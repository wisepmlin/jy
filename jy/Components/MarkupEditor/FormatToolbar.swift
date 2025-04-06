//
//  FormatToolbar.swift
//  MarkupEditor
//
//  Created by Steven Harris on 4/7/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

// 格式化工具栏视图结构体
public struct FormatToolbar: View {
    @Environment(\.theme) private var theme
    // 观察WebView对象，用于执行格式化操作
    @ObservedObject private var observedWebView: ObservedWebView = MarkupEditor.observedWebView
    // 观察选中状态对象，用于追踪文本格式状态
    @ObservedObject private var selectionState: SelectionState = MarkupEditor.selectionState
    // 工具栏内容配置
    private let contents: FormatContents = MarkupEditor.toolbarContents.formatContents
    // 悬停标签状态
    @State private var hoverLabel: Text = Text("Text Format")

    public init() {}

    // 视图主体
    public var body: some View {
        LabeledToolbar(label: hoverLabel) {
            // 粗体按钮
            ToolbarImageButton(
                systemName: "bold",
                action: { observedWebView.selectedWebView?.bold() },
                active: $selectionState.bold,
                activeColor: theme.jyxqPrimary,
                onHover: { over in hoverLabel = Text(over ? "Bold" : "Text Format") }
            )
            // 斜体按钮
            ToolbarImageButton (
                systemName: "italic",
                action: { observedWebView.selectedWebView?.italic() },
                active: $selectionState.italic,
                activeColor: theme.jyxqPrimary,
                onHover: { over in hoverLabel = Text(over ? "Italic" : "Text Format") }
            )
            // 下划线按钮
            ToolbarImageButton(
                systemName: "underline",
                action: { observedWebView.selectedWebView?.underline() },
                active: $selectionState.underline,
                activeColor: theme.jyxqPrimary,
                onHover: { over in hoverLabel = Text(over ? "Underline" : "Text Format") }
            )
            // 代码格式按钮（可选）
            if contents.code {
                ToolbarImageButton(
                    systemName: "curlybraces",
                    action: { observedWebView.selectedWebView?.code() },
                    active: $selectionState.code,
                    activeColor: theme.jyxqPrimary,
                    onHover: { over in hoverLabel = Text(over ? "Code" : "Text Format") }
                )
            }
            // 删除线按钮（可选）
            if contents.strike {
                ToolbarImageButton(
                    systemName: "strikethrough",
                    action: { observedWebView.selectedWebView?.strike() },
                    active: $selectionState.strike,
                    activeColor: theme.jyxqPrimary,
                    onHover: { over in hoverLabel = Text(over ? "Strikethrough" : "Text Format") }
                )
            }
            // 上标下标按钮（可选）
            if contents.subSuper {
                // 下标按钮
                ToolbarImageButton(
                    systemName: "textformat.subscript",
                    action: { observedWebView.selectedWebView?.subscriptText() },
                    active: $selectionState.sub,
                    activeColor: theme.jyxqPrimary,
                    onHover: { over in hoverLabel = Text(over ? "Subscript" : "Text Format") }
                )
                // 上标按钮
                ToolbarImageButton(
                    systemName: "textformat.superscript",
                    action: { observedWebView.selectedWebView?.superscript() },
                    active: $selectionState.sup,
                    activeColor: theme.jyxqPrimary,
                    onHover: { over in hoverLabel = Text(over ? "Superscript" : "Text Format") }
                )
            }
        }
    }
}

// 预览提供者结构体
struct FormatToolbar_Previews: PreviewProvider {
    static var previews: some View {
        // 垂直布局容器
        VStack(alignment: .leading) {
            // 紧凑样式预览
            HStack {
                FormatToolbar()
                    .environmentObject(ToolbarStyle.compact)
                Spacer()
            }
            // 标签样式预览
            HStack {
                FormatToolbar()
                    .environmentObject(ToolbarStyle.labeled)
                Spacer()
            }
            Spacer()
        }
    }
}
