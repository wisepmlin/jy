//
//  CorrectionToolbar.swift
//  MarkupEditor
//
//  Created by Steven Harris on 4/7/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

/// The toolbar for undo and redo.
// 导入SwiftUI框架，用于构建用户界面

// 定义一个用于撤销和重做操作的工具栏结构体
public struct CorrectionToolbar: View {
    @Environment(\.theme) private var theme
    // 观察WebView的状态变化
    @ObservedObject private var observedWebView: ObservedWebView = MarkupEditor.observedWebView
    // 用于存储悬停标签的状态
    @State private var hoverLabel: Text = Text("Correction")
    
    // 定义视图的主体内容
    public var body: some View {
        // 创建一个带标签的工具栏
        LabeledToolbar(label: hoverLabel) {
            // 添加撤销按钮
            ToolbarImageButton(
                systemName: "arrow.uturn.backward",  // 使用系统提供的后退箭头图标
                action: { observedWebView.selectedWebView?.undo() },  // 点击时执行撤销操作
                activeColor: theme.jyxqPrimary,
                onHover: { over in hoverLabel = Text(over ? "Undo" : "Correction") }  // 鼠标悬停时更新标签文本
            )
            // 添加重做按钮
            ToolbarImageButton(
                systemName: "arrow.uturn.forward",  // 使用系统提供的前进箭头图标
                action: { observedWebView.selectedWebView?.redo() },  // 点击时执行重做操作
                activeColor: theme.jyxqPrimary,
                onHover: { over in hoverLabel = Text(over ? "Redo" : "Correction") }  // 鼠标悬停时更新标签文本
            )
        }
    }
}

// 预览提供者，用于在Xcode预览画布中显示工具栏
struct CorrectionToolbar_Previews: PreviewProvider {
    static var previews: some View {
        // 创建垂直堆栈布局
        VStack(alignment: .leading) {
            // 使用紧凑样式显示工具栏
            HStack {
                CorrectionToolbar()
                    .environmentObject(ToolbarStyle.compact)
                Spacer()
            }
            // 使用带标签样式显示工具栏
            HStack {
                CorrectionToolbar()
                    .environmentObject(ToolbarStyle.labeled)
                Spacer()
            }
            Spacer()
        }
    }
}
