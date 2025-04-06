//
//  TableToolbar.swift
//  MarkupEditor
//
//  Created by Steven Harris on 4/8/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// 用于创建和编辑表格的工具栏
public struct TableToolbar: View {
    @Environment(\.theme) private var theme
    // 工具栏样式环境对象
    @EnvironmentObject private var toolbarStyle: ToolbarStyle
    // 观察WebView的状态
    @ObservedObject private var observedWebView: ObservedWebView = MarkupEditor.observedWebView
    // 观察选择状态
    @ObservedObject private var selectionState: SelectionState = MarkupEditor.selectionState
    // 表格内容配置
    private var contents: TableContents { MarkupEditor.toolbarContents.tableContents }
    // 悬停标签状态
    @State private var addHoverLabel: Text = Text("添加")
    @State private var deleteHoverLabel: Text = Text("删除")
    @State private var borderHoverLabel: Text = Text("描边")
    // 控制工具栏显示状态的绑定
    @Binding var showing: Bool
    
    public var body: some View {
        // 水平滚动视图
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                // 添加操作工具栏
                LabeledToolbar(label: addHoverLabel) {
                    // 添加表头按钮
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.addHeader() },
                        activeColor: theme.jyxqPrimary,
                        onHover: { over in addHoverLabel = Text(over ? "Add Header" : "Add") }
                    ) {
                        AddHeader()
                    }
                    .disabled(!selectionState.isInTable || selectionState.header)
                    
                    // 在下方添加行按钮
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.addRow(.after) },
                        activeColor: theme.jyxqPrimary,
                        onHover: { over in addHoverLabel = Text(over ? "Add Row Below" : "Add") }
                    ) {
                        AddRow(direction: .after)
                    }
                    .disabled(!selectionState.isInTable)
                    
                    // 在上方添加行按钮
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.addRow(.before) },
                        activeColor: theme.jyxqPrimary,
                        onHover: { over in addHoverLabel = Text(over ? "Add Row Above" : "Add") }
                    ) {
                        AddRow(direction: .before)
                    }
                    .disabled(!selectionState.isInTable || selectionState.thead)
                    
                    // 在右侧添加列按钮
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.addCol(.after) },
                        activeColor: theme.jyxqPrimary,
                        onHover: { over in addHoverLabel = Text(over ? "Add Column After" : "Add") }
                    ) {
                        AddCol(direction: .after)
                    }
                    .disabled(!selectionState.isInTable || (selectionState.thead && selectionState.colspan))
                    
                    // 在左侧添加列按钮
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.addCol(.before) },
                        activeColor: theme.jyxqPrimary,
                        onHover: { over in addHoverLabel = Text(over ? "Add Column Before" : "Add") }
                    ) {
                        AddCol(direction: .before)
                    }
                    .disabled(!selectionState.isInTable || (selectionState.thead && selectionState.colspan))
                }
                
                // 删除操作工具栏
                LabeledToolbar(label: deleteHoverLabel) {
                    // 删除行按钮
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.deleteRow() },
                        activeColor: theme.jyxqPrimary,
                        onHover: { over in deleteHoverLabel = Text(over ? "Delete Row" : "Delete") }
                    ) {
                        DeleteRow()
                    }
                    .disabled(!selectionState.isInTable)
                    
                    // 删除列按钮
                    ToolbarImageButton(
                        action: { observedWebView.selectedWebView?.deleteCol() },
                        activeColor: theme.jyxqPrimary,
                        onHover: { over in deleteHoverLabel = Text(over ? "Delete Column" : "Delete") }
                    ) {
                        DeleteCol()
                    }
                    .disabled(!selectionState.isInTable || (selectionState.thead && selectionState.colspan))
                    
                    // 删除表格按钮
                    ToolbarImageButton(
                        action: {
                            showing = false
                            observedWebView.selectedWebView?.focus {
                                observedWebView.selectedWebView?.deleteTable()
                            }
                        },
                        activeColor: theme.jyxqPrimary,
                        onHover: { over in deleteHoverLabel = Text(over ? "Delete Table" : "Delete") }
                    ) {
                        DeleteTable()
                    }
                    .disabled(!selectionState.isInTable)
                }
                
                // 边框设置工具栏
                if contents.border {
                    LabeledToolbar(label: borderHoverLabel) {
                        // 由于cell是默认值，所以cellActive需要检查isInTable
                        let cellActive = Binding<Bool>(get: { selectionState.isInTable && selectionState.border == .cell }, set: { _ = $0 })
                        let headerActive = Binding<Bool>(get: { selectionState.border == .header }, set: { _ = $0 })
                        let outerActive = Binding<Bool>(get: { selectionState.border == .outer }, set: { _ = $0 })
                        let noneActive = Binding<Bool>(get: { selectionState.border == .none }, set: { _ = $0 })
                        
                        // 单元格边框按钮
                        ToolbarImageButton(
                            action: { observedWebView.selectedWebView?.borderTable(.cell) },
                            active: cellActive,
                            activeColor: theme.jyxqPrimary,
                            onHover: { over in borderHoverLabel = Text(over ? "Cells" : "Border") }
                        ) {
                            BorderIcon(.cell, active: cellActive)
                        }
                        .disabled(!selectionState.isInTable)
                        
                        // 表头边框按钮
                        ToolbarImageButton(
                            action: { observedWebView.selectedWebView?.borderTable(.header) },
                            active: headerActive,
                            activeColor: theme.jyxqPrimary,
                            onHover: { over in borderHoverLabel = Text(over ? "Header" : "Border") }
                        ) {
                            BorderIcon(.header, active: headerActive)
                        }
                        .disabled(!selectionState.isInTable)
                        
                        // 外边框按钮
                        ToolbarImageButton(
                            action: { observedWebView.selectedWebView?.borderTable(.outer) },
                            active: outerActive,
                            activeColor: theme.jyxqPrimary,
                            onHover: { over in borderHoverLabel = Text(over ? "Outer" : "Border") }
                        ) {
                            BorderIcon(.outer, active: outerActive)
                        }
                        .disabled(!selectionState.isInTable)
                        
                        // 无边框按钮
                        ToolbarImageButton(
                            action: { observedWebView.selectedWebView?.borderTable(.none) },
                            active: noneActive,
                            activeColor: theme.jyxqPrimary,
                            onHover: { over in borderHoverLabel = Text(over ? "None" : "Border") }
                        ) {
                            BorderIcon(.none, active: noneActive)
                        }
                        .disabled(!selectionState.isInTable)
                    }
                }
            }
            .frame(height: toolbarStyle.height())
            .padding(12)
            .disabled(observedWebView.selectedWebView == nil || !selectionState.isValid)
        }
        .onTapGesture {}
    }
}

// 预览提供者
struct TableToolbar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading) {
            HStack {
                TableToolbar(showing: .constant(true))
                    .environmentObject(ToolbarStyle.compact)
                Spacer()
            }
            HStack {
                TableToolbar(showing: .constant(true))
                    .environmentObject(ToolbarStyle.labeled)
                Spacer()
            }
            Spacer()
        }
    }
}
