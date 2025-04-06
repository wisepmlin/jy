//
//  MarkupWKWebViewRepresentable.swift
//  MarkupEditor
//
//  Created by Steven Harris on 8/18/22.
//

import SwiftUI
import WebKit

/// MarkupWKWebViewRepresentable 是一个基于 UIKit 的 MarkupWKWebView 实例的 UIViewRepresentable
/// 使得 MarkupWKWebView 可以在 SwiftUI 中使用
///
/// MarkupWKWebViewRepresentable 被 MarkupEditorView 使用，但它是一个公共类，以便开发者可以
/// 用它构建自己的 SwiftUI 视图
///
/// Coordinator 将作为 WKScriptMessageHandler 并处理从 markup.js 中通过
/// window.webkit.messageHandlers.markup.postMessage(message) 发来的回调
///
/// 查看 updateView 中的说明以更好地理解何时调用 updateView。简而言之：将 html 保存在
/// MarkupEditorView 外部的某个状态中，并在初始化时传入该状态的绑定。
public struct MarkupWKWebViewRepresentable: UIViewRepresentable {
    public typealias Coordinator = MarkupCoordinator
    // 在 MarkupWKWebView 中显示的初始 HTML 内容
    public var markupDelegate: MarkupDelegate?
    private var wkNavigationDelegate: WKNavigationDelegate?
    private var wkUIDelegate: WKUIDelegate?
    private var userScripts: [String]?
    private var markupConfiguration: MarkupWKWebViewConfiguration?
    private var resourcesUrl: URL?
    private var id: String?
    @Binding private var html: String
    private var selectAfterLoad: Bool
    private var placeholder: String?
    
    /// 使用绑定到外部持有的 String 的 html 内容进行初始化（因此可以更改）
    ///
    /// 当 html 在外部更新时，将触发 updateUIView，从而设置 webView 的 html
    public init(
        markupDelegate: MarkupDelegate? = nil,
        wkNavigationDelegate: WKNavigationDelegate? = nil,
        wkUIDelegate: WKUIDelegate? = nil,
        userScripts: [String]? = nil,
        configuration: MarkupWKWebViewConfiguration? = nil,
        html: Binding<String>? = nil,
        placeholder: String? = nil,
        selectAfterLoad: Bool = true,
        resourcesUrl: URL? = nil,
        id: String? = nil) {
            self.markupDelegate = markupDelegate
            self.wkNavigationDelegate = wkNavigationDelegate
            self.wkUIDelegate = wkUIDelegate
            self.userScripts = userScripts
            self.markupConfiguration = configuration
            _html = html ?? .constant("")
            self.placeholder = placeholder
            self.selectAfterLoad = selectAfterLoad
            self.resourcesUrl = resourcesUrl
            self.id = id
        }
    
    public func makeCoordinator() -> Coordinator {
        return Coordinator(markupDelegate: markupDelegate)
    }

    /// 返回 MarkupWKWebView
    ///
    /// WKWebView 的 `isInspectable` 属性在 iOS 16.4 中添加。但是，代码在 Ventura（MacOS 10.13）之前的
    /// MacOS 版本中无法编译。仅在运行时检查 iOS 16.4 对于 Monterey（MacOS 12.6）上的 macCatalyst 构建
    /// 不起作用，因为 `#available(iOS 16.4, *)` 返回 `true`。我能找到的唯一方法是检查 `compiler(>=5.8)`
    /// 以避免在 Monterey 上编译 `webView.isInspectable = true`。然后在 Ventura+ 上，我们仍然需要检查
    /// `#available(iOS 16.4, *)`。现在我们可以在 Ventura+ 上为 iOS 15.5 和 16.4 以及 macCatalyst 16.4
    /// 构建，并且可以在 Monterey 上为 pre-iOS 16.4 版本的 iOS 15.5 构建。这种限制还允许使用较旧 MacOS
    /// 版本的 GitHub actions 工作，即使你在本地使用 Ventura。
    public func makeUIView(context: Context) -> MarkupWKWebView  {
        let webView = MarkupWKWebView(html: html, placeholder: placeholder, selectAfterLoad: selectAfterLoad, resourcesUrl: resourcesUrl, id: id, markupDelegate: markupDelegate, configuration: markupConfiguration)
        // 默认情况下，除非在 MarkupEditorUIView 初始化期间设置了 navigationDelegate，
        // 否则 webView 不会响应任何导航事件
        webView.navigationDelegate = wkNavigationDelegate
        webView.backgroundColor = UIColor(named: "car_bg")
        webView.uiDelegate = wkUIDelegate
        // coordinator 作为 WKScriptMessageHandler，将接收来自 markup.js 的回调，
        // 这些回调使用 window.webkit.messageHandlers.markup.postMessage(<message>)
        let coordinator = context.coordinator
        webView.configuration.userContentController.add(coordinator, name: "markup")
#if compiler(>=5.8)
        if #available(iOS 16.4, *) {
            webView.isInspectable = MarkupEditor.isInspectable
        }
#endif
        coordinator.webView = webView
        webView.userScripts = userScripts
        return webView
    }

    /// 当 html 更改时显式调用
    ///
    /// 当 init 中的 boundContent 为 nil 时，updateUIView 将在视图出现时以及视图进入后台或返回前台时
    /// 被多次调用。这似乎是因为没有人在外部持有 html 绑定，而是在 init 中使用 .constant 即时创建的副作用。
    /// 如果在调用者中使用 .constant 而没有正确保持 html 状态，也会发生相同的过度调用 updateView 的情况。
    /// 底线是，对于除了快速演示之外的任何情况，你都应该在某个地方正确保持 html 状态，然后将该状态的绑定
    /// 传递给 init。
    public func updateUIView(_ webView: MarkupWKWebView, context: Context) {
        //Logger.webview.debug("MarkupWKWebViewRepresentable updateUIView")
        webView.setHtmlIfChanged(html)
    }
    
    /// 通过停止加载、移除 userContentController 并让 markupDelegate 知道要拆除视图来拆除 MarkupWKWebView
    ///
    /// 注意：这在 UIKit 应用程序中不会发生，因为它们不使用 MarkupEditorView。用户需要手动挂钩到
    /// UIViewController 生命周期来完成这个操作。
    public static func dismantleUIView(_ uiView: MarkupWKWebView, coordinator: MarkupCoordinator) {
        uiView.stopLoading()
        uiView.configuration.userContentController.removeAllScriptMessageHandlers()
        coordinator.markupDelegate?.markupTeardown(uiView)
    }
    
}
