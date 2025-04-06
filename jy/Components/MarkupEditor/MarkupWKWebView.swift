//
//  MarkupWKWebView.swift
//  MarkupEditor
//
//  Created by Steven Harris on 3/12/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI
import WebKit
import Combine
import OSLog
import UniformTypeIdentifiers

/// 一个专门用于支持Swift中WYSIWYG编辑的WKWebView。
///
/// 所有init方法都会调用setupForEditing，该方法加载markup.html，
/// 而markup.html又会加载markup.css和markup.js。所有从Swift到WKWebView的交互
/// 都通过这个类来完成，该类知道如何执行JavaScript来完成任务。
///
/// 当JavaScript端发生某些事件时，会由WKScriptMessageHandler处理，
/// 即MarkupCoordinator。
///
/// 所有与JavaScript的交互都是异步的。例如，WKToolbar可能会在selectedWebView上
/// 调用`bold(handler:)`。对JavaScript的调用中的handler是可选的。在JavaScript端，
/// 我们运行`MU.toggleBold()`。`toggleBold()`最后会调用`_callback('input')`。
/// 这会导致在MarkupCoordinator中调用`userContentController(_:didReceive)`，
/// 让我们知道JavaScript端发生了什么。通过这种方式，我们可以根据需要
/// 在Swift中维护关于MarkupWKWebView中内容的最新信息。
///
/// MarkupWKWebView使用inputAccessoryView处理键盘，显示MarkupToolbarUIView。
/// 默认情况下，除手机外，MarkupEditor.toolbarPosition都设置为.top，
/// 但我们仍然需要一种方法来在没有键盘或菜单访问的设备上关闭键盘。
/// 因此，默认情况下，inputAccessoryView包含MarkupToolbar.shared和
/// 隐藏键盘按钮。
///
/// 如果你有自己的inputAccessoryView，那么你必须将MarkupEditor.toolbarPosition
/// 设置为.none并自行处理
/// 所有内容都需要自己处理。
public class MarkupWKWebView: WKWebView, ObservableObject {
    public typealias TableBorder = MarkupEditor.TableBorder
    public typealias TableDirection = MarkupEditor.TableDirection 
    public typealias FindDirection = MarkupEditor.FindDirection
    private let selectionState = SelectionState()       // 本地缓存,特定于此视图
    public var clientHeightPad: Int = 8                 // 用于调整html clientHeight的值
    public private(set) var isReady: Bool = false       // 是否准备好进行编辑
    public var hasFocus: Bool = false                   // 是否获得焦点
    private var editorHeight: Int = 0                   // 编辑器高度
    /// The HTML that is currently loaded, if it is loaded. If it has not been loaded yet, it is the
    /// HTML that will be loaded once it finishes initializing.
    private var html: String?
    private var placeholder: String?            // 当html为nil或空时显示的字符串
    public var selectAfterLoad: Bool = true     // 加载html后是否设置选择
    public var baseUrl: URL { cacheUrl() }      // WKWebView的工作目录,用于加载markup.html等文件
    private var resourcesUrl: URL?              // 资源文件URL
    public var id: String = UUID().uuidString   // 视图唯一标识符
    /// 在文档末尾注入的用户脚本
    public var userScripts: [String]? {
        didSet {
            if let userScripts {
                configuration.userContentController.removeAllUserScripts()
                for script in userScripts {
                    let wkUserScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                    configuration.userContentController.addUserScript(wkUserScript)
                }
            }
        }
    }
    public var markupConfiguration: MarkupWKWebViewConfiguration?
    /// 用户提供的JS文件,在视图准备就绪但在loadInitialHtml之前加载
    ///
    /// The file should be included as a resource of the app that consumes the MarkupEditor. The file
    /// specified here is independent of the userScripts strings. Either, both, or none can be specified.
    private var userScriptFile: String? { markupConfiguration?.userScriptFile }
    /// 用户提供的CSS文件,在视图准备就绪但在loadInitialHtml之前加载
    ///
    /// The file should be included as a resource of the app that consumes the MarkupEditor.
    private var userCssFile: String? { markupConfiguration?.userCssFile }
    // 由于拖放支持的需要,这里必须持有markupDelegate引用
    private var markupDelegate: MarkupDelegate?
    /// 追踪粘贴动作是否已被调用,避免重复调用,参考 https://developer.apple.com/forums/thread/696525
    var pastedAsync = false                     // 追踪粘贴动作是否已被调用,避免重复调用
    /// 用于覆盖UIResponder的inputAccessoryView的附加视图
    public var accessoryView: UIView? {
        didSet {
            guard let accessoryView else {
                // 当accessoryView被设置为nil时,移除高度约束和通知观察者
                markupToolbarHeightConstraint = nil
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
                return
            }
            markupToolbarHeightConstraint = NSLayoutConstraint(item: accessoryView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
            markupToolbarHeightConstraint.isActive = true
            // 使用键盘通知来调整markupToolbar作为accessoryView的大小
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        }
    }
    private var oldContentOffset: CGPoint?
    private var markupToolbarHeightConstraint: NSLayoutConstraint!
    private var firstResponder: AnyCancellable?
    
    /// MarkupWKWebView中可粘贴的内容类型
    public enum PasteableType {
        case Text           // 文本
        case Html          // HTML
        case Rtf           // RTF格式
        case ExternalImage // 外部图片
        case LocalImage    // 本地图片
        case Url          // URL链接
    }
    
    public override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        initForEditing()
    }
    
    public required init?(coder: NSCoder) {
        super.init(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        initForEditing()
    }
    
    public init(html: String? = nil, placeholder: String? = nil, selectAfterLoad: Bool = true, resourcesUrl: URL? = nil, id: String? = nil, markupDelegate: MarkupDelegate? = nil, configuration: MarkupWKWebViewConfiguration? = nil) {
        super.init(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        self.html = html
        self.placeholder = placeholder
        self.selectAfterLoad = selectAfterLoad
        self.resourcesUrl = resourcesUrl
        if id != nil {
            self.id = id!
        }
        self.markupDelegate = markupDelegate
        // 如果configuration为nil,则设置为默认值
        // 这样setTopLevelAttributes将设置editor为可编辑
        markupConfiguration = configuration ?? MarkupWKWebViewConfiguration()
        initForEditing()
    }
    /// 正确设置编辑功能
    ///
    /// 设置过程包括在缓存目录中填充"根"文件：markup.html、
    /// markup.css 和 markup.js。此外，如果指定了 resourcesUrl，
    /// 则其内容会被复制到缓存目录下的相同相对路径中。这意味着 resourcesUrl 
    /// 通常应该有一个 baseUrl，即编辑的 html 文件所在的位置。如果 resourcesUrl 
    /// 没有 baseUrl，那么 resourcesUrl 中的所有内容都会与"根"文件一起
    /// 被复制到缓存目录中。
    ///
    /// 一旦所有文件都在 cacheDir 中正确设置好，我们就会加载 markup.html，
    /// 它随后会自行加载 css 和 js 脚本。markup.html 定义了"editor"元素，
    /// 该元素后续会被填充 html 内容。
    private func initForEditing() {
        // 设置为不透明,避免暗模式下闪烁
        isOpaque = false                        
        // 设置背景色为系统背景色
        backgroundColor = .systemBackground     
        // 初始化根文件
        initRootFiles()
        // 调用代理的设置方法
        markupDelegate?.markupSetup(self)
        
        // 获取markup.html的临时路径
        let tempRootHtml = cacheUrl().appendingPathComponent("markup.html")
        // 加载markup.html文件
        loadFileURL(tempRootHtml, allowingReadAccessTo: tempRootHtml.deletingLastPathComponent())
        
        // 解析tintColor以支持暗模式
        tintColor = tintColor.resolvedColor(with: .current)
        
        // 根据工具栏位置设置输入附件视图
        if MarkupEditor.toolbarLocation == .keyboard {
            inputAccessoryView = MarkupToolbarUIView.inputAccessory(markupDelegate: markupDelegate)
        }
        
        // 观察第一响应者变化
        observeFirstResponder()
    }
    
    // 监听第一响应者变化
    private func observeFirstResponder() {
        firstResponder = MarkupEditor.observedFirstResponder.$id.sink { [weak self] selectedId in
            guard let selectedId, let self, self.id == selectedId else {
                return
            }
            self.becomeFirstResponderIfReady()
        }
    }
    
    // 在准备就绪时成为第一响应者
    public func becomeFirstResponderIfReady() {
        guard isReady else { return }
        if becomeFirstResponder() {
            // 设置为当前选中的WebView
            MarkupEditor.selectedWebView = self
            
            if !hasFocus {
                // 先获取焦点再设置选区
                focus {
                    self.setSelection()
                }
            } else {
                setSelection()
            }
        }
    }
    
    // 设置选区
    private func setSelection() {
        guard hasFocus else { return }
        getSelectionState { selectionState in
            if selectionState.isValid {
                // 更新本地和全局选区状态
                self.selectionState.reset(from: selectionState)             
                MarkupEditor.selectionState.reset(from: selectionState)     
            } else {
                // 重置选区
                self.resetSelection {
                    self.getSelectionState { newSelectionState in
                        if newSelectionState.isValid {
                            self.selectionState.reset(from: newSelectionState)         
                            MarkupEditor.selectionState.reset(from: newSelectionState) 
                        }
                    }
                }
            }
        }
    }
    
    // 重置选区到文档开始位置
    func resetSelection(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.resetSelection()") { result, error in
            if let error {
                Logger.webview.error("resetSelection error: \(error.localizedDescription)")
            }
            handler?()
        }
    }
    
    // 设置编辑器焦点
    func focus(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.focus()") { result, error in
            if let error {
                Logger.webview.error("focus error: \(error)")
                self.hasFocus = false
            } else {
                self.hasFocus = true
            }
            handler?()
        }
    }
    
