//
//  Blur.swift
//  MarkupEditor
//
//  Created by Steven Harris on 7/11/21.
//

import SwiftUI

/// 模糊效果视图结构体
struct Blur: UIViewRepresentable {
    /// 模糊效果样式，默认为系统材质效果
    var style: UIBlurEffect.Style = .systemMaterial
    
    /// 创建UIKit视图
    /// - Parameter context: 上下文环境
    /// - Returns: 返回带有模糊效果的视图
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    /// 更新UIKit视图
    /// - Parameters:
    ///   - uiView: 需要更新的视图
    ///   - context: 上下文环境
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
