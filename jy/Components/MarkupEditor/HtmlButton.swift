//
//  HtmlButton.swift
//  MarkupEditor
//
//  Created by Steven Harris on 12/28/23.
//

import Foundation

/// 表示一个HTML按钮的Swift结构体，当按下时会回调到Swift端
///
/// HtmlButton总是位于某种HtmlDiv中，通常是HtmlButtonGroup
public class HtmlButton {
    
    // 按钮动作信息结构体
    public struct ActionInfo {
        public let view: MarkupWKWebView      // WebView实例
        public let originId: String           // 源按钮ID
        public let targetId: String?          // 目标ID（可选）
        public let rect: CGRect               // 按钮区域矩形
    }
    
    public var id: String         // 按钮唯一标识符
    public var cssClass: String   // CSS类名
    public var label: String      // 按钮标签文本
    public var targetId: String?  // 目标ID（可选）
    public var action: (ActionInfo)->Void  // 按钮点击回调闭包
    
    // 初始化方法
    public init(id: String = UUID().uuidString, cssClass: String = "markupbutton", label: String, targetId: String? = nil, action: @escaping (ActionInfo)->Void) {
        self.id = id
        self.cssClass = cssClass
        self.label = label
        self.targetId = targetId
        self.action = action
    }
    
    // 执行按钮动作的方法
    public func executeAction(view: MarkupWKWebView, rect: CGRect, handler: (()->Void)? = nil) {
        let actionInfo = ActionInfo(view: view, originId: id, targetId: targetId, rect: rect)
        action(actionInfo)
        handler?()
    }

}
