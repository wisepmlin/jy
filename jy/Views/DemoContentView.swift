//
//  DemoContentView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/9.
//
import SwiftUI
import UniformTypeIdentifiers

// 主视图结构体，用于展示文档编辑界面
struct DemoContentView: View {
    @Environment(\.theme) private var theme
    private var markupConfiguration: MarkupWKWebViewConfiguration
    // 用于选择图片的观察对象
    @ObservedObject var selectImage = MarkupEditor.selectImage
    // 存储原始文本内容
    @State private var rawText = NSAttributedString(string: "")
    // 控制文档选择器的显示状态
    @State private var documentPickerShowing: Bool = false
    // 控制原始HTML显示状态
    @State private var rawShowing: Bool = false
    // 存储demo HTML内容
    @State private var demoHtml: String
    // 关闭编辑器
    @Binding var isEditView: Bool
    //编辑器类型
    let bottomBar = TabItem.editType
    // 选择的编辑器类型
    @State var seledtedType: Int = 0
    // 视图主体
    @State var isRoot: Bool = false
    var body: some View {
        NavigationStack {
            // 标记编辑器视图
            MarkupEditorView(markupDelegate: self,
                             configuration: markupConfiguration,
                             html: $demoHtml,
                             id: "Document")
            .onAppear {
                // 确保在视图加载时设置左侧工具栏
                if isRoot {
                    MarkupEditor.leftToolbar = AnyView(FileToolbar(fileToolbarDelegate: self))
                }
            }
            .onDisappear {
                MarkupEditor.selectedWebView = nil
                MarkupEditor.leftToolbar = nil
            }
            .navigationBarTitleDisplayMode(.inline)
            .overlay(alignment: .bottom) {
                // 原始HTML显示部分
                if rawShowing {
                    showHTMLView
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        isEditView.toggle()
                    }, label: {
                        Text("关闭")
                    })
                }
                ToolbarItem(placement: .principal) {
                    Text("草稿将自动保存")
                        .themeFont(theme.fonts.caption)
                        .foregroundColor(theme.subText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(theme.gray6Background.cornerRadius(16))
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        
                    }, label: {
                        Text("下一步")
                    })
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        ForEach(Array(bottomBar.enumerated()), id: \.1.id) { index, tab in
                            Button(action: {
                                seledtedType = index
                            }, label: {
                                Text(tab.title)
                                    .frame(width: 88)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .themeFont(seledtedType == index ? theme.fonts.title3 : theme.fonts.body)
                                    .fontWeight(seledtedType == index ? .bold : .regular)
                                    .foregroundColor(seledtedType == index ? theme.jyxqPrimary : theme.subText2)
                            })
                        }
                    }
                }
            }
            .background(theme.gray6Background)
        }
        // 这里会有显示模态冲突
//        .pick(isPresented: $documentPickerShowing,
//              documentTypes: [.html],
//              onPicked: openExistingDocument(url:), onCancel: nil)
//        .pick(isPresented: $selectImage.value,
//              documentTypes: MarkupEditor.supportedImageTypes,
//              onPicked: imageSelected(url:), onCancel: nil)
    }
    private var showHTMLView: some View {
        VStack {
            Divider().opacity(0.7)
            HStack {
                Spacer()
                Text("HTML代码")
                    .themeFont(theme.fonts.caption)
                    .foregroundColor(theme.subText2)
                Spacer()
            }
            TextView(text: $rawText, isEditable: false)
                .font(Font.system(size: StyleContext.P.fontSize))
        }
        .background(theme.gray6Background)
    }
    
    // 初始化方法
    init(isEditView: Binding<Bool>) {
        /// Don't specify any top-level attributes for the editor div in this demo.
        markupConfiguration = MarkupWKWebViewConfiguration()
        markupConfiguration.userCssFile = "demoDivs.css"
        if let demoUrl = Bundle.main.resourceURL?.appendingPathComponent("demo.html") {
            _demoHtml = State(initialValue: (try? String(contentsOf: demoUrl)) ?? "")
        } else {
            _demoHtml = State(initialValue: "")
        }
        self._isEditView = isEditView
        
        // 在初始化时设置左侧工具栏
        if isRoot {
            MarkupEditor.leftToolbar = AnyView(FileToolbar(fileToolbarDelegate: self))
        }
    }
    
    // 设置原始文本内容
    private func setRawText(_ handler: (()->Void)? = nil) {
        MarkupEditor.selectedWebView?.getHtml { html in
            rawText = attributedString(from: html ?? "")
            handler?()
        }
    }
    
    // 将字符串转换为富文本
    private func attributedString(from string: String) -> NSAttributedString {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.label
        attributes[.font] = UIFont.monospacedSystemFont(ofSize: StyleContext.P.fontSize, weight: .regular)
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    // 打开现有文档
    private func openExistingDocument(url: URL) {
        demoHtml = (try? String(contentsOf: url)) ?? ""
    }
    
    // 处理选中的图片
    private func imageSelected(url: URL) {
        guard let view = MarkupEditor.selectedWebView else { return }
        markupImageToAdd(view, url: url)
    }
}

