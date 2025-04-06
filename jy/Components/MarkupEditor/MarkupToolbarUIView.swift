//
//  MarkupToolbarUIView.swift
//  MarkupEditor
//
//  Created by Steven Harris on 8/13/22.
//

import SwiftUI
import Combine

/// MarkupToolbarUIView是一个可以在UIKit应用中使用的UIView，用于包含SwiftUI的MarkupToolbar。
///
/// MarkupEditorUIView将MarkupToolbarUIView和MarkupWKWebView组合在一个UIView中，
/// 这样更容易将它们一起展示。如果需要，你也可以独立使用这两个视图。
/// 例如，当你有多个MarkupWKWebView共享一个MarkupToolbarUIView时，你就需要这样做。
///
/// 即使你正在构建一个"纯"SwiftUI应用，你仍然需要MarkupToolbarUIView，因为
/// 如果要在MarkupWKWebView的inputAccessoryView中使用MarkupToolbar，这是必需的。
///
/// 默认情况下，无论你使用SwiftUI还是UIKit，MarkupToolbarUIView都被用作MarkupWKWebView中的inputAccessoryView。
/// 在这种情况下，MarkupWKWebView使用这里的静态方法`inputAccessory(markupDelegate:)`来获取一个正确配置的MarkupToolbarUIView。
/// inputAccessoryView版本的MarkupToolbarUIView的默认配置*仅*包含CorrectionToolbar和隐藏键盘的功能。
/// 这是因为默认的MarkupToolbar不包含撤销/重做按钮（即CorrectionToolbar），而在MacCatalyst或有物理键盘的设备上，
/// 撤销/重做可以通过菜单和快捷键使用，但在没有物理键盘的设备上则不行。
///
public class MarkupToolbarUIView: UIView {
    // 标记工具栏
    public var markupToolbar: MarkupToolbar!
    // 标记代理
    private var markupDelegate: MarkupDelegate?
    
    // 重写固有内容大小
    public override var intrinsicContentSize: CGSize {
        CGSize(width: frame.width, height: MarkupEditor.toolbarStyle.height())
    }
    
    // 重写初始化方法
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // 自定义初始化方法
    public init(_ style: ToolbarStyle.Style? = nil, contents: ToolbarContents? = nil, markupDelegate: MarkupDelegate? = nil, withKeyboardButton: Bool = false) {
        super.init(frame: CGRect.zero)
        self.markupDelegate = markupDelegate
        // 设置自动调整掩码，用于intrinsicContentSize的变化
        autoresizingMask = .flexibleHeight
        markupToolbar = MarkupToolbar(style, contents: contents, markupDelegate: markupDelegate, withKeyboardButton: withKeyboardButton)
        let markupToolbarHC = UIHostingController(rootView: markupToolbar)
        addSubview(markupToolbarHC.view)
        markupToolbarHC.view.translatesAutoresizingMaskIntoConstraints = false
        
        // 根据工具栏位置设置约束
        if MarkupEditor.toolbarLocation == .top || MarkupEditor.toolbarLocation == .keyboard {
            NSLayoutConstraint.activate([
                markupToolbarHC.view.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                markupToolbarHC.view.heightAnchor.constraint(equalToConstant: MarkupEditor.toolbarStyle.height()),
                markupToolbarHC.view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
                markupToolbarHC.view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                markupToolbarHC.view.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                markupToolbarHC.view.heightAnchor.constraint(equalToConstant: MarkupEditor.toolbarStyle.height()),
                markupToolbarHC.view.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
                markupToolbarHC.view.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
            ])
        }
    }
    
    // 必需的初始化方法
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 创建托管工具栏
    public func makeManaged() -> MarkupToolbarUIView {
        markupToolbar = markupToolbar.makeManaged()
        return self
    }
    
    /// 返回一个紧凑的MarkupToolbarUIView，包含当前共享的ToolbarContents，并确保存在键盘按钮
    public static func inputAccessory(markupDelegate: MarkupDelegate? = nil) -> MarkupToolbarUIView {
        let contents = ToolbarContents.from(ToolbarContents.shared)
        let toolbar = MarkupToolbarUIView(.compact, contents: contents, markupDelegate: markupDelegate, withKeyboardButton: true).makeManaged()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        return toolbar
    }
    
}