    // 获取适当的Bundle
    func bundle() -> Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: MarkupWKWebView.self)
        #endif
    }
    
    // 获取资源URL,优先使用主Bundle中的资源
    func url(forResource name: String, withExtension ext: String?) -> URL? {
        let url = bundle().url(forResource: name, withExtension: ext)
        return Bundle.main.url(forResource: name, withExtension: ext) ?? url
    }
    
    // 初始化缓存目录中的根资源文件
    private func initRootFiles() {
        // 获取必要的资源文件URL
        guard
            let rootHtml = url(forResource: "markup", withExtension: "html"),
            let rootCss = url(forResource: "markup", withExtension: "css"),
            let rootJs = url(forResource: "markup", withExtension: "js") else {
            assertionFailure("Could not find markup.html, css, and js for this bundle.")
            return
        }
        
        // 收集所有需要复制的源文件URL
        var srcUrls = [rootHtml, rootCss, rootJs]
        
        // 添加用户自定义CSS文件
        if let userCssFile, let userCss = url(forResource: userCssFile, withExtension: nil) {
            srcUrls.append(userCss)
        }
        
        // 添加用户自定义脚本文件
        if let userScriptFile, let userScript = url(forResource: userScriptFile, withExtension: nil) {
            srcUrls.append(userScript)
        }
        
        let fileManager = FileManager.default
        let cacheUrl = cacheUrl()
        let cacheUrlPath = cacheUrl.path
        
        do {
            // 创建缓存目录
            try fileManager.createDirectory(atPath: cacheUrlPath, withIntermediateDirectories: true, attributes: nil)
            
            // 复制所有源文件到缓存目录
            for srcUrl in srcUrls {
                let dstUrl = cacheUrl.appendingPathComponent(srcUrl.lastPathComponent)
                try? fileManager.removeItem(at: dstUrl)
                try fileManager.copyItem(at: srcUrl, to: dstUrl)
            }
        } catch let error {
            assertionFailure("Failed to set up cacheDir with root resource files: \(error.localizedDescription)")
        }
    }
    
    /// 填充从resourcesUrl复制的资源。
    ///
    /// markupDelegate默认在markupSetup()中调用此方法。要自定义cacheUrl的填充,
    /// 请在markupDelegate中的markupSetup()中重写。否则,默认行为是将resourcesUrl中的所有内容
    /// 复制到cacheUrl下的相同相对路径中。
    public func setup() {
        // 将resourcesUrl的内容复制到cacheUrl下的相对路径或cacheUrl本身。
        // 虽然未能正确设置根文件会导致断言失败,但未能正确复制resourceUrl中的文件则会静默失败。
        guard let resourcesUrl = resourcesUrl else {
            return
        }
        let fileManager = FileManager.default
        let cacheUrl = cacheUrl()
        var tempResourcesUrl: URL
        if resourcesUrl.baseURL == nil {
            tempResourcesUrl = cacheUrl
        } else {
            tempResourcesUrl = cacheUrl.appendingPathComponent(resourcesUrl.relativePath)
        }
        let tempResourcesUrlPath = tempResourcesUrl.path
        do {
            try fileManager.createDirectory(atPath: tempResourcesUrlPath, withIntermediateDirectories: true, attributes: nil)
            // 如果我们指定了resourceUrl但没有资源,这不是错误
            let resources = (try? fileManager.contentsOfDirectory(at: resourcesUrl, includingPropertiesForKeys: nil, options: [])) ?? []
            for srcUrl in resources {
                let dstUrl = tempResourcesUrl.appendingPathComponent(srcUrl.lastPathComponent)
                try? fileManager.removeItem(at: dstUrl)
                try fileManager.copyItem(at: srcUrl, to: dstUrl)
            }
            
        } catch let error {
            Logger.webview.error("Failure copying resource files: \(error.localizedDescription)")
        }
    }
    
    /// 返回资源文件是否存在于预期位置。
    ///
    /// 资源相对于cacheUrl引用,我们在测试期间使用此方法。
    public func resourceExists(_ fileName: String) -> Bool {
        return FileManager.default.fileExists(atPath: cacheUrl().appendingPathComponent(fileName).path)
    }
    
    /// 清理我们为使用MarkupEditor而设置的内容。
    ///
    /// 默认情况下,我们删除cacheUrl中的所有内容。如果出现问题则静默失败。
    public func teardown() {
        try? FileManager.default.removeItem(atPath: cacheUrl().path)
    }
    
    /// 返回应用缓存目录下"id"子目录的URL
    private func cacheUrl() -> URL {
        let cacheUrls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return cacheUrls[0].appendingPathComponent(id)
    }
    
    /// 为编辑器元素设置EditableAttributes。
    public func setTopLevelAttributes(_ handler: (()->Void)? = nil) {
        guard 
            let attributes = markupConfiguration?.topLevelAttributes,
            !attributes.isEmpty,
            let jsonData = try? JSONSerialization.data(withJSONObject: attributes.options),
            let jsonString = String(data: jsonData, encoding: .utf8)
        else {
            handler?()
            return
        }
        evaluateJavaScript("MU.setTopLevelAttributes('\(jsonString)')") { result, error in
            handler?()
        }
    }
    
    /// 调用`loadUserFiles`加载`userScriptFile`和`userCssFile`,无论是否指定了这两个文件。
    /// 结果将回调到`loadedUserFiles`,这会触发`loadInitialHtml`和对MarkupDelegate.markupLoaded的调用。
    public func loadUserFiles(_ handler: (()->Void)? = nil) {
        let scriptFile = userScriptFile == nil ? "null": "'\(userScriptFile!)'"
        let cssFile = userCssFile == nil ? "null" : "'\(userCssFile!)'"
        evaluateJavaScript("MU.loadUserFiles(\(scriptFile), \(cssFile))") { result, error in
            handler?()
        }
    }
    
    /// 加载初始HTML内容,通知代理,并在selectAfterLoad为true时成为第一响应者
    ///
    /// 在某些情况下,你可能不希望在加载后选中。例如,如果你在单个View/UIView
    /// 或者List中使用多个MarkupWKWebView,那么你会希望通过id设置
    /// MarkupEditor.firstResponder,而不是让每个MarkupWKWebView都成为
    /// 第一响应者并在加载HTML时触发SelectionState更新来刷新MarkupToolbar。
    public func loadInitialHtml() {
        setPlaceholder {
            self.markupDelegate?.markupWillLoad(self)
            self.setHtml(self.html ?? "") {
                //Logger.webview.debug("isReady: \(self.id)")
                self.isReady = true
                if let delegate = self.markupDelegate {
                    delegate.markupDidLoad(self) {
                        if self.selectAfterLoad {
                            self.becomeFirstResponderIfReady()
                        }
                    }
                } else {
                    if self.selectAfterLoad {
                        self.becomeFirstResponderIfReady()
                    }
                }
            }
        }
    }
    
    //MARK: Keyboard handling and accessoryView setup

    /// 响应键盘即将显示事件
    ///
    /// 我们调整工具栏高度约束使其正确显示,并滚动选区以避免被键盘遮挡
    ///
    /// 我们希望在键盘隐藏时恢复任何初始的contentOffset。但是,我们会收到多个
    /// keyboardWillShow事件,在第一次之后的事件中,contentOffset可能已经
    /// 被神奇地改变成我们不想重置的值。因此,我们只在第一次keyboardWillShow
    /// 事件中捕获和恢复contentOffset。
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        markupToolbarHeightConstraint.constant = MarkupEditor.toolbarStyle.height()
        // Gate the oldContentOffset setting so it only happens once; reset to nil at keyboardDidHide time
        if oldContentOffset == nil { oldContentOffset = scrollView.contentOffset }
        if hasFocus, let oldContentOffset, let actualSourceRect = selectionState.sourceRect {
            let sourceRect = CGRect(origin: actualSourceRect.origin, size: CGSize(width: actualSourceRect.width, height: actualSourceRect.height))
            guard let userInfo = notification.userInfo else { return }
            // 在iOS 16.1及以后,键盘通知对象是键盘出现的屏幕
            guard let screen = notification.object as? UIScreen,
                  // 获取键盘动画结束时的frame
                  let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
            // 使用screen获取要转换的坐标空间
            let fromCoordinateSpace = screen.coordinateSpace
            // 获取此视图的坐标空间
            let toCoordinateSpace: UICoordinateSpace = self
            // 将扩展的键盘frame从屏幕坐标空间转换到此视图的坐标空间
            let convertedKeyboardFrameEnd = fromCoordinateSpace.convert(keyboardFrameEnd, to: toCoordinateSpace)
            // 获取键盘frame和视图bounds的交集。与TextView不同,我们不想使用视图的
            // scrollview将其推离键盘,而是想在键盘与选区重叠时滚动MarkupWKWebView
            // 内的文本,选区保存在sourceRect中。
            let viewIntersection = bounds.intersection(convertedKeyboardFrameEnd)
            let sourceIntersection = sourceRect.intersection(convertedKeyboardFrameEnd)
            // 在宣布需要的偏移量之前检查键盘是否与选区相交。如果键盘根本没有
            // 覆盖sourceRect,我们就不需要做任何事情。
            if !sourceIntersection.isEmpty {
                let bottomOffset = sourceIntersection.maxY - viewIntersection.minY
                if bottomOffset > 0 {
                    scrollView.setContentOffset(CGPoint(x: oldContentOffset.x, y: oldContentOffset.y + bottomOffset), animated: true)
                }
            }
        }
    }
    
    /// 响应键盘已隐藏事件
    ///
    /// 调整MarkupToolbar的高度约束并重置contentOffset。
    /// 重置oldContentOffset,这样下次keyboardWillShow发生时可以根据它是否为nil来判断。
    @objc private func keyboardDidHide() {
        markupToolbarHeightConstraint.constant = 0
        scrollView.setContentOffset(oldContentOffset ?? CGPoint.zero, animated: true)
        oldContentOffset = nil
    }
    
    //MARK: Overrides
    
    /// 重写hitTest以启用拖放事件
    ///
    /// 视图接收UIDragEvents,这似乎是UIEvent.EventType的一个私有类型。
    /// 当hitTest正常响应这些事件时,它们返回MarkupWKWebView实例,
    /// 该实例永远不会收到sessionDidUpdate或performDrop消息,即使它
    /// 确实响应可以处理拖放。这看起来只是一个bug。解决方案是在父视图
    /// (即WKWebView)中处理"正常"拖动事件,在MarkupWKWebView中
    /// 处理UIDragEvent。
    ///
    /// 为了避免直接访问私有事件类型,我们首先检查所有公开可识别的事件,
    /// 让超类处理它们。默认情况下捕获其他所有内容(据我所知只有UIDragEvent),
    /// 并只返回self(这个MarkupWKWebView实例)。最终结果是我们在这里看到拖放。
    ///
    /// 不确定这个hack是否能长期存在。如果有办法判断event.type是否是公共
    /// UIEvent.EventType枚举的一部分就更好了,但这似乎是不可能的。
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let event = event else { return nil }
        switch event.type {
        case .hover, .motion, .presses, .remoteControl, .scroll, .touches, .transform:
            // 让超类处理所有公开识别的事件类型
            //if event.type != .hover { // Else mouse movement over the view produces a zillion hover log messages
            //    Logger.webview.debug("Letting WKWebView handle: \(event.description)")
            //}
            return super.hitTest(point, with: event)
        default:
            // 我们将自己处理UIDragEvent
            //Logger.webview.debug("MarkupWKWebView handling: \(event.description)")
            return self
        }
    }
    
    //MARK: Responder Handling
    
    // 以下两个重写被移除,因为它们会导致keyboardWillShow事件被触发太多次,
    // 有时甚至在键盘不会显示时也会触发(比如在没有键盘显示时旋转屏幕)。
    //public override var canBecomeFirstResponder: Bool {
    //    return hasFocus
    //}
    
    //public override var canResignFirstResponder: Bool {
    //    return !hasFocus
    //}
    
    public override var inputAccessoryView: UIView? {
        get { accessoryView }
        set { accessoryView = newValue }
    }
    
    /// Return false to disable various menu items depending on selectionState
    @objc override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard selectionState.isValid else { return false }
        switch action {
        case #selector(getter: undoManager):
            return true
        case #selector(UIResponderStandardEditActions.select(_:)), #selector(UIResponderStandardEditActions.selectAll(_:)):
            return super.canPerformAction(action, withSender: sender)
        case #selector(UIResponderStandardEditActions.copy(_:)), #selector(UIResponderStandardEditActions.cut(_:)):
            return selectionState.canCopyCut
        case #selector(UIResponderStandardEditActions.paste(_:)), #selector(UIResponderStandardEditActions.pasteAndMatchStyle(_:)):
            return pasteableType() != nil
        case #selector(indent), #selector(outdent):
            return selectionState.canDent
        case #selector(bullets), #selector(numbers):
            return selectionState.canList
        case #selector(pStyle), #selector(h1Style), #selector(h2Style), #selector(h3Style), #selector(h4Style), #selector(h5Style), #selector(h6Style), #selector(pStyle):
            return selectionState.canStyle
        case #selector(showPluggableLinkPopover), #selector(showPluggableImagePopover), #selector(showPluggableTablePopover):
            return true     // Toggles off and on
        case #selector(bold), #selector(italic), #selector(underline), #selector(code), #selector(strike), #selector(subscriptText), #selector(superscript):
            return selectionState.canFormat
        default:
            //Logger.webview.debug("Unknown action: \(action)")
            return false
        }
    }
    
    public func startModalInput(_ handler: (() -> Void)? = nil) {
        evaluateJavaScript("MU.startModalInput()") { result, error in
            handler?()
        }
    }
    
    public func endModalInput(_ handler: (() -> Void)? = nil) {
        evaluateJavaScript("MU.endModalInput()") { result, error in
            handler?()
        }
    }
    
    /// Indirect the presentation of the link popover thru the markupDelegate to allow overriding.
    @objc public func showPluggableLinkPopover() {
        markupDelegate?.markupShowLinkPopover(self)
    }
    
    /// Indirect the presentation of the image popover thru the markupDelegate to allow overriding.
    @objc public func showPluggableImagePopover() {
        markupDelegate?.markupShowImagePopover(self)
    }
    
    /// Indirect the presentation of the table popover thru the markupDelegate to allow overriding.
    @objc public func showPluggableTablePopover() {
        markupDelegate?.markupShowTablePopover(self)
    }
    
    /// Show the default link popover using the LinkViewController.
    @objc public func showLinkPopover() {
        MarkupEditor.showInsertPopover.type = .link     // Does nothing by default
        startModalInput()                               // Required to deal with focus properly for popovers
        let linkVC = LinkViewController()
        linkVC.modalPresentationStyle = .popover
        linkVC.preferredContentSize = CGSize(width: 300, height: 100 + 2.0 * MarkupEditor.toolbarStyle.buttonHeight())
        guard let popover = linkVC.popoverPresentationController else { return }
        popover.delegate = self
        popover.sourceView = self
        // The sourceRect needs a non-zero width/height, but when selection is collapsed, we get a zero width.
        // The selectionState.sourceRect makes sure selRect has non-zero width/height.
        popover.sourceRect = MarkupEditor.selectionState.sourceRect ?? bounds
        closestVC()?.present(linkVC, animated: true)
    }
    
    /// Show the default link popover using the ImageViewController.
    @objc public func showImagePopover() {
        MarkupEditor.showInsertPopover.type = .image    // Does nothing by default
        startModalInput()                               // Required to deal with focus properly for popovers
        let imageVC = ImageViewController()
        imageVC.modalPresentationStyle = .popover
        imageVC.preferredContentSize = CGSize(width: 300, height: 140 + 2.0 * MarkupEditor.toolbarStyle.buttonHeight())
        guard let popover = imageVC.popoverPresentationController else { return }
        popover.delegate = self
        popover.sourceView = self
        // The sourceRect needs a non-zero width/height, but when selection is collapsed, we get a zero width.
        // The selectionState.sourceRect makes sure selRect has non-zero width/height.
        popover.sourceRect = MarkupEditor.selectionState.sourceRect ?? bounds
        closestVC()?.present(imageVC, animated: true)
    }
    
    /// Show the default table popover by setting the state of `MarkupEditor.showInsertPopover` to `.table`,
    /// which will in turn `forcePopover` of either the TableSizer or TableToolbar.
    @objc public func showTablePopover() {
        guard selectionState.canInsert else { return }
        startModalInput()                               // Required to deal with focus properly for popovers
        MarkupEditor.showInsertPopover.type = .table    // Triggers default SwiftUI TableSizer or TableToolbar
    }
    
    //MARK: Testing support

    /// Set the html content for testing after a delay.
    ///
    /// The small delay seems to avoid intermitted problems when running many tests together.
    public func setTestHtml(value: String, handler: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.evaluateJavaScript("MU.setHTML('\(value.escaped)')") { result, error in handler?() }
        }
    }
    
    /// Set the range for testing.
    ///
    /// If startChildNodeIndex is nil, then startOffset is the offset into the childNode with startId in parentNode;
    /// if not, then the startOffset is the offset into parentNode.childNodes[startChildNodeIndex].
    /// If endChildNodeIndex is nil, then endOffset is the offset into the childNode with endId parentNode;
    /// if not, then the endOffset is the offset into parentNode.childNodes[endChildNodeIndex].
    public func setTestRange(startId: String, startOffset: Int, endId: String, endOffset: Int, startChildNodeIndex: Int? = nil, endChildNodeIndex: Int? = nil, handler: @escaping (Bool) -> Void) {
        var rangeCall = "MU.setRange('\(startId)', '\(startOffset)', '\(endId)', '\(endOffset)'"
        if let startChildNodeIndex = startChildNodeIndex {
            rangeCall += ", '\(startChildNodeIndex)'"
        } else {
            rangeCall += ", null"
        }
        if let endChildNodeIndex = endChildNodeIndex {
            rangeCall += ", '\(endChildNodeIndex)'"
        } else {
            rangeCall += ", null"
        }
        rangeCall += ")"
        evaluateJavaScript(rangeCall) { result, error in
            handler(result as? Bool ?? false)
        }
    }
    
    /// Invoke the preprocessing step for MU.pasteHTML directly.
    public func testPasteHtmlPreprocessing(html: String, handler: ((String?)->Void)? = nil) {
        evaluateJavaScript("MU.testPasteHTMLPreprocessing('\(html.escaped)')") { result, error in
            handler?(result as? String)
        }
    }
    
    /// Invoke the preprocessing step for MU.pasteText directly.
    public func testPasteTextPreprocessing(html: String, handler: ((String?)->Void)? = nil) {
        evaluateJavaScript("MU.testPasteTextPreprocessing('\(html.escaped)')") { result, error in
            handler?(result as? String)
        }
    }
    
    /// Invoke the \_undoOperation directly.
    ///
    /// Delay to allow the async operation being done to have completed.
    public func testUndo(handler: (()->Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.evaluateJavaScript("MU.testUndo()") { result, error in handler?() }
        }
    }
    
    /// Invoke the \_redoOperation directly.
    ///
    /// Delay to allow the async operation being undone to have completed.
    public func testRedo(handler: (()->Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.evaluateJavaScript("MU.testRedo()") { result, error in handler?() }
        }
    }
    
    /// Invoke the \_doBlockquoteEnter operation directly.
    public func testBlockquoteEnter(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.testBlockquoteEnter()") { result, error in handler?() }
    }
    
    /// Invoke the \_doListEnter operation directly.
    public func testListEnter(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.testListEnter()") { result, error in handler?() }
    }
    
    /// Ensure extractContents behaves as expected, since we depend on it.
    public func testExtractContents(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.testExtractContents()") { result, error in handler?() }
    }
    
    //MARK: Javascript interactions
    
    /// Return the HTML contained in this MarkupWKWebView.
    ///
    /// By default, we return nicely formatted HTML stripped of DIVs, SPANs, and empty text nodes.
    public func getHtml(pretty: Bool = true, clean: Bool = true, divID: String? = nil, _ handler: ((String?)->Void)?) {
        // By default, we get "pretty" and "clean" HTML.
        //  Pretty HTML is formatted to be readable.
        //  Clean HTML has divs, spans, and empty text nodes removed.
        let argString = divID == nil ? "'\(pretty)', '\(clean)'" : "'\(pretty)', '\(clean)', '\(divID!)'"
        evaluateJavaScript("MU.getHTML(\(argString))") { result, error in
            handler?(result as? String)
        }
    }
    
    /// Return unformatted but clean HTML contained in this MarkupWKWebView.
    ///
    /// The HTML is functionally equivalent to `getHtml()` but is compressed.
    public func getRawHtml(divID: String? = nil, _ handler: ((String?)->Void)?) {
        getHtml(pretty: false, divID: divID, handler)
    }
    
    public func emptyDocument(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.emptyDocument()") { result, error in
            handler?()
        }
    }
    
    public func setPlaceholder(handler: (()->Void)? = nil) {
        guard let placeholder else {
            handler?()
            return
        }
        evaluateJavaScript("MU.setPlaceholder('\(placeholder.escaped)')") { result, error in
            handler?()
        }
    }
    
    public func setHtml(_ html: String, handler: (()->Void)? = nil) {
        self.html = html    // Our local record of what we set, used by setHtmlIfChanged
        evaluateJavaScript("MU.setHTML('\(html.escaped)', \(selectAfterLoad))") { result, error in
            handler?()
        }
    }
    
    public func setHtmlIfChanged(_ html: String, handler: (()->Void)? = nil) {
        if html != self.html {
            setHtml(html, handler: handler)
        } else {
            handler?()
        }
    }
    
    /// Set the CSS padding-block bottom so that the padding fills the frame height.
    public func padBottom(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.padBottom('\(frame.height)')") { result, error in
            if let error {
                Logger.webview.error("Error: \(error)")
            }
            handler?()
        }
    }
    
    /// Update the internal height tracking.
    public func updateHeight(handler: ((Int)->Void)?) {
        self.getHeight() { clientHeight in
            if self.editorHeight != clientHeight {
                self.editorHeight = clientHeight
                handler?(clientHeight + self.clientHeightPad)
            }
        }
    }
    
    public func cleanUpHtml(handler: ((Error?)->Void)?) {
        evaluateJavaScript("MU.cleanUpHTML()") { result, error in
            handler?(error)
        }
    }
    
    public func insertLink(_ href: String?, handler: (()->Void)? = nil) {
        if href == nil {
            evaluateJavaScript("MU.deleteLink()") { result, error in handler?() }
        } else {
            evaluateJavaScript("MU.insertLink('\(href!.escaped)')") { result, error in handler?() }
        }
    }
    
    public func insertImage(src: String?, alt: String?, handler: (()->Void)? = nil) {
        var args = "'\(src!.escaped)'"
        if alt != nil {
            args += ", '\(alt!.escaped)'"
        }
        becomeFirstResponder()
        evaluateJavaScript("MU.insertImage(\(args))") { result, error in handler?() }
    }
    
    public func insertLocalImage(url: URL, handler: ((URL)->Void)? = nil) {
        // TODO: Use extended attributes for alt text if available
        // (see https://stackoverflow.com/a/38343753/8968411)
        // Make a new unique ID for the image to save in the cacheUrl directory
        var path = "\(UUID().uuidString).\(url.pathExtension)"
        if let resourcesUrl {
            path = resourcesUrl.appendingPathComponent(path).relativePath
        }
        let cachedImageUrl = URL(fileURLWithPath: path, relativeTo: cacheUrl())
        do {
            try FileManager.default.copyItem(at: url, to: cachedImageUrl)
            insertImage(src: path, alt: nil) {
                handler?(cachedImageUrl)
            }
        } catch let error {
            Logger.webview.error("Error inserting local image: \(error.localizedDescription)")
            handler?(cachedImageUrl)
        }
    }
    
    /// Copy both the html for the image and the image itself to the clipboard.
    ///
    /// Why copy both? For copy/paste within the document itself, we always want to paste the HTML. The html
    /// points to the same image file at the same scale as exists in the document already. But, if the user wants
    /// to copy an image from the document and paste it into some other app, then they need the image from src
    /// at its full resolution. However, if the image in the MarkupEditor document is an external image, then we
    /// populate the public.html, not the public.png, so external pasting uses the url.
    public func copyImage(src: String, alt: String?, width: Int?, height: Int?) {
        guard let url = URL(string: src) else {
            markupDelegate?.markupError(code: "Invalid image URL", message: "The url for the image to copy was invalid.", info: "src: \(src)", alert: true)
            return
        }
        var html = ""
        var items = [String : Any]()
        // First, get the pngData for any local element, and start populating html with src
        if url.isFileURL, let fileUrl = URL(string: url.path) {
            // File urls need to reside at the cacheUrl or we don't put it in the pasteboard.
            // The src is specified relative to the cacheUrl().
            if (url.path.starts(with: cacheUrl().path)) {
                let cachedImageUrl = URL(fileURLWithPath: fileUrl.lastPathComponent, relativeTo: cacheUrl())
                if let urlData = try? Data(contentsOf: cachedImageUrl) {
                    let ext = cachedImageUrl.pathExtension
                    if let publicName = ext.isEmpty ? nil : "public." + ext {
                        items[publicName] = urlData
                    }
                    html += "<img src=\"\(cachedImageUrl.relativePath)\""
                }
            }
            guard !items.isEmpty else {
                markupDelegate?.markupError(code: "Invalid local image", message: "Could not copy image data to pasteboard.", info: "src: \(src)", alert: true)
                return
            }
        } else {
            // Src is the full path
            html += "<img src=\"\(src)\""
        }
        if let alt = alt { html += " alt=\"\(alt)\""}
        if let width = width, let height = height { html += " width=\"\(width)\" height=\"\(height)\""}
        html += ">"
        guard let htmlData = html.data(using: .utf8) else { // Should never happen
            markupDelegate?.markupError(code: "Invalid image HTML", message: "The html for the image to copy was invalid.", info: "html: \(html)", alert: true)
            return
        }
        items["markup.image"] = htmlData        // Always load up our custom pasteboard element
        if !url.isFileURL {
            items["public.html"] = htmlData     // And for external images, load up the html
        }
        let pasteboard = UIPasteboard.general
        pasteboard.setItems([items])
    }
    
    private func getHeight(_ handler: @escaping ((Int)->Void)) {
        evaluateJavaScript("MU.getHeight()") { result, error in
            handler(result as? Int ?? 0)
        }
    }
    
    /// Search for text in the direction specified.
    ///
    /// *NOTE*: If you specify `activate: true`, then It is very important to `deactivateSearch` or `cancelSearch`
    /// when you're done searching. When `activate: true` is specified, on the JavaScript side a search becomes "active",
    /// and subsequent input of Enter in the MarkupWKWebView will search for the next occurrence of `text` in the `direction`
    /// specified until `deactivateSearch` or `cancelSearch` is called.
    public func search(for text: String, direction: FindDirection, activate: Bool = false, handler: (()->Void)? = nil) {
        startModalInput() {
            self.becomeFirstResponder()
            // Remove the "smartquote" stuff that happens when inputting search into a TextField.
            // On the Swift side, replace the search string characters with the proper equivalents
            // for the MarkupEditor. To pass mixed apostrophes and quotes in the JavaScript call,
            // replace all apostrophe/quote-like things with "&quot;"/"&apos;", which we will
            // replace with "\"" and "'" on the JavaScript side before doing a search.
            let patchedText = text
                .replacingOccurrences(of: "\u{0027}", with: "&apos;")   // '
                .replacingOccurrences(of: "\u{2018}", with: "&apos;")   // ‘
                .replacingOccurrences(of: "\u{2019}", with: "&apos;")   // ‘
                .replacingOccurrences(of: "\u{0022}", with: "&quot;")   // "
                .replacingOccurrences(of: "\u{201C}", with: "&quot;")   // “
                .replacingOccurrences(of: "\u{201D}", with: "&quot;")   // ”
            self.evaluateJavaScript("MU.searchFor(\"\(patchedText)\", \"\(direction)\", \"\(activate)\")") { result, error in
                if let error {
                    Logger.webview.error("Error: \(error)")
                }
                handler?()
            }
        }
    }
    
    /// Stop intercepting Enter to invoke searchForNext().
    public func deactivateSearch(handler: (()->Void)? = nil) {
        endModalInput() {
            self.evaluateJavaScript("MU.deactivateSearch()") { result, error in
                if let error {
                    Logger.webview.error("Error: \(error)")
                }
                handler?()
            }
        }
    }
    
    /// Cancel the search that is underway, so that Enter is no longer intercepted and indexes are cleared on the JavaScript side.
    public func cancelSearch(handler: (()->Void)? = nil) {
        endModalInput() {
            self.evaluateJavaScript("MU.cancelSearch()") { result, error in
                if let error {
                    Logger.webview.error("Error: \(error)")
                }
                handler?()
            }
        }
    }
    
    /// Scroll the view so that the selection is visible.
    ///
    /// We use the selrect found in selection state, pad it by 8 vertically, and scroll a minimum
    /// amount to keep put that padded rectangle fully in the view. Scrolling never moves the
    /// top below 0 or the bottom above the scrollView.contentHeight.
    public func makeSelectionVisible(handler: (()->Void)? = nil) {
        getSelectionState() { state in
            guard let selrect = state.selrect else {
                handler?()
                return
            }
            // We pad selrect because we don't want to scroll so it is right at the top
            // or bottom, but instead is a reasonable amount inset.
            let padrect = selrect.insetBy(dx: 0, dy: -8)
            // Find intersection of padrect and visible portion of document. The selrect is always
            // relative to the frame, so we can use frame for the intersection.
            let intersection = padrect.intersection(self.frame)
            // If the intersection is the full padrect, then it is fully visible and we can return
            // without scrolling.
            if intersection == padrect {
                handler?()
                return
            }
            // Set the scroll targets so that padRect's bottom is fully within the frame, but scroll
            // by as little as needed to bring it in frame.
            let topTarget = padrect.origin.y + padrect.height + self.scrollView.contentOffset.y - self.frame.height
            // Keep the target so that it doesn't scroll the content above the bottom.
            let bottomTarget = self.scrollView.contentSize.height - self.frame.height
            let target = min(bottomTarget, max(0, topTarget))
            let scrollPoint = CGPoint(x: 0, y: target)
            self.scrollView.setContentOffset(scrollPoint, animated: true)
            handler?()
        }
    }
    
    //MARK: Undo/redo
    
    /// Invoke the undo function from the undo button, same as occurs with Command-S.
    ///
    /// Note that this operation interleaves the browser-native undo (e.g., undoing typing)
    /// with the _undoOperation implemented in markup.js.
    public func undo(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.undo()") { result, error in handler?() }
    }
    
    /// Invoke the undo function from the undo button, same as occurs with Command-Shift-S.
    ///
    /// Note that this operation interleaves the browser-native redo (e.g., redoing typing)
    /// with the _redoOperation implemented in markup.js.
    public func redo(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.redo()") { result, error in handler?() }
    }
    
    //MARK: Table editing
    
    public func nextCell(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.nextCell()") { result, error in handler?() }
    }
    
    public func prevCell(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.prevCell()") { result, error in handler?() }
    }
    
    public func insertTable(rows: Int, cols: Int, handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.insertTable(\(rows), \(cols))") { result, error in handler?() }
    }
    
    public func addRow(_ direction: TableDirection, handler: (()->Void)? = nil) {
        switch direction {
        case .before:
            evaluateJavaScript("MU.addRow('BEFORE')") { result, error in handler?() }
        case .after:
            evaluateJavaScript("MU.addRow('AFTER')") { result, error in handler?() }
        }
    }
    
    public func deleteRow(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.deleteRow()") { result, error in handler?() }
    }
    
    public func addCol(_ direction: TableDirection, handler: (()->Void)? = nil) {
        switch direction {
        case .before:
            evaluateJavaScript("MU.addCol('BEFORE')") { result, error in handler?() }
        case .after:
            evaluateJavaScript("MU.addCol('AFTER')") { result, error in handler?() }
        }
    }
    
    public func deleteCol(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.deleteCol()") { result, error in handler?() }
    }
    
    public func addHeader(colspan: Bool = true, handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.addHeader(\(colspan))") { result, error in handler?() }
    }
    
    public func deleteTable(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.deleteTable()") { result, error in handler?() }
    }
    
    public func borderTable(_ border: TableBorder, handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.borderTable(\"\(border)\")")  { result, error in handler?() }
    }
    
    //MARK: Image editing
    
    public func modifyImage(src: String?, alt: String?, handler: (()->Void)?) {
        // If src is nil, then no arguments are passed and the image will be removed
        // Otherwise, the src and alt will be applied to the selected image
        var args = ""
        if let src = src {
            args += "'\(src)'"
            if let alt = alt {
                args += ", '\(alt)'"
            } else {
                args += ", null"
            }
        }
        evaluateJavaScript("MU.modifyImage(\(args))") { result, error in
            handler?()
        }
    }
    
    //MARK: Paste
    
    /// Return the Pasteable type based on the types found in the UIPasteboard.general.
    ///
    /// The order is important, since it identifies what will be pasted, and multiple of these
    /// pasteboard types may be included. Thus, the ordering translates to:
    ///
    /// 1. Paste a local image from the MarkupEditor if present.
    /// 2. Paste an image copied from an external source/app if present.
    /// 3. Paste an image that exists at a URL if present.
    /// 4. Paste html if present, which might be pasted as text or html depending on choice.
    /// 5. Paste text if present.
    ///
    /// When we copy from the MarkupEditor itself, we populate both the "markup.image" of the
    /// pasteboard as well as the "image". This lets us paste the image to an external app,
    /// where it will show up full size. However, if we have "markup.image" populated, then
    /// we prioritize it for pasting, because it retains the sizing of the original.
    public func pasteableType() -> PasteableType? {
        let pasteboard = UIPasteboard.general
        if pasteboard.contains(pasteboardTypes: ["markup.image"]) {
            return .LocalImage
        } else if pasteboard.image != nil {
            // We have copied an image into the pasteboard
            return .ExternalImage
        } else if pasteboard.url != nil {
            // We have a url which might be an image we can display or not
            return .Url
        } else if pasteboard.contains(pasteboardTypes: ["public.html"]) {
            // We have HTML, which we will have to sanitize before pasting
            return .Html
        } else if pasteboard.contains(pasteboardTypes: ["public.rtf"]) {
            return .Rtf
        } else if pasteboard.hasStrings {
            // We have a string that we can paste
            return .Text
        }
        return nil
    }
    
    public func pasteText(_ text: String?, handler: (()->Void)? = nil) {
        guard let text = text, !pastedAsync else { return }
        pastedAsync = true
        evaluateJavaScript("MU.pasteText('\(text.escaped)')") { result, error in
            self.pastedAsync = false
            handler?()
        }
    }
    
    public func pasteHtml(_ html: String?, handler: (()->Void)? = nil) {
        guard let html = html, !pastedAsync else { return }
        pastedAsync = true
        evaluateJavaScript("MU.pasteHTML('\(html.escaped)')") { result, error in
            self.pastedAsync = false
            handler?()
        }
    }
    
    public func pasteImage(_ image: UIImage?, handler: (()->Void)? = nil) {
        guard let image = image, let contents = image.pngData(), !pastedAsync else { return }
        // Make a new unique ID for the image to save in the cacheUrl directory
        pastedAsync = true
        var path = "\(UUID().uuidString).png"
        if let resourcesUrl {
            path = resourcesUrl.appendingPathComponent(path).relativePath
        }
        let cachedImageUrl = URL(fileURLWithPath: path, relativeTo: cacheUrl())
        do {
            if FileManager.default.fileExists(atPath: path) {
                // Update an existing data file (Which should never happen!)
                try contents.write(to: cachedImageUrl)
            } else {
                // Create a new data file
                FileManager.default.createFile(atPath: cachedImageUrl.path, contents: contents, attributes: nil)
            }
            insertImage(src: path, alt: nil) {
                self.pastedAsync = false
                handler?()
            }
        } catch let error {
            Logger.webview.error("Error inserting local image: \(error.localizedDescription)")
            handler?()
        }
    }
    
    //MARK: Formatting
    
    @objc public func bold() {
        bold(handler: nil)
    }
    
    public func bold(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.toggleBold()") { result, error in
            handler?()
        }
    }
    
    @objc public func italic() {
        italic(handler: nil)
    }
    
    public func italic(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.toggleItalic()") { result, error in
            handler?()
        }
    }
    
    @objc public func underline() {
        underline(handler: nil)
    }
    
    public func underline(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.toggleUnderline()") { result, error in
            handler?()
        }
    }
    
    @objc public func code() {
        code(handler: nil)
    }
    
    public func code(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.toggleCode()") { result, error in
            handler?()
        }
    }

    @objc public func strike() {
        strike(handler: nil)
    }
    
    public func strike(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.toggleStrike()") { result, error in
            handler?()
        }
    }
    
    @objc public func subscriptText() {
        subscriptText(handler: nil)
    }
    
    public func subscriptText(handler: (()->Void)? = nil) {      // "superscript" is a keyword
        evaluateJavaScript("MU.toggleSubscript()") { result, error in
            handler?()
        }
    }
    
    @objc public func superscript() {
        superscript(handler: nil)
    }
    
    public func superscript(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.toggleSuperscript()") { result, error in
            handler?()
        }
    }
    
    //MARK: Selection state
    
    /// Get the selectionState async and execute a handler with it.
    ///
    /// Note we keep a local copy up-to-date so we can use it for handling actions coming in from
    /// the MarkupMenu and hot-keys. Calls to getSelectionState here only affect the locally cached
    /// selectionState, not the MarkupEditor.selectionState that is reflected in the MarkupToolbar.
    public func getSelectionState(handler: ((SelectionState)->Void)? = nil) {
        evaluateJavaScript("MU.getSelectionState()") { result, error in
            guard
                error == nil,
                let stateString = result as? String,
                !stateString.isEmpty,
                let data = stateString.data(using: .utf8) else {
                self.selectionState.reset(from: SelectionState())
                handler?(self.selectionState)
                return
            }
            var newSelectionState: SelectionState
            do {
                let stateDictionary = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
                newSelectionState = self.selectionState(from: stateDictionary)
            } catch let error {
                Logger.webview.error("Error decoding selectionState data: \(error.localizedDescription)")
                newSelectionState = SelectionState()
            }
            self.selectionState.reset(from: newSelectionState)
            handler?(newSelectionState)
        }
    }
    
    private func selectionState(from stateDictionary: [String : Any]?) -> SelectionState {
        let selectionState = SelectionState()
        guard let stateDictionary = stateDictionary else {
            Logger.webview.error("State decoded from JSON was nil")
            return selectionState
        }
        // Validity (i.e., document.getSelection().rangeCount > 0
        selectionState.valid = stateDictionary["valid"] as? Bool ?? false
        // The contenteditable div ID or the enclosing DIV id if not contenteditable
        selectionState.divid = stateDictionary["divid"] as? String
        // Selected text
        if let selectedText = stateDictionary["selection"] as? String {
            selectionState.selection = selectedText.isEmpty ? nil : selectedText
            selectionState.selrect = rectFromDict(stateDictionary["selrect"] as? [String : CGFloat])
        } else {
            selectionState.selection = nil
            selectionState.selrect = nil
        }
        // Links
        selectionState.href = stateDictionary["href"] as? String
        selectionState.link = stateDictionary["link"] as? String
        // Images
        selectionState.src = stateDictionary["src"] as? String
        selectionState.alt = stateDictionary["alt"] as? String
        selectionState.width = stateDictionary["width"] as? Int
        selectionState.height = stateDictionary["height"] as? Int
        selectionState.scale = stateDictionary["scale"] as? Int
        // Tables
        selectionState.table = stateDictionary["table"] as? Bool ?? false
        selectionState.thead = stateDictionary["thead"] as? Bool ?? false
        selectionState.tbody = stateDictionary["tbody"] as? Bool ?? false
        selectionState.header = stateDictionary["header"] as? Bool ?? false
        selectionState.colspan = stateDictionary["colspan"] as? Bool ?? false
        selectionState.rows = stateDictionary["rows"] as? Int ?? 0
        selectionState.cols = stateDictionary["cols"] as? Int ?? 0
        selectionState.row = stateDictionary["row"] as? Int ?? 0
        selectionState.col = stateDictionary["col"] as? Int ?? 0
        if let rawValue = stateDictionary["border"] as? String {
            selectionState.border = TableBorder(rawValue: rawValue) ?? .cell
        } else {
            selectionState.border = .cell
        }
        // Styles
        if let tag = stateDictionary["style"] as? String {
            selectionState.style = StyleContext.with(tag: tag)
        } else {
            selectionState.style = StyleContext.Undefined
        }
        if let tag = stateDictionary["list"] as? String {
            selectionState.list = ListContext.with(tag: tag)
        } else {
            selectionState.list = ListContext.Undefined
        }
        selectionState.li = stateDictionary["li"] as? Bool ?? false
        selectionState.quote = stateDictionary["quote"] as? Bool ?? false
        // Formats
        selectionState.bold = stateDictionary["bold"] as? Bool ?? false
        selectionState.italic = stateDictionary["italic"] as? Bool ?? false
        selectionState.underline = stateDictionary["underline"] as? Bool ?? false
        selectionState.strike = stateDictionary["strike"] as? Bool ?? false
        selectionState.sub = stateDictionary["sub"] as? Bool ?? false
        selectionState.sup = stateDictionary["sup"] as? Bool ?? false
        selectionState.code = stateDictionary["code"] as? Bool ?? false
        return selectionState
    }
    
    public func rectFromDict(_ rectDict: [String : CGFloat]?) -> CGRect? {
        guard let rectDict = rectDict else { return nil }
        guard
            let x = rectDict["x"],
            let y = rectDict["y"],
            let width = rectDict["width"],
            let height = rectDict["height"] else { return nil }
            return CGRect(origin: CGPoint(x: x, y: y), size: CGSize(width: width, height: height))
    }
    
    //MARK: Styling
    
    @objc public func pStyle(sender: UICommand) {
        replaceStyle(selectionState.style, with: .P)
    }
    
    @objc public func h1Style() {
        replaceStyle(selectionState.style, with: .H1)
    }
    
    @objc public func h2Style() {
        replaceStyle(selectionState.style, with: .H2)
    }
    
    @objc public func h3Style() {
        replaceStyle(selectionState.style, with: .H3)
    }
    
    @objc public func h4Style() {
        replaceStyle(selectionState.style, with: .H4)
    }
    
    @objc public func h5Style() {
        replaceStyle(selectionState.style, with: .H5)
    }
    
    @objc public func h6Style() {
        replaceStyle(selectionState.style, with: .H6)
    }
    
    /// Replace the oldStyle of the selection with the newStyle (e.g., from <p> to <h3>)
    ///
    /// A null value of oldStyle results in an unstyled element being styled (which really should never happen)
    public func replaceStyle(_ oldStyle: StyleContext?, with newStyle: StyleContext, handler: (()->Void)? = nil) {
        var replaceCall = "MU.replaceStyle("
        if let oldStyle = oldStyle {
            replaceCall += "'\(oldStyle)', '\(newStyle)')"
        } else {
            replaceCall += "null, '\(newStyle)')"
        }
        evaluateJavaScript(replaceCall) { result, error in
            handler?()
        }
    }
    
    /// Indent from the menu or hotkey
    @objc public func indent() {
        indent(handler: nil)
    }

    /// Indent the selection based on the context.
    ///
    /// If in a list, move list item to the next nested level if appropriate.
    /// Otherwise, increase the quote level by inserting a new blockquote.
    public func indent(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.indent()") { result, error in
            handler?()
        }
    }
    
    /// Outdent from the menu or hotkey
    @objc public func outdent() {
        outdent(handler: nil)
    }

    /// Outdent the selection based on the context.
    ///
    /// If in a list, move list item to the previous nested level if appropriate.
    /// Otherwise, decrease the quote level by removing a blockquote if one exists.
    public func outdent(handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.outdent()") { result, error in
            handler?()
        }
    }
    
    @objc public func bullets() {
        toggleListItem(type: .UL)
    }
    
    @objc public func numbers() {
        toggleListItem(type: .OL)
    }
    
    /// Switch between ordered and unordered list styles.
    public func toggleListItem(type: ListContext, handler: (()->Void)? = nil) {
        evaluateJavaScript("MU.toggleListItem('\(type.tag)')") { result, error in
            handler?()
        }
    }
    
}

