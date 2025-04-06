//
//  HtmlDiv.swift
//  SwiftUIDemo
//
//  Created by Steven Harris on 1/17/24.
//

import Foundation

/// 表示JavaScript端的DIV元素的类
///
/// 这个类的作用是让其他结构体可以实现HtmlDivHolder协议，这意味着它们拥有一个HtmlDiv实例
public class HtmlDiv: CustomStringConvertible {
    // DIV的唯一标识符
    public var id: String
    // 父元素的ID
    public var parentId: String
    // 目标元素的ID，可选
    public var targetId: String?
    // 焦点元素的ID，可选
    public var focusId: String?
    // CSS类名，默认为"editor"
    public var cssClass: String = "editor"
    // 可编辑属性，使用标准配置
    public var attributes: EditableAttributes = EditableAttributes.standard
    // HTML内容
    public var htmlContents: String
    // 资源URL，可选
    public var resourcesUrl: URL?
    // 按钮组，可选
    public var buttonGroup: HtmlButtonGroup?
    // 按钮数组的计算属性
    public var buttons: [HtmlButton] {
        get { buttonGroup?.buttons ?? [] }
        set { buttonGroup = HtmlButtonGroup(in: id, focusId: focusId, buttons: newValue, dynamic: dynamic) }
    }
    // 是否动态
    private var dynamic: Bool
    // 描述信息
    public var description: String {
        "\(cssClass) id: \(id), parentId: \(parentId)"
    }
    
    // 初始化方法
    public init(id: String, in parentId: String = "editor", targetId: String? = nil, focusId: String? = nil, cssClass: String, attributes: EditableAttributes, htmlContents: String = "", resourcesUrl: URL? = nil, buttons: [HtmlButton]? = nil, dynamic: Bool = false) {
        self.id = id
        self.parentId = parentId
        self.targetId = targetId
        self.focusId = focusId
        self.cssClass = cssClass
        self.attributes = attributes
        self.htmlContents = htmlContents
        self.resourcesUrl = resourcesUrl
        self.dynamic = dynamic
        if let buttons {
            self.buttons = buttons
        }
    }
}
