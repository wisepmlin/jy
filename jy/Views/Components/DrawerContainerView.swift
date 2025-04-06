//
//  DrawerContainerView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/21.
//
import SwiftUI

// MARK: - SwiftUI 集成
/// SwiftUI包装器，用于在SwiftUI中使用抽屉容器
/// - 提供了一个可复用的抽屉容器组件
/// - 支持自定义主内容和抽屉内容
/// - 通过Binding实现双向状态同步
/// - 支持动态字体大小适配
@MainActor
struct DrawerContainerView<MainContent: View, DrawerContent: View>: UIViewControllerRepresentable {
    // MARK: - Environment Values
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    // MARK: - Properties
    /// 控制抽屉开关状态的绑定
    @Binding var isDrawerOpen: Bool
    /// 抽屉宽度
    let drawerWidth: CGFloat
    /// 主内容视图构建器
    var mainContent: MainContent
    /// 抽屉内容视图构建器
    var drawerContent:  DrawerContent
    
    init(isDrawerOpen: Binding<Bool>, drawerWidth: CGFloat, mainContent: @escaping () -> MainContent, drawerContent: @escaping () -> DrawerContent) {
        self._isDrawerOpen = isDrawerOpen
        self.drawerWidth = drawerWidth
        self.mainContent = mainContent()
        self.drawerContent = drawerContent()
    }
    
    // MARK: - Coordinator
    /// 协调器类，负责处理视图控制器和SwiftUI视图之间的通信
    class Coordinator: NSObject {
        /// 对父视图的引用
        private var parent: DrawerContainerView?
        
        init(_ parent: DrawerContainerView) {
            self.parent = parent
            super.init()
        }
        
        /// 处理抽屉状态变化
        /// - Parameter isOpen: 抽屉是否打开
        @objc func drawerStateDidChange(_ isOpen: Bool) {
            DispatchQueue.main.async { [parent] in
                withAnimation(.easeInOut) {
                    parent?.isDrawerOpen = isOpen
                }
            }
        }
        
        /// 更新视图控制器的生命周期状态
        @MainActor func updateLifecycle(_ viewController: DrawerContainerViewController) {
            viewController.isViewVisible = true
        }
        
        /// 更新动态字体大小
        @MainActor func updateDynamicTypeSize(_ viewController: DrawerContainerViewController) {
            viewController.currentDynamicTypeSize = .large
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - UIViewControllerRepresentable
    func makeUIViewController(context: UIViewControllerRepresentableContext<DrawerContainerView>) -> DrawerContainerViewController {
        // 创建视图控制器
        let containerVC = createContainerViewController()
        // 配置回调和状态
        configureCallbacks(containerVC, context: context)
        configureInitialState(containerVC, context: context)
        
        // Force navigation bar visibility
        configureNavigationBar(for: containerVC)
        return containerVC
    }
    
    func updateUIViewController(_ uiViewController: DrawerContainerViewController, context: UIViewControllerRepresentableContext<DrawerContainerView>) {
        // 更新状态
        updateViewControllerState(uiViewController, context: context)
        
        // 更新内容
        updateContent(uiViewController)
        
        // 同步抽屉状态
        synchronizeDrawerState(uiViewController)
        
        // Force navigation bar visibility
        configureNavigationBar(for: uiViewController)
    }
    
    // MARK: - 私有辅助方法
    
    /// 创建容器视图控制器
    private func createContainerViewController() -> DrawerContainerViewController {
        let mainVC = UIHostingController(rootView: mainContent)
        let drawerVC = UIHostingController(rootView: drawerContent)
        return DrawerContainerViewController(mainContent: mainVC,
                                           drawerContent: drawerVC,
                                           drawerWidth: drawerWidth)
    }
    
    /// 配置视图控制器的回调
    private func configureCallbacks(_ containerVC: DrawerContainerViewController, context: UIViewControllerRepresentableContext<DrawerContainerView>) {
        containerVC.onDrawerStateChange = { [weak containerVC] isOpen in
            guard let containerVC = containerVC else { return }
            context.coordinator.drawerStateDidChange(isOpen)
            context.coordinator.updateLifecycle(containerVC)
        }
    }
    
    /// 配置初始状态
    private func configureInitialState(_ containerVC: DrawerContainerViewController, context: UIViewControllerRepresentableContext<DrawerContainerView>) {
        
        // 更新生命周期和动态字体大小
        context.coordinator.updateLifecycle(containerVC)
        context.coordinator.updateDynamicTypeSize(containerVC)
        
        configureNavigationBar(for: containerVC)
    }
    
    /// 更新视图控制器状态
    private func updateViewControllerState(_ uiViewController: DrawerContainerViewController, context: UIViewControllerRepresentableContext<DrawerContainerView>) {
        context.coordinator.updateLifecycle(uiViewController)
        context.coordinator.updateDynamicTypeSize(uiViewController)
        
        configureNavigationBar(for: uiViewController)
    }
    
    /// 更新内容视图
    private func updateContent(_ uiViewController: DrawerContainerViewController) {
        if let mainVC = uiViewController.children.first as? UIHostingController<MainContent> {
            mainVC.rootView = mainContent
            mainVC.view.backgroundColor = .clear
        }
        if let drawerVC = uiViewController.children.last as? UIHostingController<DrawerContent> {
            drawerVC.rootView = drawerContent
            drawerVC.view.backgroundColor = .clear
        }
    }
    
    /// 同步抽屉状态
    private func synchronizeDrawerState(_ uiViewController: DrawerContainerViewController) {
        configureNavigationBar(for: uiViewController)
        let isViewVisible = uiViewController.isViewVisible
        if isViewVisible == isDrawerOpen {
            uiViewController.openDrawer(animated: true)
        } else {
            uiViewController.closeDrawer(animated: true)
        }
    }
    
    // MARK: - 类型擦除
    static func dismantleUIViewController(_ uiViewController: DrawerContainerViewController, coordinator: Coordinator) {
        uiViewController.isViewVisible = false
        uiViewController.onDrawerStateChange = nil
    }
    
    /// 配置导航栏
    private func configureNavigationBar(for viewController: UIViewController) {
        if let navigationController = viewController.navigationController {
            navigationController.setNavigationBarHidden(false, animated: false)
            navigationController.navigationBar.isHidden = false
        }
    }
}