//MARK: UIResponderStandardEditActions overrides

extension MarkupWKWebView {
    
    /// Replace standard action with the MarkupWKWebView implementation.
    public override func toggleBoldface(_ sender: Any?) {
        bold()
    }
    
    /// Replace standard action with the MarkupWKWebView implementation.
    public override func toggleItalics(_ sender: Any?) {
        italic()
    }
    
    /// Replace standard action with the MarkupWKWebView implementation.
    public override func toggleUnderline(_ sender: Any?) {
        underline()
    }
    
    /// Replace standard action with the MarkupWKWebView implementation.
    public override func increaseSize(_ sender: Any?) {
        // Do nothing
    }
    
    /// Replace standard action with the MarkupWKWebView implementation.
    public override func decreaseSize(_ sender: Any?) {
        // Do nothing
    }
    
    @objc public override func copy(_ sender: Any?) {
        if selectionState.isInImage {
            copyImage(src: selectionState.src!, alt: selectionState.alt, width: selectionState.width, height: selectionState.height)
        } else {
            super.copy(sender)
        }
    }
    
    @objc public override func cut(_ sender: Any?) {
        if selectionState.isInImage {
            evaluateJavaScript("MU.cutImage()") { result, error in }
        } else {
            super.cut(sender)
        }
    }
    
