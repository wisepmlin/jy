//
//  SelectionState.swift
//  MarkupEditor
//
//  Created by Steven Harris on 1/19/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import UIKit

/// MarkupWKWebView中选择状态的类
public class SelectionState: ObservableObject, Identifiable, CustomStringConvertible {
    // 有效性标志
    @Published public var valid: Bool = false
    // 选择内容或包含div的可编辑区域ID
    @Published public var divid: String? = nil
    // 选中的文本
    @Published public var selection: String? = nil
    @Published public var selrect: CGRect? = nil
    // 链接相关
    @Published public var href: String? = nil
    @Published public var link: String? = nil
    // 图片相关
    @Published public var src: String? = nil
    @Published public var alt: String? = nil
    @Published public var width: Int? = nil
    @Published public var height: Int? = nil
    @Published public var scale: Int? = nil  // 百分比
    // 表格相关
    @Published public var table: Bool = false
    @Published public var thead: Bool = false
    @Published public var tbody: Bool = false
    @Published public var header: Bool = false
    @Published public var colspan: Bool = false
    @Published public var rows: Int = 0
    @Published public var cols: Int = 0
    @Published public var row: Int = 0
    @Published public var col: Int = 0
    @Published public var border: MarkupEditor.TableBorder = .cell
    // 样式相关
    @Published public var style: StyleContext = StyleContext.Undefined
    @Published public var list: ListContext = ListContext.Undefined
    @Published public var li: Bool = false
    @Published public var quote: Bool = false
    // 格式相关
    @Published public var bold: Bool = false
    @Published public var italic: Bool = false
    @Published public var underline: Bool = false
    @Published public var strike: Bool = false
    @Published public var sub: Bool = false
    @Published public var sup: Bool = false
    @Published public var code: Bool = false
    
    // MARK: 弹出框的源矩形
    public var sourceRect: CGRect? {
        guard let selrect else {
            return nil
        }
        // 弹出框源矩形必须有非零宽度/高度
        return CGRect(origin: selrect.origin, size: CGSize(width: max(selrect.width, 1), height: max(selrect.height, 1)))
    }
    
    // MARK: 选择状态查询
    public var isValid: Bool { valid }
    public var isEditable: Bool {
        valid && divid != nil
    }
    public var isLinkable: Bool {
        href == nil          // 当选择在链接中时不能链接
    }
    public var isFollowable: Bool { // 选择是否会跟随链接
        isInLink && selection == nil
    }
    public var isInLink: Bool {
        link != nil && href != nil
    }
    public var isInsertable: Bool {
        selection == nil || selection?.isEmpty ?? true
    }
    public var isStyleNormal: Bool {
        style == .P || style == .Undefined
    }
    public var isStyleLargest: Bool {
        style == .H1
    }
    public var isStyleSmallest: Bool {
        isStyleNormal   // 目前"normal"是最小的
    }
    public var isInList: Bool {
        list != .Undefined
    }
    public var isInListItem: Bool {
        // li为true而isInList为false将是一个错误
        // 但是isInList可以为true而li为false
        isInList && li
    }
    public var isInImage: Bool {
        src != nil  // 可能缺少alt
    }
    public var isInTable: Bool {
        table
    }
    
    // MARK: 启用/禁用菜单选项和按钮
    
    public var canDent: Bool { true }
    public var canStyle: Bool { style != .Undefined }
    public var canList: Bool { true }
    public var canInsert: Bool { isInsertable }
    public var canLink: Bool { !isInLink }
    public var canFormat: Bool { true }
    public var canCopyCut: Bool { selection != nil || isInImage }
    
    // CustomStringConvertible协议实现
    public var description: String {
        valid ?
        """
          selection: \(selection ?? "none")
          divid: \(divid ?? "none")
          style: \(style.tag)
          formats: \(formatString())
          list: \(listString())
          quote: \(quote ? "true" : "none")
          link: \(linkString())
          image: \(imageString())
          table: \(tableString())
        """ : "invalid, divid: \(divid ?? "none"))"
    }
    
