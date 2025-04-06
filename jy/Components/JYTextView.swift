import SwiftUI
import UIKit

struct JYTextView: UIViewRepresentable {
    @Binding var text: String
    var font: UIFont = .systemFont(ofSize: 16)
    var textColor: UIColor = .label
    var textAlignment: NSTextAlignment = .left
    var isEditable: Bool = false
    var isSelectable: Bool = true
    var lineLimit: Int? = nil
    var onLinkTap: ((URL) -> Void)? = nil
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.isEditable = isEditable
        textView.isSelectable = isSelectable
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        updateUIView(textView, context: context)
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        textView.text = text
        textView.font = font
        textView.textColor = textColor
        textView.textAlignment = textAlignment
        
        if let lineLimit = lineLimit {
            textView.textContainer.maximumNumberOfLines = lineLimit
            textView.textContainer.lineBreakMode = .byTruncatingTail
        } else {
            textView.textContainer.maximumNumberOfLines = 0
        }
        
        // 自适应高度
        let size = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude))
        if textView.frame.size.height != size.height {
            DispatchQueue.main.async {
                textView.frame.size.height = size.height
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: JYTextView
        
        init(_ parent: JYTextView) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
        
        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            if let onLinkTap = parent.onLinkTap {
                onLinkTap(URL)
                return false
            }
            return true
        }
    }
}

// 使用示例
struct JYTextViewExample: View {
    @State private var text = "这是一个支持自定义的文本视图组件，支持设置字体、颜色、对齐方式等属性，并且能够自适应内容高度。\n\n你可以设置是否可编辑、是否可选择文本，以及最大行数限制。同时还支持点击链接的回调处理。"
    
    var body: some View {
        VStack(spacing: 20) {
            // 基本使用
            JYTextView(text: .constant("基本文本显示"))
                .padding()
            
            // 自定义样式
            JYTextView(text: .constant("自定义样式的文本"),
                      font: .boldSystemFont(ofSize: 20),
                      textColor: .systemBlue,
                      textAlignment: .center)
                .padding()
            
            // 可编辑的文本框
            JYTextView(text: $text,
                      isEditable: true,
                      lineLimit: 5)
                .padding()
            
            // 带链接回调
            JYTextView(text: .constant("点击链接：https://example.com"),
                      onLinkTap: { url in
                print("点击链接：\(url)")
            })
                .padding()
        }
    }
}

#Preview {
    JYTextViewExample()
}
