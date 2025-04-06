//
//  LabeledToolbar.swift
//  MarkupEditor
//
//  Created by Steven Harris on 4/29/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

// 标准的工具栏显示方式，在上方显示标签。通常使用ToolbarImageButtons作为其内容。
public struct LabeledToolbar<Content: View>: View {
    // 环境对象，用于控制工具栏样式
    @EnvironmentObject private var toolbarStyle: ToolbarStyle
    // 工具栏标签
    private let label: Text
    // 工具栏内容
    private let content: Content
    
    // 初始化方法，接收标签和内容构建器
    public init(label: Text, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }
    
    public var body: some View {
        // 根据工具栏样式进行不同的布局
        switch toolbarStyle.style {
        case .labeled:
            // 带标签的垂直布局
            VStack(spacing: 4) {
                // 标签文本，使用轻量级小字体
                label
                    .font(.system(size: 10, weight: .light))
                // 水平排列的内容区域
                HStack (alignment: .bottom) {
                    content
                }
                .padding([.bottom], 2)
                // 以下手势修复了按钮只能部分点击的问题，同时保留了hover效果
                .gesture(TapGesture(), including: .subviews)
            }
        case .compact:
            // 紧凑模式下的水平布局
            HStack(alignment: .center) {
                content
            }
            .padding([.top, .bottom], 2)
            // 以下手势修复了按钮只能部分点击的问题，同时保留了hover效果
            .gesture(TapGesture(), including: .subviews)
        }
    }
}

// 预览提供者，用于在Xcode中预览组件效果
struct LabeledToolbar_Previews: PreviewProvider {
    static var previews: some View {
        // 垂直布局容器
        VStack(alignment: .leading) {
            // 紧凑模式预览
            HStack {
                LabeledToolbar(label: Text("Test Label")) {
                    ToolbarImageButton(
                        systemName: "square.and.arrow.up.fill",
                        action: { print("up") }
                    )
                    ToolbarImageButton(
                        systemName: "square.and.arrow.down.fill",
                        action: { print("down") }
                    )
                }
                .environmentObject(ToolbarStyle.compact)
                Spacer()
            }
            // 带标签模式预览
            HStack {
                LabeledToolbar(label: Text("Test Label")) {
                    ToolbarImageButton(
                        systemName: "square.and.arrow.up.fill",
                        action: { print("up") }
                    )
                    ToolbarImageButton(
                        systemName: "square.and.arrow.down.fill",
                        action: { print("down") }
                    )
                }
                .environmentObject(ToolbarStyle.labeled)
                Spacer()
            }
            Spacer()
        }
    }
}