    /// Invoke the paste method in the editor directly, passing the clipboard contents
    /// that would otherwise be obtained via the JavaScript event.
    ///
    /// Customize the type of paste operation on the JavaScript side based on the type
    /// of data available in UIPasteboard.general.
    public override func paste(_ sender: Any?) {
        guard let pasteableType = pasteableType() else { return }
        let pasteboard = UIPasteboard.general
        switch pasteableType {
        case .Text:
            pasteText(pasteboard.string)
        case .Html:
            if let data = pasteboard.data(forPasteboardType: "public.html") {
                pasteHtml(String(data: data, encoding: .utf8))
            }
        case .Rtf:
            if let rtfData = pasteboard.data(forPasteboardType: "public.rtf") {
                do {
                    let attrString = try NSAttributedString(
                        data: rtfData,
                        options: [.documentType: NSAttributedString.DocumentType.rtf],
                        documentAttributes: nil)
                    let htmlData = try attrString.data(
                        from: NSRange(location: 0, length: attrString.length),
                        documentAttributes: [.documentType : NSAttributedString.DocumentType.html])
                    let html = String(data: htmlData, encoding: .utf8)
                    pasteHtml(html)
                } catch let error {
                    Logger.webview.error("Error getting html from rtf: \(error.localizedDescription)")
                }
            }
        case .ExternalImage:
            pasteImage(pasteboard.image)
        case .LocalImage:
            // Note that a LocalImage is just HTML; i.e., the html of the
            // image element we copied in the MarkupEditor, that also specifies
            // the dimensions.
            if let data = pasteboard.data(forPasteboardType: "markup.image") {
                pasteHtml(String(data: data, encoding: .utf8))
            }
        case .Url:
            pasteUrl(url: pasteboard.url)
        }
    }
    
