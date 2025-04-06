import SwiftUI
import UIKit

/// 自适应高度的输入框组件
/// - 支持自动调整高度
/// - 支持占位文本
/// - 支持最大高度限制
/// - 支持自定义样式
struct AdaptiveTextView: UIViewRepresentable {
    // MARK: - Properties
    
    /// 绑定的文本内容
    @Binding var text: String
    /// 占位文本
    let placeholder: String
    /// 字体
    let font: UIFont
    /// 最小高度（默认为单行高度）
    let minHeight: CGFloat
    /// 最大高度（如果为nil则不限制）
    let maxHeight: CGFloat?
    /// 固定宽度
    let width: CGFloat
    /// 文本变化回调
    var onTextChange: ((String) -> Void)?
    /// 高度变化回调
    var onHeightChange: ((CGFloat) -> Void)?
    /// 发送回调
    var onSend: (() -> Void)?
    /// 文本是否超过两行高度的回调
    var onTextHeightStateChange: ((Bool, Int) -> Void)?
    
    // MARK: - 初始化
    
    init(text: Binding<String>,
         placeholder: String = "输入文本",
         font: UIFont = .systemFont(ofSize: 16, weight: .regular),
         minHeight: CGFloat = 36,
         maxHeight: CGFloat? = nil,
         width: CGFloat = 180,
         onTextChange: ((String) -> Void)? = nil,
         onHeightChange: ((CGFloat) -> Void)? = nil,
         onSend: (() -> Void)? = nil,
         onTextHeightStateChange: ((Bool, Int) -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.font = font
        self.minHeight = minHeight
        self.maxHeight = maxHeight
        self.width = width
        self.onTextChange = onTextChange
        self.onHeightChange = onHeightChange
        self.onSend = onSend
        self.onTextHeightStateChange = onTextHeightStateChange
    }
    
    // MARK: - UIViewRepresentable
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        // 使用TextKit 2初始化
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: width, height: .greatestFiniteMagnitude))
        let textStorage = NSTextStorage()
        
        // 配置文本容器
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = false
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // 创建文本视图
        let textView = UITextView(frame: .zero, textContainer: textContainer)
        textView.delegate = context.coordinator
        
        // 配置基本属性
        textView.font = font
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.showsVerticalScrollIndicator = false
        textView.isScrollEnabled = true
        textView.textAlignment = .natural
        textView.returnKeyType = .send
        textView.alwaysBounceVertical = false
        
        // 设置约束
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        // 设置文本和颜色
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = .placeholderText
        } else {
            textView.text = text
            textView.textColor = .label
        }
        
        // 计算并设置初始高度
        let initialHeight = calculateInitialHeight(textView)
        
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(equalToConstant: width),
            textView.heightAnchor.constraint(equalToConstant: initialHeight)
        ])
        
        // 异步回调初始高度
        DispatchQueue.main.async {
            self.onHeightChange?(initialHeight)
        }
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        // 更新文本内容（避免光标位置重置）
        if textView.text != text {
            let shouldUpdateHeight = !textView.isFirstResponder || textView.text.isEmpty != text.isEmpty
            
            // 根据文本是否为空来设置显示内容和颜色
            if !textView.isFirstResponder && text.isEmpty {
                textView.text = placeholder
                textView.textColor = .placeholderText
            } else {
                textView.text = text
                textView.textColor = .label
            }
            
            // 将高度更新放到主队列的下一个运行循环中执行
            if shouldUpdateHeight {
                DispatchQueue.main.async {
                    self.updateTextViewHeight(textView)
                }
            }
        }
    }
    
    /// 计算初始高度
    private func calculateInitialHeight(_ textView: UITextView) -> CGFloat {
        let size = CGSize(width: width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        var initialHeight = max(estimatedSize.height, minHeight)
        if let maxHeight = maxHeight {
            initialHeight = min(initialHeight, maxHeight)
        }
        
        // 考虑文本容器内边距
        return initialHeight
    }
    
    /// 计算并更新文本视图高度
    private func updateTextViewHeight(_ textView: UITextView) {
        // 使用统一的布局计算方法
        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer
        
        // 确保布局已更新
        layoutManager.ensureLayout(for: textContainer)
        
        // 获取文本区域
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
        // 计算总高度（文本高度 + 内边距）
        let totalHeight = boundingRect.height + textView.textContainerInset.top + textView.textContainerInset.bottom
        
        // 应用最小和最大高度限制
        var newHeight = max(totalHeight, minHeight)
        if let maxHeight = maxHeight {
            newHeight = min(newHeight, maxHeight)
        }
        
        // 检查高度是否发生变化（使用更精确的比较）
        let currentHeight = textView.frame.height
        guard abs(currentHeight - newHeight) > 0.01 else { return }
        
        // 使用CATransaction避免动画冲突
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        // 更新高度约束
        textView.constraints.forEach { constraint in
            if constraint.firstAttribute == .height {
                constraint.isActive = false
            }
        }
        
        // 添加新的高度约束
        let heightConstraint = textView.heightAnchor.constraint(equalToConstant: newHeight)
        heightConstraint.priority = .required
        heightConstraint.isActive = true
        
        // 立即应用布局更新
        textView.superview?.layoutIfNeeded()
        
        CATransaction.commit()
        
        // 使用优化后的动画参数
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.2,
            options: [.allowUserInteraction, .beginFromCurrentState]
        ) {
            textView.superview?.layoutIfNeeded()
        } completion: { _ in
            self.onHeightChange?(newHeight)
        }
    }
    
    private func isTextMoreThanTwoLines(_ textView: UITextView) -> (Bool, Int) {
        // 使用统一的布局计算方法
        let layoutManager = textView.layoutManager
        let textContainer = textView.textContainer
        let textContainerInset = textView.textContainerInset
        
        // 确保布局已更新
        layoutManager.ensureLayout(for: textContainer)
        
        // 获取文本区域
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        let boundingRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer)
        
        // 计算总高度（文本高度 + 内边距）
        let totalHeight = boundingRect.height + textContainerInset.top + textContainerInset.bottom
        
        // 计算单行高度（使用当前字体）
        let lineHeight = textView.font?.lineHeight ?? 0
        
        // 计算行数（减去内边距后除以行高，向上取整）
        let lineCount = Int(ceil((totalHeight - textContainerInset.top - textContainerInset.bottom) / lineHeight))
        
        // 判断是否超过一行
        return (totalHeight > (lineHeight + textContainerInset.top + textContainerInset.bottom), lineCount)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: AdaptiveTextView
        
        init(_ parent: AdaptiveTextView) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = .label
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = .placeholderText
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // 更新绑定的文本
            parent.text = textView.text
            parent.onTextChange?(textView.text)
            
            // 更新高度
            parent.updateTextViewHeight(textView)
            
            // 检查并回调文本高度状态
            let (isMoreThanTwoLines, lineCount) = parent.isTextMoreThanTwoLines(textView)
            parent.onTextHeightStateChange?(isMoreThanTwoLines, lineCount)
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            // 处理回车键
            if text == "\n" {
                // 触发发送回调
                parent.onSend?()
                return false // 不插入换行符
            }
            return true
        }
    }
}

// MARK: - 预览

#Preview {
    struct PreviewView: View {
        @State private var text = ""
        @State private var height: CGFloat = 36
        
        var body: some View {
            VStack {
                Text("当前高度: \(Int(height))")
                    .font(.caption)
                
                AdaptiveTextView(
                    text: $text,
                    placeholder: "请输入内容...",
                    minHeight: 36,
                    maxHeight: 120,
                    width: UIScreen.main.bounds.width - 32,
                    onHeightChange: { height = $0 }
                )
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .padding()
        }
    }
    
    return PreviewView()
}
