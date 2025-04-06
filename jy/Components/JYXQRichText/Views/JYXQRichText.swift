//
//  RichText.swift
//
//
//  创建者: 이웅재(NuPlay) 创建于 2021/07/26.
//  项目地址: https://github.com/NuPlay/RichText

import SwiftUI

public struct JYXQRichText: View {
    @Environment(\.theme) private var theme
    // 动态高度状态变量
    @State private var dynamicHeight: CGFloat = .zero
    
    // HTML内容
    let html: String
    // 配置项
    var configuration: Configuration
    // 占位视图
    var placeholder: AnyView?
    
    // 初始化方法
    public init(html: String, configuration: Configuration = .init(), placeholder: AnyView? = nil) {
        self.html = html
        self.configuration = configuration
        self.placeholder = placeholder
    }

    public var body: some View {
        WebView(width: UIScreen.main.bounds.width - 16,
                dynamicHeight: $dynamicHeight,
                html: html,
                configuration: configuration)
        .overlay {
            // 当高度为0时显示占位视图
            if self.dynamicHeight == 0 {
                placeholder
            }
        }
        .frame(height: dynamicHeight)
        .frame(minHeight: 300, alignment: .top)
        .background(theme.background.cornerRadius(theme.minCornerRadius))
    }
}
