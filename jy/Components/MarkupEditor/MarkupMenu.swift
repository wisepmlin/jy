//
//  MarkupMenu.swift
//  MarkupEditor
//
//  Created by Steven Harris on 8/3/22.
//

import UIKit

/// MarkupMenu 为支持菜单栏的环境创建 UIMenu 内容。
///
/// MarkupMenu 的内容对应于 ToolbarContents。所有的操作和
/// canPerformAction 逻辑都位于 MarkupWKWebView 中。当菜单项被调用和热键被
/// 按下时，selectedWebView (一个 MarkupWKWebView) 在响应链中被找到并执行
/// 相应的操作。
///
/// MarkupMenu 默认标题为 "Format"，并将被放置在 Edit 菜单之后。
/// initMenu 方法会移除默认的 Format 菜单。
///
/// 注意，某些热键即使在菜单未启用的情况下也能工作，但大多数不会。例如，command+B
/// 即使没有 MarkupMenu 也能实现加粗/取消加粗，但 command+] 不会缩进。这是
/// WKWebView 的"原生"支持的副产品。
///
@MainActor
public class MarkupMenu {
    // 工具栏内容
    let contents = MarkupEditor.toolbarContents
    
    public init() {}
    
    // 初始化菜单
    public func initMenu(with builder: UIMenuBuilder) {
        // 移除现有的 Format 菜单并替换它
        builder.remove(menu: .format)
        var children = [UIMenu]()
        if contents.insert { children.append(insertMenu()) }
        if contents.style {
            if contents.styleContents.paragraph { children.append(styleMenu()) }
            if !contents.styleContents.listType.isEmpty { children.append(listMenu()) }
            if contents.styleContents.dent { children.append(dentMenu()) }
        }
        if contents.format { children.append(formatMenu()) }
        if children.isEmpty { return }  // 如果没有子菜单，不显示 markupMenu
        let markupMenu = UIMenu(title: "Format", children: children)
        builder.insertSibling(markupMenu, afterMenu: .edit)
    }
    
    // 创建插入菜单
    private func insertMenu() -> UIMenu {
        var children = [UICommand]()
        if contents.insertContents.link {
            children.append(UIKeyCommand(title: "Link", action: #selector(MarkupWKWebView.showPluggableLinkPopover), input: "K", modifierFlags: .command))
        }
        if contents.insertContents.image {
            children.append(UICommand(title: "Image", action: #selector(MarkupWKWebView.showPluggableImagePopover)))
        }
        if contents.insertContents.table {
            children.append(UICommand(title: "Table", action: #selector(MarkupWKWebView.showPluggableTablePopover)))
        }
        return UIMenu(title: "Insert", children: children)
    }
    
    // 创建样式菜单
    private func styleMenu() -> UIMenu {
        let children: [UICommand] = [
            UICommand(title: "Normal", action: #selector(MarkupWKWebView.pStyle)),
            UICommand(title: "Header 1", action: #selector(MarkupWKWebView.h1Style)),
            UICommand(title: "Header 2", action: #selector(MarkupWKWebView.h2Style)),
            UICommand(title: "Header 3", action: #selector(MarkupWKWebView.h3Style)),
            UICommand(title: "Header 4", action: #selector(MarkupWKWebView.h4Style)),
            UICommand(title: "Header 5", action: #selector(MarkupWKWebView.h5Style)),
            UICommand(title: "Header 6", action: #selector(MarkupWKWebView.h6Style))
        ]
        return UIMenu(title: "Style", children: children)
    }
    
    // 创建缩进菜单
    private func dentMenu() -> UIMenu {
        let children: [UICommand] = [
            UIKeyCommand(title: "Indent", action: #selector(MarkupWKWebView.indent), input: "]", modifierFlags: .command),
            UIKeyCommand(title: "Outdent", action: #selector(MarkupWKWebView.outdent), input: "[", modifierFlags: .command)
        ]
        return UIMenu(title: "Dent", options: .displayInline, children: children)
    }
    
    // 创建列表菜单
    private func listMenu() -> UIMenu {
        let children: [UICommand] = contents.styleContents.listType.map { type in
            switch type {
            case .bullet:
                return UIKeyCommand(title: "Bullets", action: #selector(MarkupWKWebView.bullets), input: ".", modifierFlags: .command)
            case .number:
                return UIKeyCommand(title: "Numbers", action: #selector(MarkupWKWebView.numbers), input: "/", modifierFlags: .command)
            }
        }

        return UIMenu(title: "List", options: .displayInline, children: children)
    }
    
    // 创建格式菜单
    private func formatMenu() -> UIMenu {
        var children: [UICommand] = []
        // 添加加粗选项
        children.append(UIKeyCommand(title: "Bold", action: #selector(MarkupWKWebView.bold), input: "B", modifierFlags: .command))
        // 添加斜体选项
        children.append(UIKeyCommand(title: "Italic", action: #selector(MarkupWKWebView.italic), input: "I", modifierFlags: .command))
        // 添加下划线选项
        children.append(UIKeyCommand(title: "Underline", action: #selector(MarkupWKWebView.underline), input: "U", modifierFlags: .command))
        // 添加代码选项
        if contents.formatContents.code {
            children.append(UIKeyCommand(title: "Code", action: #selector(MarkupWKWebView.code), input: "`", modifierFlags: .command))
        }
        // 添加删除线选项
        if contents.formatContents.strike {
            children.append(UIKeyCommand(title: "Strikethrough", action: #selector(MarkupWKWebView.strike), input: "-", modifierFlags: [.control, .command]))
        }
        // 添加上下标选项
        if contents.formatContents.subSuper {
            children.append(UIKeyCommand(title: "Subscript", action: #selector(MarkupWKWebView.subscriptText), input: "=", modifierFlags: [.alternate, .command]))
            children.append(UIKeyCommand(title: "Superscript", action: #selector(MarkupWKWebView.superscript), input: "=", modifierFlags: [.shift, .alternate, .command]))
        }
        return UIMenu(title: "Format", options: .displayInline, children: children)
    }
    
}
