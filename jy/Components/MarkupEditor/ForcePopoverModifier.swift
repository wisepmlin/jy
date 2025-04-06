//
//  ForcePopoverModifier.swift
//  MarkupEditor
//
//  参考自 https://pspdfkit.com/blog/2022/presenting-popovers-on-iphone-with-swiftui/
//  由 Steven G. Harris 修改
//

import SwiftUI

// @MainActor 确保所有UI操作都在主线程执行
@MainActor
struct ForcePopoverModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    
    // 用于控制弹出框是否显示的绑定变量
    let isPresented: Binding<Bool>
    // 用于生成弹出框内容的闭包
    let content: () -> PopoverContent
    // 弹出框的源矩形区域，用于定位弹出框的位置
    let sourceRect: CGRect
    // 弹出框箭头的方向
    let arrowEdge: Edge
    // 用作弹出框锚点的UIView
    @State private var anchorView = UIView()
    // 当前显示的视图控制器的引用
    @State private var presentedVC: UIViewController?
    
    // 视图主体实现
    func body(content: Content) -> some View {
        if isPresented.wrappedValue {
            presentPopover()
        } else {
            dismissPopover()
        }
        return content
            .background(InternalAnchorView(uiView: anchorView))
    }
    
    // 初始化方法，设置弹出框的基本属性
    init(isPresented: Binding<Bool>, at sourceRect: CGRect? = nil, arrowEdge: Edge? = nil, content: @escaping ()->PopoverContent) {
        self.isPresented = isPresented
        self.content = content
        self.sourceRect = sourceRect ?? CGRect.zero
        self.arrowEdge = arrowEdge ?? .top
    }

    // 显示弹出框的私有方法
    private func presentPopover() {
        // 创建承载弹出框内容的视图控制器
        let hostingController = PopoverHostingController(rootView: content(), isPresented: isPresented)
        // 设置展示样式为弹出框
        hostingController.modalPresentationStyle = .popover
        // 获取弹出框控制器
        guard let popover = hostingController.popoverPresentationController else { return }
        // 设置弹出框的源视图
        popover.sourceView = anchorView
        // 设置弹出框的源矩形
        popover.sourceRect = sourceRect
        // 设置弹出框的代理
        popover.delegate = hostingController
        // TODO: 需要实现箭头方向的功能
        // 获取最近的视图控制器
        guard let sourceVC = anchorView.closestVC() else { return }
        // 展示弹出框
        sourceVC.present(hostingController, animated: true) {
            // 当弹出框从键盘输入附件视图显示时，sourceVC.presentedViewController 将为空
            // 实际的 presentingViewController 是 UIInputWindowController
            // 试图使用 nearestVC 从 sourceVC 向上查找链来重新定位它以便稍后关闭将返回错误的 ViewController
            // 因此，在这里直接保留 presentedVC，在键盘输入附件视图的情况下，它与 sourceVC 不同
            presentedVC = hostingController.presentingViewController?.presentedViewController
        }
    }
    
    // 关闭弹出框的私有方法
    private func dismissPopover() {
        // 当弹出框未显示时调用 dismissPopover 是正常的
        // (即 presentedVC 为 nil 时)，例如当 TableToolbar 显示但用户
        // 尚未显示 TableSizer 时的情况
        guard let presentedVC else { return }
        // 关闭弹出框并清除引用
        presentedVC.dismiss(animated: true) {
            self.presentedVC = nil
        }
    }
    
    // 内部锚点视图结构体，用于在SwiftUI中表示UIKit视图
    private struct InternalAnchorView: UIViewRepresentable {
        // 定义UIView类型
        typealias UIViewType = UIView
        // 存储UIView实例
        let uiView: UIView
        
        // 创建UIView的方法
        func makeUIView(context: Self.Context) -> Self.UIViewType {
            uiView
        }
        
        // 更新UIView的方法（此处不需要实现具体更新逻辑）
        func updateUIView(_ uiView: Self.UIViewType, context: Self.Context) { }
    }
}
