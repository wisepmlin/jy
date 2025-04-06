//
//  MarkupCoordinator.swift
//  MarkupEditor
//
//  Created by Steven Harris on 2/28/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import WebKit
import OSLog

/// 跟踪单个MarkupWKWebView的变化，更新选择状态并通知MarkupDelegate发生的事件
///
/// MarkupWKWebView和MarkupCoordinator之间的通信是通过UserContentController完成的
/// MarkupCoordinator作为WKScriptMessageHandler，接收userContentController(_:didReceive:)消息
///
/// MarkupCoordinator的一个关键功能是处理MarkupWKWebView的初始化，因为它加载初始的html、css和JavaScript
/// 文档中的'editor'元素是我们在MarkupWKWebView中交互的对象。当html文档完全加载时，
/// MarkupCoordinator接收'ready'消息，此时它已准备好进行交互
///
/// MarkupCoordinator在SwiftUI和非SwiftUI应用程序中都使用。在SwiftUI中，MarkupEditorView创建
/// MarkupCoordinator本身，因为MarkupWKWebView(WKWebView的子类)是UIKit组件，必须由某种
/// Coordinator处理。在UIKit中，MarkupEditorUIView执行类似的工作
///
/// 当事件到达MarkupCoordinator时，它采取各种步骤确保我们在Swift中对MarkupWKWebView中内容的了解
/// 得到适当维护。它的另一个功能是通知MarkupDelegate发生了什么，以便MarkupDelegate可以执行
/// 所需的操作。例如，当此MarkupCoordinator接收到焦点事件时，它会通知MarkupDelegate，后者可能
/// 想要在焦点更改时采取其他操作，比如更新selectedWebView

public class MarkupCoordinator: NSObject, WKScriptMessageHandler {
    // webView的弱引用
    weak public var webView: MarkupWKWebView!
    // 标记代理
    public var markupDelegate: MarkupDelegate?
    
    // 初始化方法
    public init(markupDelegate: MarkupDelegate? = nil, webView: MarkupWKWebView? = nil) {
        self.markupDelegate = markupDelegate
        self.webView = webView
        super.init()
    }
    
    /// JavaScript端高度改变时，更新webView本地值，并设置底部padding以填充webView的完整高度
    @MainActor
    private func updateHeight() {
        webView.updateHeight() { height in
            self.webView.padBottom() {
                self.markupDelegate?.markup(self.webView, heightDidChange: height)
            }
        }
    }
    
    /// 根据从JavaScript通过userContentController接收的消息体采取行动
    /// 带参数的消息使用JSON编码
    @MainActor
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let messageBody = message.body as? String else {
            Logger.coordinator.error("Unknown message received: \(String(describing: message.body))")
            return
        }
        guard let webView = message.webView as? MarkupWKWebView else {
            Logger.coordinator.error("message.webView was not a MarkupWKWebView")
            return
        }
        // 由于每次更改都会发生，所以单独处理"input"
        if messageBody.hasPrefix("input") {
            // 在input消息中编码divId，通常是"editor"
            let index = messageBody.index(messageBody.startIndex, offsetBy: 5)
            let divId = String(messageBody[index...])
            if divId.isEmpty || divId == "editor" {
                markupDelegate?.markupInput(webView)
                updateHeight()
            } else if !divId.isEmpty {
                markupDelegate?.markupInput(webView, divId: divId)
            } else {
                Logger.coordinator.error("Error: The div id could not be decoded for input.")
            }
            return
        }
        
