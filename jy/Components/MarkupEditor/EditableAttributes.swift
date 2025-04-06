//
//  EditableAttributes.swift
//  MarkupEditor
//
//  Created by Steven Harris on 12/26/23.
//

import Foundation

// EditableAttributes 结构体实现了 OptionSet 协议，用于管理可编辑属性的位掩码
public struct EditableAttributes: @unchecked Sendable, OptionSet {
    // 原始值，用于存储位掩码
    public let rawValue: Int
    
    // 定义三个基本的可编辑属性
    // contenteditable: 内容是否可编辑
    public static let contenteditable = EditableAttributes(rawValue: 1 << 0)
    // spellcheck: 拼写检查
    public static let spellcheck = EditableAttributes(rawValue: 1 << 1)
    // autocorrect: 自动纠正
    public static let autocorrect = EditableAttributes(rawValue: 1 << 2)
    
    // 标准配置：包含 contenteditable 和 autocorrect
    public static let standard: EditableAttributes = [.contenteditable, .autocorrect]
    // 空配置：不包含任何属性
    public static let empty: EditableAttributes = []
    
    // 初始化方法
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// Return a dictionary of the options that are set in this EditableAttributes instance.
    ///
    /// We use this to get JSON from, so populate the dictionary with booleans for all values.
    ///
    /// NOTE: Currently spellcheck="true" produces a bad behavior wherein a word is selected and then the selection
    /// changes to the end of the paragraph. This may have to do with some underlying mechanics for presenting
    /// suggestions, but for now we will set to "false" by default.
    
    // 将当前实例的属性转换为字典形式
    public var options: [String : Bool] {
        var options: [String : Bool] = [:]
        // 检查各个属性是否被设置，并添加到字典中
        options["contenteditable"] = contains(.contenteditable)
        options["spellcheck"] = contains(.spellcheck)
        options["autocorrect"] = contains(.autocorrect)
        return options
    }
}
