//
//  View+Modifiers.swift
//  MarkupEditor
//
//  参考自 https://pspdfkit.com/blog/2022/presenting-popovers-on-iphone-with-swiftui/
//

import SwiftUI

extension View {
    
    /// 强制显示弹出框的视图修饰器
    /// - Parameters:
    ///   - isPresented: 控制弹出框显示状态的绑定值
    ///   - rect: 弹出框的锚点矩形区域
    ///   - arrowEdge: 弹出框箭头指向的边缘
    ///   - content: 弹出框的内容视图
    /// - Returns: 修改后的视图
    @MainActor public func forcePopover<Content>(
        isPresented: Binding<Bool>,
        at rect: CGRect? = nil,
        arrowEdge: Edge? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content : View {
        #if targetEnvironment(macCatalyst)
        // 在macCatalyst环境下，标准的.popover可以正常工作，而ForcePopoverModifier会在整个屏幕上显示
        guard let rect else {
            // 如果没有提供rect参数，使用默认的popover
            return popover(
                isPresented: isPresented,
                content: content
            )
        }
        guard let arrowEdge else {
            // 如果没有提供arrowEdge参数，只使用rect参数
            return popover(
                isPresented: isPresented,
                attachmentAnchor: .rect(.rect(rect)),
                content: content
            )
        }
        // 使用所有提供的参数
        return popover(
            isPresented: isPresented,
            attachmentAnchor: .rect(.rect(rect)),
            arrowEdge: arrowEdge,
            content: content
        )
        #else
        // 在非macCatalyst环境下，使用自定义的ForcePopoverModifier
        modifier(
            ForcePopoverModifier(
                isPresented: isPresented,
                at: rect,
                arrowEdge: arrowEdge,
                content: content)
        )
        #endif
    }
}
