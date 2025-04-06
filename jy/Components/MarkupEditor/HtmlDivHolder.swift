//
//  HtmlDivHolder.swift
//  MarkupEditor
//  Adapted from https://stackoverflow.com/a/38885813/8968411
//
//  Created by Steven Harris on 12/26/23.
//

import Foundation

// 定义一个包含HtmlDiv属性的协议
public protocol HasHtmlDiv {
    var htmlDiv: HtmlDiv { get set }
}

// 定义HtmlDivHolder协议，继承自HasHtmlDiv和CustomStringConvertible
public protocol HtmlDivHolder: HasHtmlDiv, CustomStringConvertible { }

// HtmlDivHolder的扩展，用于转发和设置相应的HtmlDiv值
extension HtmlDivHolder {
    // HTML元素的唯一标识符
    public var id: String {
        get { htmlDiv.id }
        set { htmlDiv.id = newValue }
    }
    
    // 父元素的ID
    public var parentId: String {
        get { htmlDiv.parentId }
        set { htmlDiv.parentId = newValue }
    }
    
    // 目标元素的ID，可选值
    public var targetId: String? {
        get { htmlDiv.targetId }
        set { htmlDiv.targetId = newValue }
    }
    
    // 焦点元素的ID，可选值
    public var focusId: String? {
        get { htmlDiv.focusId }
        set { htmlDiv.focusId = newValue }
    }
    
    // CSS类名
    public var cssClass: String {
        get { htmlDiv.cssClass }
        set { htmlDiv.cssClass = newValue }
    }
    
    // 可编辑的HTML属性
    public var attributes: EditableAttributes {
        get { htmlDiv.attributes }
        set { htmlDiv.attributes = newValue }
    }
    
    // HTML内容
    public var htmlContents: String {
        get { htmlDiv.htmlContents }
        set { htmlDiv.htmlContents = newValue }
    }
    
    // 资源URL，可选值
    public var resourcesUrl: URL? {
        get { htmlDiv.resourcesUrl }
        set { htmlDiv.resourcesUrl = newValue }
    }
    
    // 按钮组，可选值
    public var buttonGroup: HtmlButtonGroup? {
        get { htmlDiv.buttonGroup }
        set { htmlDiv.buttonGroup = newValue }
    }
    
    // 按钮数组，如果buttonGroup为nil则返回空数组
    public var buttons: [HtmlButton] {
        get { buttonGroup?.buttons ?? [] }
        set { buttonGroup = HtmlButtonGroup(in: id, buttons: newValue) }
    }
    
    // 描述信息
    public var description: String { htmlDiv.description }
}