    public init() {}
    
    // 从另一个SelectionState重置状态
    public func reset(from selectionState: SelectionState?) {
        selection = selectionState?.selection
        selrect = selectionState?.selrect               // 包含选择的矩形（如果已选择）
        valid = selectionState?.valid ?? false          // 如果document.getSelection().rangeCount > 0则为true
        divid = selectionState?.divid                   // 通常是"editor"，但可能是其他包含div的id
        href = selectionState?.href                     // 选中时<a>标签的href
        link = selectionState?.link                     // 选中时<a>标签中链接到href的文本
        src = selectionState?.src                       // 选中时<img>的src
        alt = selectionState?.alt                       // 选中时<img>的alt
        width = selectionState?.width                   // 选中且定义时<img>的宽度
        height = selectionState?.height                 // 选中且定义时<img>的高度
        scale = selectionState?.scale ?? 100            // 选中时<img>的缩放比例
        table = selectionState?.table ?? false          // 选择是否在表格中
        thead = selectionState?.thead ?? false          // 选择是否在表头中
        tbody = selectionState?.tbody ?? false          // 选择是否在表体中
        header = selectionState?.header ?? false        // 表格是否有表头
        colspan = selectionState?.colspan ?? false      // 如果有表头，表头是否有colspan
        rows = selectionState?.rows ?? 0                // 选中表格的行数
        cols = selectionState?.cols ?? 0                // 选中表格的列数
        row = selectionState?.row ?? 0                  // 选中的表体行号（表头为0）
        col = selectionState?.col ?? 0                  // 选中的表体或表头列号
        border = selectionState?.border ?? .cell        // 选中表格的边框样式
        style = selectionState?.style ?? StyleContext.Undefined
        list = selectionState?.list ?? ListContext.Undefined
        li = selectionState?.li ?? false
        quote = selectionState?.quote ?? false
        bold = selectionState?.bold ?? false
        italic = selectionState?.italic ?? false
        underline = selectionState?.underline ?? false
        strike = selectionState?.strike ?? false
        sub = selectionState?.sub ?? false
        sup = selectionState?.sup ?? false
        code = selectionState?.code ?? false
    }
    
    // 获取格式化字符串
    func formatString() -> String {
        let formatValues = [bold, italic, underline, strike, sub, sup, code]
        let formats = FormatContext.AllCases
        var tags = [String]()
        for index in formatValues.indices { if formatValues[index] { tags.append("\(formats[index])")} }
        return tags.isEmpty ? "none" : tags.joined(separator: ", ")
    }
    
    // 获取列表字符串
    func listString() -> String {
        if li {
            return "Inside of <LI> in \(list.tag) list"   // 这是一个错误
        } else {
            if list == .Undefined {
                return "none"
            } else {
                return "Outside of <LI> in \(list.tag) list"
            }
        }
    }
    
    // 获取链接字符串
    func linkString() -> String {
        guard let href = href, let link = link else { return "none" }
        return "\(href) linksTo: \(link)"
    }
    
    // 获取图片字符串
    func imageString() -> String {
        guard let src = src else { return "none" }
        let width = width == nil ? "undefined" : "\(width!)"
        let height = height == nil ? "undefined" : "\(height!)"
        return "\(src), alt: \(alt ?? "none"), width: \(width), height: \(height), scale: \(scale ?? 100)%"
    }
    
    // 获取表格字符串
    func tableString() -> String {
        guard table else { return "none" }
        let tableSize = "\(rows)x\(cols)"
        let headerType = header ? (colspan ? "spanning header" : "non-spanning header") : "no header"
        if tbody {
            return "in body row \(row), col \(col) of \(tableSize) table with \(headerType), border: \(border)"
        } else if thead {
            if colspan {
                return "in \(headerType) of \(tableSize) table, border: \(border)"
            } else {
                return "in col \(col) of \(headerType) of \(tableSize) table, border: \(border)"
            }
        } else {
            return "Error: in \(tableSize) table, but in neither tbody nor thead"
        }
    }
    
}