        // 处理不同类型的消息
        switch messageBody {
        case "ready":
            // 根文件正确加载后，可以加载用户提供的css和js
            webView.loadUserFiles()
        case "loadedUserFiles":
            // 用户css和js加载后，设置顶级"editor"属性并加载初始HTML
            webView.setTopLevelAttributes() {
                webView.loadInitialHtml()
            }
        case "updateHeight":
            updateHeight()
        case "blur":
            webView.hasFocus = false
            markupDelegate?.markupLostFocus(webView)
        case "focus":
            webView.hasFocus = true
            markupDelegate?.markupTookFocus(webView)
        case "selectionChange":
            // 仅在webView有焦点时处理选择更改
            if webView.hasFocus {
                webView.getSelectionState() { selectionState in
                    MarkupEditor.selectionState.reset(from: selectionState)
                    self.markupDelegate?.markupSelectionChanged(webView)
                }
            }
        case "click":
            webView.becomeFirstResponder()
            markupDelegate?.markupClicked(webView)
        case "undoSet":
            markupDelegate?.markupUndoSet(webView)
        case "searched":
            webView.makeSelectionVisible()
        case "activateSearch":
            markupDelegate?.markupActivateSearch(webView)
        case "deactivateSearch":
            markupDelegate?.markupDeactivateSearch(webView)
        default:
            // 尝试解码复杂的JSON字符串消息
            if let data = messageBody.data(using: .utf8) {
                do {
                    if let messageData = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                        receivedMessageData(messageData)
                    } else {
                        Logger.coordinator.error("Error: Decoded message data was nil")
                    }
                } catch let error {
                    Logger.coordinator.error("Error decoding message data: \(error.localizedDescription)")
                }
            } else {
                Logger.coordinator.error("Error: Data could not be derived from message body")
            }
        }
    }
    
    /// 处理从JavaScript通过userContentController接收的带参数的消息
    /// 在JavaScript端，messageType具有字符串键'messageType'，参数具有messageType的键
    @MainActor
    private func receivedMessageData(_ messageData: [String : Any]) {
        guard let messageType = messageData["messageType"] as? String else {
            Logger.coordinator.error("Unknown message received: \(messageData)")
            return
        }
        switch messageType {
        case "action":
            if let message = messageData["action"] as? String {
                Logger.coordinator.info("\(message)")
            } else {
                Logger.coordinator.error("Bad action message.")
            }
        case "log":
            if let message = messageData["log"] as? String {
                Logger.coordinator.info("\(message)")
            } else {
                Logger.coordinator.error("Bad log message.")
            }
        case "error":
            guard let code = messageData["code"] as? String, let message = messageData["message"] as? String else {
                Logger.coordinator.error("Bad error message.")
                return
            }
            let info = messageData["info"] as? String
            let alert = (messageData["alert"] as? Bool) ?? true
            markupDelegate?.markupError(code: code, message: message, info: info, alert: alert)
        case "copyImage":
            guard
                let src = messageData["src"] as? String,
                let dimensions = messageData["dimensions"] as? [String : Int]
            else {
                Logger.coordinator.error("Src or dimensions was missing")
                return
            }
            let alt = messageData["alt"] as? String
            let width = dimensions["width"]
            let height = dimensions["height"]
            webView.copyImage(src: src, alt: alt, width: width, height: height)
        case "addedImage":
            guard let src = messageData["src"] as? String, let url = URL(string: src) else {
                Logger.coordinator.error("Src was missing or malformed")
                return
            }
            if let divId = messageData["divId"] as? String {
                if divId.isEmpty || divId == "editor" {
                    markupDelegate?.markupImageAdded(url: url)
                    updateHeight()
                } else if !divId.isEmpty {
                    markupDelegate?.markupImageAdded(webView, url: url, divId: divId)
                } else {
                    Logger.coordinator.error("Error: The div id for the image could not be decoded.")
                }
            } else {
                markupDelegate?.markupImageAdded(url: url)
            }
        case "deletedImage":
            guard let src = messageData["src"] as? String, let url = URL(string: src) else {
                Logger.coordinator.error("Src was missing or malformed")
                return
            }
            if let divId = messageData["divId"] as? String {
                if divId.isEmpty || divId == "editor" {
                    markupDelegate?.markupImageDeleted(url: url)
                    updateHeight()
                } else if !divId.isEmpty {
                    markupDelegate?.markupImageDeleted(webView, url: url, divId: divId)
                } else {
                    Logger.coordinator.error("Error: The div id for the image could not be decoded.")
                }
            } else {
                markupDelegate?.markupImageDeleted(url: url)
            }
        case "buttonClicked":
            guard
                let id = messageData["id"] as? String,
                let rectDict = messageData["rect"] as? [String : CGFloat],
                let rect = webView.rectFromDict(rectDict)
            else {
                Logger.coordinator.error("Button id or rect was missing")
                return
            }
            markupDelegate?.markupButtonClicked(webView, id: id, rect: rect)
        default:
            Logger.coordinator.error("Unknown message of type \(messageType): \(messageData).")
        }
    }
    
    /// 处理WKWebView的导航策略
    @MainActor public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            webView.load(navigationAction.request)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
    
}
