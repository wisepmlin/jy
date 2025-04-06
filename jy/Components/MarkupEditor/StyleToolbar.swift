//
// StyleToolbar.swift
// MarkupEditor
//
// 创建者: Steven Harris 
// 创建时间: 2021年4月7日
// 版权所有 © 2021 Steven Harris. 保留所有权利.
//
// 该文件实现了一个样式工具栏组件，用于设置段落样式
// 主要功能包括:
// 1. 段落样式选择下拉菜单
// 2. 项目符号列表切换
// 3. 数字列表切换
// 4. 缩进和减少缩进功能
//

import SwiftUI

/// 用于设置段落样式的工具栏
public struct StyleToolbar: View {
    @Environment(\.theme) private var theme
    // 工具栏样式环境对象
    @EnvironmentObject private var toolbarStyle: ToolbarStyle
    // 观察WebView的状态
    @ObservedObject private var observedWebView: ObservedWebView = MarkupEditor.observedWebView
    // 观察选中内容的状态
    @ObservedObject private var selectionState: SelectionState = MarkupEditor.selectionState
    // 工具栏内容配置
    private let contents: StyleContents = MarkupEditor.toolbarContents.styleContents
    // 悬停标签状态
    @State private var hoverLabel: Text = Text("Paragraph Style")
    // 工具栏高度
    private var height: CGFloat { toolbarStyle.height() }

    public init() {}

    public var body: some View {
        LabeledToolbar(label: hoverLabel) {
            // 段落样式下拉菜单
            if contents.paragraph {
                if #available(iOS 16, macCatalyst 16, *) {
                    Menu {
                        ForEach(StyleContext.StyleCases, id: \.self) { styleContext in
                            Button(action: { observedWebView.selectedWebView?.replaceStyle(selectionState.style, with: styleContext) }) {
                                Text(styleContext.name)
                                    .font(.system(size: styleContext.fontSize))
                            }
                        }
                    } label: {
                        // Mac Catalyst上前景色为黑色且无法更改
                        Text(selectionState.style.name)
                            .frame(width: 72, height: toolbarStyle.buttonHeight(), alignment: .center)
                            .foregroundColor(theme.jyxqPrimary)
                    }
                    .buttonStyle(.borderless)
                    .menuStyle(.button)         // iOS 16才可用
                    .frame(width: 72, height: toolbarStyle.buttonHeight())
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        )
                        .stroke(theme.jyxqPrimary, lineWidth: 0.5)
                    )
                    .disabled(!selectionState.canStyle)
                } else {
                    // iOS 16以下版本的菜单实现
                    Menu {
                        ForEach(StyleContext.StyleCases, id: \.self) { styleContext in
                            Button(action: { observedWebView.selectedWebView?.replaceStyle(selectionState.style, with: styleContext) }) {
                                Text(styleContext.name)
                                    .font(.system(size: styleContext.fontSize))
                            }
                        }
                    } label: {
                        Text(selectionState.style.name)
                            .frame(width: 72, height: toolbarStyle.buttonHeight(), alignment: .center)
                            .foregroundColor(theme.jyxqPrimary)
                    }
                    .menuStyle(.borderlessButton)   // iOS14后已弃用
                    .frame(width: 72, height: toolbarStyle.buttonHeight())
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        )
                        .stroke(theme.jyxqPrimary, lineWidth: 0.5)
                    )
                    .disabled(!selectionState.canStyle)
                }
                if !contents.listType.isEmpty || contents.dent {
                    Divider().frame(height: 20)
                }
            }

            // 列表类型按钮
            ForEach(contents.listType, id: \.self) { type in
                switch type {
                case .bullet:
                    // 项目符号列表按钮
                    ToolbarImageButton(
                        systemName: "list.bullet",
                        action: { observedWebView.selectedWebView?.toggleListItem(type: .UL) },
                        active: Binding<Bool>(get: { selectionState.isInListItem && selectionState.list == .UL }, set: { _ = $0 }),
                        activeColor: theme.jyxqPrimary,
                        onHover: { over in hoverLabel = Text(over ? "Bullets" : "Paragraph Style") }
                    )
                case .number:
                    // 数字列表按钮
                    ToolbarImageButton(
                        systemName: "list.number",
                        action: { observedWebView.selectedWebView?.toggleListItem(type: .OL) },
                        active: Binding<Bool>(get: { selectionState.isInListItem && selectionState.list == .OL }, set: { _ = $0 }),
                        activeColor: theme.jyxqPrimary,
                        onHover: { over in hoverLabel = Text(over ? "Numbers" : "Paragraph Style") }
                    )
                }
            }

            // 缩进控制按钮
            if contents.dent {
                // 增加缩进按钮
                ToolbarImageButton(
                    systemName: "increase.quotelevel",
                    action: { observedWebView.selectedWebView?.indent() },
                    active: Binding<Bool>(get: { selectionState.quote }, set: { _ = $0 }),
                    activeColor: theme.jyxqPrimary,
                    onHover: { over in hoverLabel = Text(over ? "Indent" : "Paragraph Style") }
                )
                // 减少缩进按钮
                ToolbarImageButton(
                    systemName: "decrease.quotelevel",
                    action: { observedWebView.selectedWebView?.outdent() },
                    active: Binding<Bool>(get: { selectionState.quote }, set: { _ = $0 }),
                    activeColor: theme.jyxqPrimary,
                    onHover: { over in hoverLabel = Text(over ? "Outdent" : "Paragraph Style") }
                )
            }
        }
        .frame(height: height)
    }
    
}

// 预览提供者
struct StyleToolbar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            HStack {
                StyleToolbar()
                    .environmentObject(ToolbarStyle.compact)
                Spacer()
            }
            HStack {
                StyleToolbar()
                    .environmentObject(ToolbarStyle.labeled)
                Spacer()
            }
            Spacer()
        }
    }
}