    /// Paste the url as an img or as a link depending on its content.
    ///
    /// This method is public so it can be used from tests and the tests can ensure the
    /// logic does the right thing for various URL forms.
    public func pasteUrl(url: URL?, handler: (()->Void)? = nil) {
        guard let url else {
            handler?()
            return
        }
        let urlString = url.absoluteString
        // StartModalInput saves the selection before inserting and is "normally"
        // done before opening the LinkViewController or ImageViewController.
        // However, since pasteUrl is invoked directly when using paste, without
        // the intervening dialog, we need to do it here.
        startModalInput {
            if self.isImageUrl(url: url) {
                self.insertImage(src: urlString, alt: nil) {
                    handler?()
                }
            } else {
                self.insertLink(urlString) {
                    handler?()
                }
            }
        }
    }
    
    /// Return true if the url points to an image or movie that can be inserted into the document
    private func isImageUrl(url: URL?) -> Bool {
        guard let url else { return false }
        if url.isFileURL {
            return isLocalImage(url: url)
        } else {
            return isRemoteImage(url: url)
        }
    }
    
    /// Return true if the url points to an image in a local file.
    ///
    /// We can use `resourceValues(forKeys:)` on local files, whereas we have to infer whether the file is an image
    /// from the extension on non-local files.
    private func isLocalImage(url: URL) -> Bool {
        do {
            guard let typeID = try url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier else { return false }
            guard let supertypes = UTType(typeID)?.supertypes else { return false }
            return supertypes.contains(.image) || supertypes.contains(.movie)
        } catch {
            return false
        }
    }
    
