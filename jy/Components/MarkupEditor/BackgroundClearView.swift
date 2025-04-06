//
//  BackgroundClearView.swift
//  MarkupEditor
//
//  Created by Steven Harris on 8/30/22.
//  Modeled on https://stackoverflow.com/a/63745596
//

import SwiftUI

// 定义一个遵循UIViewRepresentable协议的结构体，用于创建一个背景透明的视图
struct BackgroundClearView: UIViewRepresentable {
    // 创建UIView实例
    func makeUIView(context: Context) -> UIView {
        // 初始化一个UIView
        let view = UIView()
        // 在主线程异步设置视图的背景色为透明
        DispatchQueue.main.async {
            // 通过superview?.superview获取父视图的父视图，并将其背景色设置为透明
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    // 更新UIView的方法（此处为空实现，因为不需要更新逻辑）
    func updateUIView(_ uiView: UIView, context: Context) {}
}