// 实现MarkupDelegate协议
extension DemoContentView: MarkupDelegate {
    // 标记加载完成回调
    func markupDidLoad(_ view: MarkupWKWebView, handler: (()->Void)?) {
        MarkupEditor.selectedWebView = view
        setRawText(handler)
    }
    
    // 标记输入回调
    func markupInput(_ view: MarkupWKWebView) {
        setRawText()
    }
    
    // 图片添加完成回调
    func markupImageAdded(url: URL) {
        print("Image added from \(url.path)")
    }
}

// 文本视图结构体
struct TextView: UIViewRepresentable {
    @Binding var text: NSAttributedString
    var isEditable: Bool = true
    
    // 创建UIView
    func makeUIView(context: Context) -> UITextView {
        let textView = UIViewType()
        textView.isEditable = isEditable
        // 内边距
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        return textView
    }
    
    // 更新UIView
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.backgroundColor = UIColor.systemGray6
        uiView.attributedText = text
        uiView.spellCheckingType = .no
        uiView.autocorrectionType = .no
    }
}

// View扩展，添加文档选择功能
extension View {
    public func pick(isPresented: Binding<Bool>, documentTypes: [UTType], onPicked: ((URL)->Void)?, onCancel: (()->Void)?) -> some View {
        DocumentPicker(isPresented: isPresented, content: self, documentTypes: documentTypes, onPicked: onPicked, onCancel: onCancel)
    }
}

// 文档选择器结构体
struct DocumentPicker<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let content: Content
    var documentTypes: [UTType]
    var onPicked: ((URL) -> Void)?
    var onCancel: (() -> Void)?
    
    // 创建UIViewController
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPicker>) -> UIHostingController<Content> {
        UIHostingController(rootView: content)
    }
    
    // 协调器类
    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        var uiPicker: UIDocumentPickerViewController?
        var onPicked: ((URL) -> Void)?
        var onCancel: (() -> Void)?
        
        init(_ picker: UIDocumentPickerViewController? = nil) {
            super.init()
            uiPicker = picker
            uiPicker?.delegate = self
        }
        
        // 文档选择完成回调
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
            defer { url.stopAccessingSecurityScopedResource() }
            onPicked?(url)
        }
        
        // 文档选择取消回调
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCancel?()
        }
    }
    
    // 创建协调器
    func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        let onPickedToggle: ((URL)->Void) = { url in
            isPresented.toggle()
            onPicked?(url)
        }
        coordinator.onPicked = onPickedToggle
        let onCancelToggle: (()->Void) = {
            isPresented.toggle()
            onCancel?()
        }
        coordinator.onCancel = onCancelToggle
        return coordinator
    }
    
    // 更新UIViewController
    func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<DocumentPicker>) {
        uiViewController.rootView = content
        if isPresented && uiViewController.presentedViewController == nil {
            let controller =  UIDocumentPickerViewController(forOpeningContentTypes: documentTypes)
            controller.allowsMultipleSelection = false
            controller.delegate = context.coordinator
            context.coordinator.uiPicker = controller
            uiViewController.present(controller, animated: true)
        }
        if !isPresented && uiViewController.presentedViewController == context.coordinator.uiPicker {
            uiViewController.dismiss(animated: true)
        }
    }
}

// 文件工具栏视图
struct FileToolbar: View {
    @Environment(\.theme) private var theme
    @State private var hoverLabel: Text = Text("File")
    private var fileToolbarDelegate: FileToolbarDelegate?
    
    var body: some View {
        LabeledToolbar(label: hoverLabel) {
            ToolbarImageButton(
                systemName: "plus",
                action: { fileToolbarDelegate?.newDocument(handler: nil) },
                activeColor: theme.jyxqPrimary,
                onHover: { over in hoverLabel = Text(over ? "New" : "File") }
            )
            ToolbarImageButton(
                systemName: "newspaper",
                action: { fileToolbarDelegate?.existingDocument(handler: nil) },
                activeColor: theme.jyxqPrimary,
                onHover: { over in hoverLabel = Text(over ? "Existing" : "File") }
            )
            ToolbarImageButton(
                systemName: "chevron.left.slash.chevron.right",
                action: {
                    fileToolbarDelegate?.rawDocument()
                },
                activeColor: theme.jyxqPrimary,
                onHover: { over in hoverLabel = Text(over ? "Raw HTML" : "File") }
            )
        }
    }
    
    init(fileToolbarDelegate: FileToolbarDelegate? = nil) {
        self.fileToolbarDelegate = fileToolbarDelegate
    }
}

// 文件工具栏代理协议
@MainActor
protocol FileToolbarDelegate {
    func newDocument(handler: ((URL?)->Void)?)
    func existingDocument(handler: ((URL?)->Void)?)
    func rawDocument()
}

// DemoContentView实现FileToolbarDelegate协议
extension DemoContentView: FileToolbarDelegate {
    // 创建新文档
    func newDocument(handler: ((URL?)->Void)? = nil) {
        MarkupEditor.selectedWebView?.emptyDocument() {
            setRawText()
        }
    }
    
    // 打开现有文档
    func existingDocument(handler: ((URL?)->Void)? = nil) {
        documentPickerShowing.toggle()
    }
    
    // 显示/隐藏原始HTML
    func rawDocument() {
        withAnimation(.easeInOut) { rawShowing.toggle()}
    }
}