    /// Return true if the url points to a remote image file, based only on the file extension.
    private func isRemoteImage(url: URL) -> Bool {
        guard let utType = UTType(tag: url.pathExtension, tagClass: .filenameExtension, conformingTo: nil) else { return false }
        return utType.conforms(to: .image) || utType.conforms(to: .movie)
    }
    
    /// Paste the HTML or text only from the clipboard, but in a minimal "unformatted" manner
    public override func pasteAndMatchStyle(_ sender: Any?) {
        guard let pasteableType = pasteableType() else { return }
        let pasteboard = UIPasteboard.general
        switch pasteableType {
        case .Text, .Rtf:
            pasteText(pasteboard.string)
        case .Html:
            if let data = pasteboard.data(forPasteboardType: "public.html") {
                pasteText(String(data: data, encoding: .utf8))
            }
        default:
            break
        }
    }
    
}

//MARK: Drop support

extension MarkupWKWebView: UIDropInteractionDelegate {
    
    /// Delegate the handling decision for DropInteraction to the markupDelegate.
    public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        markupDelegate?.markupDropInteraction(interaction, canHandle: session) ?? false
    }
    
    /// Delegate the type of DropProposal to the markupDelegate, or return .copy by default.
    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        markupDelegate?.markupDropInteraction(interaction, sessionDidUpdate: session) ?? UIDropProposal(operation: .copy)
    }
    
    /// Delegate the actual drop action to the markupDelegate.
    public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        markupDelegate?.markupDropInteraction(interaction, performDrop: session)
    }
    
}

//MARK: Popover support

extension MarkupWKWebView: UIPopoverPresentationControllerDelegate {
    
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        .none
    }
}
