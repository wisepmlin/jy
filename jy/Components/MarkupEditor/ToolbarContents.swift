//
//  ToolbarContents.swift
//  MarkupEditor
//
//  Created by Steven Harris on 8/3/22.
//

import Foundation

/// ToolbarContents控制MarkupToolbar和MarkupMenu的内容
///
/// ToolbarContents包含一组布尔值，用于在各种工具栏中确定显示的内容
/// 顶层的`correction`、`insert`、`style`和`format`条目表示这些工具栏是否完全包含在MarkupToolbar中
/// 其他的`*contents`条目指向单个工具栏内容的类似结构
///
/// 设置`custom`以使用自己的ToolbarContents实例来自定义MarkupToolbar和MarkupMenu的内容
/// 在内部，工具栏和菜单访问`shared`，如果未指定`custom`，则为默认的ToolbarContents实例
@MainActor
public class ToolbarContents {
    // 自定义工具栏内容实例
    public static var custom: ToolbarContents?
    // 共享实例，如果custom为nil则使用默认实例
    public static let shared = custom ?? ToolbarContents()
    
    // 左侧工具栏开关
    public var leftToolbar: Bool
    // 纠正功能开关
    public var correction: Bool
    // 插入功能开关
    public var insert: Bool
    // 样式功能开关
    public var style: Bool
    // 格式功能开关
    public var format: Bool
    // 右侧工具栏开关
    public var rightToolbar: Bool
    
    // 插入内容配置
    public var insertContents: InsertContents
    // 样式内容配置
    public var styleContents: StyleContents
    // 格式内容配置
    public var formatContents: FormatContents
    // 表格内容配置
    public var tableContents: TableContents
    
    // 弹出窗口类型枚举
    public enum PopoverType: String, CaseIterable {
        case link   // 链接
        case image  // 图片
        case table  // 表格
    }
    
    // 初始化方法
    public init(
        leftToolbar: Bool = false,
        correction: Bool = true,
        insert: Bool = true,
        style: Bool = true,
        format: Bool = true,
        rightToolbar: Bool = false,
        insertContents: InsertContents = InsertContents(),
        styleContents: StyleContents = StyleContents(),
        formatContents: FormatContents = FormatContents(),
        tableContents: TableContents = TableContents()
    ) {
        self.leftToolbar = leftToolbar ? MarkupEditor.leftToolbar != nil : false
        self.correction = correction
        self.insert = insert
        self.style = style
        self.format = format
        self.rightToolbar = rightToolbar ? MarkupEditor.rightToolbar != nil : false
        self.insertContents = insertContents
        self.styleContents = styleContents
        self.formatContents = formatContents
        self.tableContents = tableContents
    }
    
    // 从现有实例创建新实例
    public static func from(_ toolbarContents: ToolbarContents) -> ToolbarContents{
        ToolbarContents(
            leftToolbar: toolbarContents.leftToolbar,
            correction: toolbarContents.correction,
            insert: toolbarContents.insert,
            style: toolbarContents.style,
            format: toolbarContents.format,
            rightToolbar: toolbarContents.rightToolbar,
            insertContents: toolbarContents.insertContents,
            styleContents: toolbarContents.styleContents,
            formatContents: toolbarContents.formatContents,
            tableContents: toolbarContents.tableContents
        )
    }
}

// 定义插入工具栏项目的显示配置
public struct InsertContents {
    // 链接功能开关
    public var link: Bool
    // 图片功能开关
    public var image: Bool
    // 表格功能开关
    public var table: Bool
    
    public init(link: Bool = true, image: Bool = true, table: Bool = true) {
        self.link = link
        self.image = image
        self.table = table
    }
}

// 定义列表和缩进/突出显示项目的显示配置
public struct StyleContents {
    // 列表类型枚举
    public enum ListType {
        case bullet  // 项目符号列表
        case number  // 数字列表
    }

    // 段落功能开关
    public var paragraph: Bool
    // 列表类型数组
    public var listType: [ListType]
    // 缩进功能开关
    public var dent: Bool

    public init(paragraph: Bool = true, listType: [ListType], dent: Bool = true) {
        self.paragraph = paragraph
        self.listType = listType
        self.dent = dent
    }

    public init(paragraph: Bool = true, list: Bool = true, dent: Bool = true) {
        self.paragraph = paragraph
        self.listType = list ? [.bullet, .number] : []
        self.dent = dent
    }
}

// 定义代码、删除线和上下标项目的显示配置
public struct FormatContents {
    // 代码格式开关
    public var code: Bool
    // 删除线格式开关
    public var strike: Bool
    // 上下标格式开关
    public var subSuper: Bool
    
    public init(code: Bool = true, strike: Bool = true, subSuper: Bool = true) {
        self.code = code
        self.strike = strike
        self.subSuper = subSuper
    }
}

// 定义表格边框显示配置
public struct TableContents {
    // 边框显示开关
    public var border: Bool
    
    public init(border: Bool = true) {
        self.border = border
    }
}
