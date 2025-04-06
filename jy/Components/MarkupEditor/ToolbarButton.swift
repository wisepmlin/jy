//
//  ToolbarButton.swift
//  MarkupEditor
//
//  Created by Steven Harris on 4/5/21.
//  Copyright © 2021 Steven Harris. All rights reserved.
//

import SwiftUI

// 一个通常在工具栏中使用系统图像的方形按钮
//
// 这些圆角矩形按钮显示文本和轮廓采用activeColor（默认为.accentColor），
// 背景色为UIColor.systemBackground。当激活时，文本和背景会切换。
public struct ToolbarImageButton<Content: View>: View {
    // 按钮的图像内容
    private let image: Content
    // 系统图标名称
    private let systemName: String?
    // 按钮点击事件处理
    private let action: ()->Void
    // 按钮激活状态绑定
    @Binding private var active: Bool
    // 激活状态的颜色
    private let activeColor: Color
    // 悬停事件处理
    private let onHover: ((Bool)->Void)?
    
    public var body: some View {
        Button(action: action, label: {
            label()
                .frame(width: MarkupEditor.toolbarStyle.buttonHeight(), height: MarkupEditor.toolbarStyle.buttonHeight())
        })
        .onHover { over in onHover?(over) }
        // 对于MacOS按钮（针对Mac优化的界面），指定.contentShape
        // 修复了一些在此视图下方显示的SwiftUI视图中的不稳定问题
        // 参考: https://stackoverflow.com/a/67377002/8968411
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .buttonStyle(ToolbarButtonStyle(active: $active, activeColor: activeColor))
    }

    // 使用内容初始化按钮。查看Content == EmptyView的扩展以了解systemName样式初始化
    public init(action: @escaping ()->Void,
                active: Binding<Bool> = .constant(false),
                activeColor: Color = .accentColor,
                onHover: ((Bool)->Void)? = nil, @ViewBuilder
                content: ()->Content) {
        self.systemName = nil
        self.image = content()
        self.action = action
        _active = active
        self.activeColor = activeColor
        self.onHover = onHover
    }
    
    // 返回标签视图
    private func label() -> AnyView {
        // 根据样式返回从内容派生的图像或适当大小的systemName图像
        if systemName == nil {
            return AnyView(image)
        } else {
            return AnyView(Image(systemName: systemName!).imageScale(.large))
        }
    }
}

// 当Content为EmptyView时的ToolbarImageButton扩展
extension ToolbarImageButton where Content == EmptyView {
    
    // 使用系统图像初始化按钮，即使传入内容也会被覆盖。用于不带内容块的使用场景
    public init(systemName: String, action: @escaping ()->Void, active: Binding<Bool> = .constant(false), activeColor: Color = .accentColor, onHover: ((Bool)->Void)? = nil, @ViewBuilder content: ()->Content = { EmptyView() }) {
        self.systemName = systemName
        self.image = content()
        self.action = action
        _active = active
        self.activeColor = activeColor
        self.onHover = onHover
    }
}

// 工具栏文本按钮
public struct ToolbarTextButton: View {
    // 按钮标题
    let title: String
    // 按钮点击事件处理
    let action: ()->Void
    // 按钮宽度
    let width: CGFloat?
    // 按钮激活状态绑定
    @Binding var active: Bool
    // 激活状态的颜色
    let activeColor: Color
    
    public var body: some View {
        Button(action: action, label: {
            Text(title)
                .frame(width: width, height: MarkupEditor.toolbarStyle.buttonHeight())
                .padding(.horizontal, 4)
                .background(
                    RoundedRectangle(
                        cornerRadius: 20,
                        style: .continuous
                    )
                    .stroke(Color.accentColor)
                    .background(Color(UIColor.systemGray6))
                )
        })
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .buttonStyle(ToolbarButtonStyle(active: $active, activeColor: activeColor))
    }
    
    // 初始化工具栏文本按钮
    public init(title: String, action: @escaping ()->Void, width: CGFloat? = nil, active: Binding<Bool> = .constant(false), activeColor: Color = .accentColor) {
        self.title = title
        self.action = action
        self.width = width
        _active = active
        self.activeColor = activeColor
    }
}

// 工具栏按钮样式
public struct ToolbarButtonStyle: ButtonStyle {
    // 按钮激活状态绑定
    @Binding var active: Bool
    // 激活状态的颜色
    let activeColor: Color
    
    // 初始化工具栏按钮样式
    public init(active: Binding<Bool>, activeColor: Color) {
        _active = active
        self.activeColor = activeColor
    }
    
    // 创建按钮视图
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .cornerRadius(20)
            .foregroundColor(active ? Color(UIColor.systemBackground) : activeColor)
            .overlay(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .stroke(activeColor, lineWidth: 0.5)
            )
            .background(
                RoundedRectangle(
                    cornerRadius: 20,
                    style: .continuous
                )
                .fill(active ? activeColor: Color.clear)
            )
    }
}
