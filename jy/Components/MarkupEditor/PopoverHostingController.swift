//
//  PopoverHostingController.swift
//  MarkupEditor
//
//  Modeled after https://pspdfkit.com/blog/2022/presenting-popovers-on-iphone-with-swiftui/
//  Modified by Steven G. Harris
//

import SwiftUI

// PopoverHostingController类用于在iOS设备上展示弹出窗口
// 泛型类型V必须遵循View协议
class PopoverHostingController<V>: UIHostingController<V>, UIPopoverPresentationControllerDelegate where V:View {
    // 用于控制弹出窗口显示状态的绑定变量
    var isPresented: Binding<Bool>
    
    // 初始化方法，接收根视图和显示状态绑定
    init(rootView: V, isPresented: Binding<Bool>) {
        self.isPresented = isPresented
        super.init(rootView: rootView)
    }
    
    // 必需的初始化方法，但这里不支持从storyboard或xib加载
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 视图加载完成后的设置
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 计算并设置弹出窗口的首选大小
        let size = sizeThatFits(in: UIView.layoutFittingExpandedSize)
        preferredContentSize = size
    }
    
    // 设置弹出窗口的展示样式
    // 返回.none表示使用默认的弹出窗口样式
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    // 当弹出窗口被关闭时的回调方法
    // 更新isPresented状态为false
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        isPresented.wrappedValue = false
    }
}
