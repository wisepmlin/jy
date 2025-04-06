//
//  ContentView.swift
//  jy
//
//  Created by 林晓彬 on 2025/1/24.
//

import SwiftUI

/// 主内容视图
/// 负责管理整个应用的主要布局结构，包括抽屉菜单、标签栏和主要内容区域
struct ContentView: View {
    @Binding var navigationPath: [NavigationType] // 导航路径
    // MARK: - 状态管理
    /// 堆栈深度管理器，用于控制视图层级
    @StateObject private var stackDepthManager = StackDepthManager()
    /// 主题环境变量
    @Environment(\.theme) private var theme
    
    // MARK: - 视图状态
    /// 是否显示模态视图
    @State private var showModal = false
    /// 抽屉菜单是否打开
    @State private var isDrawerOpen = false
    
    @State private var selectedTab: TabItem?
    // MARK: - 常量
    /// 抽屉菜单宽度
    private let drawerWidth: CGFloat = {
        return UIScreen.main.bounds.width * 0.85
    }()
    /// 触感反馈生成器
    private let haptics = UIImpactFeedbackGenerator(style: .soft)
    
    // MARK: - 初始化
    init(navigationPath: Binding< [NavigationType]>) {
        self._navigationPath = navigationPath
        // 配置导航栏外观
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear // 清除阴影线
        UINavigationBar.appearance().standardAppearance = appearance
    }
    
    // MARK: - 主视图
    var body: some View {
        DrawerContainerView(isDrawerOpen: $isDrawerOpen, drawerWidth: drawerWidth) {
            MainContent(selectedTab: $selectedTab, isDrawerOpen: $isDrawerOpen, navigationPath: $navigationPath)
                .environmentObject(stackDepthManager)
                .overlay(alignment: .bottom) {
                    if stackDepthManager.depth == 0 {
                        CustomTabBar(selectedTab: $selectedTab,
                                     showModal: $showModal,
                                     isDrawerOpen: $isDrawerOpen)
                        .transition(
                            .asymmetric(
                                insertion: .offset(x: 0, y: 0),
                                removal: .offset(x: 0, y: 120)
                            )
                        )
                    }
                }
        } drawerContent: {
            DrawerMenuView(isDrawerOpen: $isDrawerOpen)
        }
        .tint(theme.primaryText)
        .ignoresSafeArea(.all, edges: .vertical)
        .fullScreenCover(isPresented: $showModal) {
            ModalView()
                .interactiveDismissDisabled()
        }
        .overlay(alignment: .top) {
            NetworkStatusView()
        }
    }
}

#Preview {
    ContentView(navigationPath: .constant([]))
}

/// 主要内容区域
struct MainContent: View {
    @EnvironmentObject private var stackDepthManager: StackDepthManager
    let tab = TabItem.JYXQTab
    @Binding var selectedTab: TabItem?
    @Binding var isDrawerOpen: Bool
    @Binding var navigationPath: [NavigationType] // 导航路径
    /// 当前选中的标签页索引
   
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(isDrawerOpen: $isDrawerOpen, navigationPath: $navigationPath)
                .environmentObject(stackDepthManager)
                .toolbar(.hidden, for: .tabBar)
                .tag(tab[0])
            SquareView()
                .environmentObject(stackDepthManager)
                .toolbar(.hidden, for: .tabBar)
                .tag(tab[1])
            QAView()
                .environmentObject(stackDepthManager)
                .toolbar(.hidden, for: .tabBar)
                .tag(tab[2])
            ProfileView()
                .environmentObject(stackDepthManager)
                .toolbar(.hidden, for: .tabBar)
                .tag(tab[3])
        }
        .ignoresSafeArea(.all, edges: .vertical)
    }
}
