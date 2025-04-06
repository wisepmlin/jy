//
//  WebView.swift
//
//
//  Created by 이웅재(NuPlay) on 2021/07/26.
//  https://github.com/NuPlay/RichText

import SwiftUI
@preconcurrency import WebKit
import SafariServices

// WebView结构体定义
struct WebView {
    @Environment(\.multilineTextAlignment) var alignment
    @Binding var dynamicHeight: CGFloat
    
    let html: String
    let conf: Configuration
    let width: CGFloat
    
    init(width: CGFloat, dynamicHeight: Binding<CGFloat>, html: String, configuration: Configuration) {
        self._dynamicHeight = dynamicHeight
        
        self.html = html
        self.conf = configuration
        self.width = width
    }
}

#if canImport(UIKit)
import UIKit
// iOS平台WebView实现
extension WebView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "notifyCompletion")
        let webview = WKWebView(frame: .zero, configuration: configuration)
        
        webview.scrollView.bounces = false
        webview.navigationDelegate = context.coordinator
        webview.scrollView.isScrollEnabled = false
        
        DispatchQueue.main.async {
            webview.loadHTMLString(generateHTML(), baseURL: conf.baseURL)
        }
        
        webview.isOpaque = false
        webview.backgroundColor = UIColor.clear
        webview.scrollView.backgroundColor = UIColor.clear
        
        return webview
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        DispatchQueue.main.async {
            uiView.loadHTMLString(generateHTML(), baseURL: conf.baseURL)
            uiView.frame.size = .init(width: width, height: dynamicHeight)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
#else
import AppKit
// macOS平台自定义WebView类
private class ScrollAdjustedWKWebView: WKWebView {
    override public func scrollWheel(with event: NSEvent) {
        nextResponder?.scrollWheel(with: event)
    }
}

// macOS平台WebView实现
extension WebView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(context.coordinator, name: "notifyCompletion")
        let webview = ScrollAdjustedWKWebView(frame: .zero, configuration: configuration)
        webview.navigationDelegate = context.coordinator
        DispatchQueue.main.async {
            webview.loadHTMLString(generateHTML(), baseURL: conf.baseURL)
        }
        webview.setValue(false, forKey: "drawsBackground")
        
        return webview
    }
    
    func updateNSView(_ nsView: WKWebView, context _: Context) {
        DispatchQueue.main.async {
            nsView.loadHTMLString(generateHTML(), baseURL: conf.baseURL)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
#endif

// WebView协调器实现
extension WebView {
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // 处理JavaScript消息
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "notifyCompletion" {
                if let height = message.body as? NSNumber {
                    let cgFloatHeight = CGFloat(height.doubleValue)
                    DispatchQueue.main.async {
                        if let animation = self.parent.conf.transition {
                            withAnimation(animation) {
                                self.parent.dynamicHeight = cgFloatHeight
                            }
                        } else {
                            self.parent.dynamicHeight = cgFloatHeight
                        }
                    }
                }
            }
        }
        
        // 处理导航操作
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard navigationAction.navigationType == WKNavigationType.linkActivated,
                  var url = navigationAction.request.url else {
                decisionHandler(WKNavigationActionPolicy.allow)
                return
            }
            
            if case let .custom(action) = parent.conf.linkOpenType {
                action(url)
            } else {
                if url.scheme == nil {
                    guard let httpsURL = URL(string: "https://\(url.absoluteString)") else {
                        decisionHandler(WKNavigationActionPolicy.cancel)
                        return
                    }
                    url = httpsURL
                }
                
                switch url.scheme {
                case "mailto", "tel":
#if canImport(UIKit)
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
#else
                    NSWorkspace.shared.open(url)
#endif
                case "http", "https":
                    switch parent.conf.linkOpenType {
#if canImport(UIKit)
                    case let .SFSafariView(conf, isReaderActivated, isAnimated):
                        if let reader = isReaderActivated {
                            conf.entersReaderIfAvailable = reader
                        }
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = scene.windows.first?.rootViewController {
                            rootViewController.present(SFSafariViewController(url: url, configuration: conf),
                                                       animated: isAnimated,
                                                       completion: nil)
                        }
#endif
                    case .Safari:
#if canImport(UIKit)
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
#else
                        NSWorkspace.shared.open(url)
#endif
                    case .none, .custom:
                        break
                    }
                default:
#if canImport(UIKit)
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
#else
                    NSWorkspace.shared.open(url)
#endif
                }
            }
            
            decisionHandler(WKNavigationActionPolicy.cancel)
        }
    }
}

// HTML生成相关扩展
extension WebView {
    // 生成HTML内容
    func generateHTML() -> String {
        return """
            <HTML>
            <head>
                <meta name='viewport' content='width=device-width, shrink-to-fit=YES, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>
            </head>
            \(generateCSS())
            <div id="NuPlay_RichText" style="padding: 8px">\(html)</div>
            </BODY>
            <script>
                function syncHeight() {
                  window.webkit.messageHandlers.notifyCompletion.postMessage(
                    document.getElementById('NuPlay_RichText').offsetHeight
                  );
                }
                window.onload = function () {
                  syncHeight();
            
                  var imgs = document.getElementsByTagName('img');
                  for (var i = 0; i < imgs.length; i++) {
                    imgs[i].onload = syncHeight;
                  }
                };
            </script>
            </HTML>
            """
    }
    
    // 生成CSS样式
    func generateCSS() -> String {
        switch conf.colorScheme {
        case .light:
            return """
            <style type='text/css'>
                \(conf.css(isLight: true, alignment: alignment))
                \(conf.customCSS)
                body, article {
                    margin: 0;
                    padding: 0;
                }
            </style>
            <BODY>
            """
        case .dark:
            return """
            <style type='text/css'>
                \(conf.css(isLight: false, alignment: alignment))
                \(conf.customCSS)
                body, article {
                    margin: 0;
                    padding: 0;
                }
            </style>
            <BODY>
            """
        case .auto:
            return """
            <style type='text/css'>
            @media (prefers-color-scheme: light) {
                \(conf.css(isLight: true, alignment: alignment))
            }
            @media (prefers-color-scheme: dark) {
                \(conf.css(isLight: false, alignment: alignment))
            }
            \(conf.customCSS)
            body, article {
                margin: 0;
                padding: 0;
            }
            </style>
            <BODY>
            """
        }
    }
}

// 获取 rootViewController 的辅助方法
private func getRootViewController() -> UIViewController? {
    // 获取当前活跃的场景
    guard let scene = UIApplication.shared.connectedScenes
        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
        return nil
    }
    
    // 从场景中获取 window
    return scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
}
