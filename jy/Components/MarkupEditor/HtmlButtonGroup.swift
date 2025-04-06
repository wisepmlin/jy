//
//  HtmlButtonGroup.swift
//  MarkupEditor
//
//  Created by Steven Harris on 12/29/23.
//

import Foundation

/// 表示一组HTML按钮的Swift结构体。HtmlButtonGroup以包含HTML按钮的DIV形式呈现。
///
/// 我们使用它们使CSS样式可以将按钮组推到边缘。它们通常不会被直接引用，而是通过
/// 向MarkupDivStructure添加按钮或按钮数组来创建，这总是通过识别它们所在div的id来完成。
public class HtmlButtonGroup: HtmlDivHolder {
    public var id: String               // 对应此div的HTML元素的id
    public var parentId: String         // 此div的父div的id
    public var htmlDiv: HtmlDiv         // 我们持有的HTMLDiv，用于作为HTMLDivHolder
    public var cssClass: String         // 此div的CSS类
    public var buttons: [HtmlButton]    // 将位于div尾部边缘的按钮数组
    private var dynamic: Bool           // 如果按钮将被动态添加/删除则为true
    public var isDynamic: Bool { dynamic }
    
    // 初始化方法
    // parentId: 父div的id
    // focusId: 焦点元素的id，可选
    // cssClass: CSS类名，默认为"markupbuttongroup"
    // buttons: 按钮数组
    // dynamic: 是否支持动态添加删除按钮，默认为false
    public init(in parentId: String, focusId: String? = nil, cssClass: String = "markupbuttongroup", buttons: [HtmlButton], dynamic: Bool = false) {
        let bgId = "BG.\(parentId)"
        self.id = bgId
        self.parentId = parentId
        htmlDiv = HtmlDiv(id: bgId, in: parentId, focusId: focusId, cssClass: "markupbuttongroup", attributes: EditableAttributes.empty)
        self.cssClass = cssClass
        self.buttons = buttons
        self.dynamic = dynamic
    }

}
