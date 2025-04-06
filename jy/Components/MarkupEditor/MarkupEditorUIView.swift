//
//  MarkupEditorUIView.swift
//  MarkupEditor
//
//  Created by Steven Harris on 8/18/22.
//

import WebKit
import Combine

/// MarkupEditorUIView是一个UIKit视图，包含一个MarkupWKWebView和（可选的）MarkupToolbarUIView。
///
/// 可以使用MarkupEditor.toolbarLocation单独指定工具栏位置。默认情况下，MarkupEditorUIView在所有设备上
/// 都在顶部有一个工具栏。
///
/// 如果在应用程序中有多个MarkupWKWebViews，应该只有一个工具栏。在这种情况下，你可能应该指定
/// MarkupEditor.toolbarLocation = .none，然后直接使用MarkupToolbarUIView。
///
/// 通常，我们不希望WebKit抽象泄漏到MarkupEditor世界中。当实例化MarkupEditorUIView时，
/// 如果需要，你可以选择指定WKUIDelegate和WKNavigationDelegate，它们将被分配给底层的MarkupWKWebView。
public class MarkupEditorUIView: UIView, MarkupDelegate {
    // 工具栏视图
    private var toolbar: MarkupToolbarUIView!
    // 工具栏高度约束
    private var toolbarHeightConstraint: NSLayoutConstraint!
    // Web视图
    private var webView: MarkupWKWebView!
    // MarkupCoordinator处理与MarkupWKWebView的交互
    private var coordinator: MarkupCoordinator!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }

    /// 初始化MarkupEditorUIView
    ///
    /// WKWebView的isInspectable属性在iOS 16.4中添加。但是，代码在Ventura（MacOS 10.13）之前的MacOS版本中
    /// 无法编译。仅在运行时检查iOS 16.4不适用于Monterey（MacOS 12.6）上的macCatalyst构建，因为
    /// `#available(iOS 16.4, *)`返回`true`。我能找到的唯一方法是在Monterey上检查`compiler(>=5.8)`
    /// 以避免编译`webView.isInspectable = true`。然后在Ventura+上，我们仍然需要检查
    /// `#available(iOS 16.4, *)`。现在我们可以在Ventura+上为iOS 15.5和16.4构建，以及
    /// macCatalyst 16.4，我们可以在Monterey上为pre-iOS 16.4版本构建iOS 15.5。这个门控
    /// 还允许使用较旧MacOS版本的GitHub操作工作，即使你在本地使用Ventura。
    public init(
        markupDelegate: MarkupDelegate? = nil,
        wkNavigationDelegate: WKNavigationDelegate? = nil,
        wkUIDelegate: WKUIDelegate? = nil,
        userScripts: [String]? = nil,
        configuration: MarkupWKWebViewConfiguration? = nil,
        html: String?,
        placeholder: String? = nil,
        selectAfterLoad: Bool = true,
        resourcesUrl: URL? = nil,
        id: String? = nil) {
            super.init(frame: CGRect.zero)
            // 初始化Web视图
            webView = MarkupWKWebView(html: html, placeholder: placeholder, selectAfterLoad: selectAfterLoad, resourcesUrl: resourcesUrl, id: "Document", markupDelegate: markupDelegate ?? self, configuration: configuration)
            // coordinator作为WKScriptMessageHandler，将接收来自markup.js的回调
            // 使用window.webkit.messageHandlers.markup.postMessage(<message>)
            coordinator = MarkupCoordinator(markupDelegate: markupDelegate, webView: webView)
            webView.configuration.userContentController.add(coordinator, name: "markup")
            coordinator.webView = webView
#if compiler(>=5.8)
            if #available(iOS 16.4, *) {
                webView.isInspectable = MarkupEditor.isInspectable
            }
#endif
            // 默认情况下，除非在MarkupEditorUIView初始化期间设置navigationDelegate，
            // 否则webView不响应任何导航事件
            webView.navigationDelegate = wkNavigationDelegate
            webView.uiDelegate = wkUIDelegate
            webView.userScripts = userScripts
            webView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(webView)
            
            // 根据工具栏位置设置布局
            if MarkupEditor.toolbarLocation == .top {
                // 顶部工具栏布局设置
                toolbar = MarkupToolbarUIView(markupDelegate: markupDelegate).makeManaged()
                toolbar.translatesAutoresizingMaskIntoConstraints = false
                toolbarHeightConstraint = NSLayoutConstraint(item: toolbar!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: MarkupEditor.toolbarStyle.height())
                addSubview(toolbar)
                NSLayoutConstraint.activate([
                    toolbar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                    toolbarHeightConstraint,
                    toolbar.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
                    toolbar.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
                    webView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: MarkupEditor.toolbarStyle.height()),
                    webView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                    webView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
                    webView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor)
                ])
            } else if MarkupEditor.toolbarLocation == .bottom {
                // 底部工具栏布局设置
                toolbar = MarkupToolbarUIView(markupDelegate: markupDelegate).makeManaged()
                toolbar.translatesAutoresizingMaskIntoConstraints = false
                toolbarHeightConstraint = NSLayoutConstraint(item: toolbar!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: MarkupEditor.toolbarStyle.height())
                addSubview(toolbar)
                NSLayoutConstraint.activate([
                    webView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                    webView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -MarkupEditor.toolbarStyle.height()),
                    webView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
                    webView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
                    toolbar.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                    toolbarHeightConstraint,
                    toolbar.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
                    toolbar.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor)
                ])
            } else {
                // 无工具栏布局设置
                NSLayoutConstraint.activate([
                    webView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
                    webView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
                    webView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
                    webView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor)
                ])
                // 用于需要覆盖inputAccessoryView的场景
                webView.inputAccessoryView = MarkupToolbarUIView.inputAccessory(markupDelegate: markupDelegate)
            }
        }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
