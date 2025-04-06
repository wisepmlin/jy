//
//  InsertToolbar.swift
//  MarkupEditor
//
//  Created by Steven Harris on 3/24/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// 用于创建/编辑链接、图片和表格的工具栏。
///
/// 控制流程说明：按钮操作会调用 `selectedWebView` 中的 `showPluggable[Link/Image/Table]Popover` 方法。
/// 这些方法会进一步调用 MarkupDelegate 的 `show[Link/Image/Table]Popover` 方法。
/// 你可以在你的代理中重写这些方法，用自己的视图替代默认视图。默认情况下，
/// MarkupDelegate 会回调 `selectedWebView.show[Link/Image/Table]Popover` 方法，
/// 该方法会根据所选的插入弹出窗口类型使用 UIKit 或 SwiftUI 方法。这样可以确保
/// InsertToolbar 中的按钮和菜单选择之间的行为一致性，同时为用户提供的展示方式提供灵活性。
public struct InsertToolbar: View {
    @Environment(\.theme) private var theme
    // 选中状态的观察对象
    @ObservedObject private var selectionState: SelectionState = MarkupEditor.selectionState
    // 显示弹出窗口类型的观察对象
    @ObservedObject private var showPopoverType: ShowInsertPopover = MarkupEditor.showInsertPopover
    // 工具栏内容配置
    let contents: InsertContents = MarkupEditor.toolbarContents.insertContents
    // 悬停标签状态
    @State private var hoverLabel: Text = Text("Insert")
    // 表格弹出窗口显示状态
    @State private var showTablePopover: Bool = false
    // 表格行数
    @State private var rows: Int = 0
    // 表格列数
    @State private var cols: Int = 0
    
    public var body: some View {
        LabeledToolbar(label: hoverLabel) {
            // 链接按钮
            if contents.link {
                ToolbarImageButton(
                    systemName: "link",
                    action: { MarkupEditor.selectedWebView?.showPluggableLinkPopover() },
                    active: Binding<Bool>(get: { selectionState.isInLink }, set: { _ = $0 }),
                    activeColor: theme.jyxqPrimary,
                    onHover: { over in if over { hoverLabel = Text("Insert Link") } else { hoverLabel = Text("Insert") } }
                )
            }
            // 图片按钮
            if contents.image {
                ToolbarImageButton(
                    systemName: "photo",
                    action: { MarkupEditor.selectedWebView?.showPluggableImagePopover() },
                    active: Binding<Bool>(get: { selectionState.isInImage }, set: { _ = $0 }),
                    activeColor: theme.jyxqPrimary,
                    onHover: { over in if over { hoverLabel = Text("Insert Image") } else { hoverLabel = Text("Insert") } }
                )
            }
            // 表格按钮
            if contents.table {
                ToolbarImageButton(
                    systemName: "squareshape.split.3x3",
                    action: { MarkupEditor.selectedWebView?.showPluggableTablePopover() },
                    active: Binding<Bool>(get: { selectionState.isInTable }, set: { _ = $0 }),
                    activeColor: theme.jyxqPrimary,
                    onHover: { over in if over { hoverLabel = Text(selectionState.isInTable ? "Edit Table" : "Insert Table") } else { hoverLabel = Text("Insert") } }
                )
                .forcePopover(isPresented: $showTablePopover) {
                    // 传递 $showTablePopover 以便视图可以自行关闭
                    if selectionState.isInTable {
                        // 如果在表格中，显示表格工具栏
                        TableToolbar(showing: $showTablePopover)
                            .environmentObject(MarkupEditor.toolbarStyle)
                            .onDisappear {
                                MarkupEditor.showInsertPopover.type = nil
                            }
                    } else {
                        // 如果不在表格中，显示表格尺寸选择器
                        TableSizer(rows: $rows, cols: $cols, showing: $showTablePopover)
                            .onAppear() {
                                rows = 0
                                cols = 0
                            }
                            .onDisappear() {
                                if rows > 0 && cols > 0 {
                                    MarkupEditor.selectedWebView?.insertTable(rows: rows, cols: cols)
                                }
                                MarkupEditor.showInsertPopover.type = nil
                            }
                    }
                }
            }
        }
        // 监听弹出窗口类型变化
        .onChange(of: showPopoverType.type) { oldType, newType in
            switch newType {
            case .table:
                showTablePopover = true
            case .link, .image, .none:
                showTablePopover = false
            }
        }
    }
    
}

// 预览提供者
struct InsertToolbar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            HStack {
                InsertToolbar()
                    .environmentObject(ToolbarStyle.compact)
                Spacer()
            }
            HStack {
                InsertToolbar()
                    .environmentObject(ToolbarStyle.labeled)
                Spacer()
            }
            Spacer()
        }
    }
}
