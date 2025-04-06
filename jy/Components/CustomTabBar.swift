//
//  CustomTabBar.swift
//  jy
//
//  Created by 林晓彬 on 2025/1/28.
//
import SwiftUI

/// 自定义底部标签栏组件
struct CustomTabBar: View {
    // MARK: - Properties
    @Binding var selectedTab: TabItem?
    @Binding var showModal: Bool
    @Binding var isDrawerOpen: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var animation
    
    // MARK: - Constants
    private let tabBarHeight: CGFloat = 44
    private let centerButtonSize: CGFloat = 52
    private let centerButtonOffset: CGFloat = 0
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // 背景形状
            TabBarShape()
                .fill(Material.bar)
                .ignoresSafeArea()
            
            // 标签按钮布局
            HStack(spacing: 10) {
                // 首页标签
                TabBarButton(
                    image: "house.fill",
                    title: "首页",
                    isSelected: selectedTab?.id == "home"
                ) {
                    selectedTab = TabItem.JYXQTab[0]
                }
                
                // 金圈标签
                TabBarButton(
                    image: "square.grid.2x2.fill",
                    title: "金圈",
                    isSelected: selectedTab?.id == "circle"
                ) {
                    selectedTab = TabItem.JYXQTab[1]
                }
                
                // 中心按钮
                CenterButton(
                    showModal: $showModal,
                    size: centerButtonSize,
                    offset: centerButtonOffset
                )
                
                // 问答标签
                TabBarButton(
                    image: "questionmark.circle.fill",
                    title: "咨询",
                    isSelected: selectedTab?.id == "consult"
                ) {
                    selectedTab = TabItem.JYXQTab[2]
                }
                
                // 我的标签
                TabBarButton(
                    image: "person.fill",
                    title: "我的",
                    isSelected: selectedTab?.id == "my"
                ) {
                    selectedTab = TabItem.JYXQTab[3]
                }
            }
            .frame(height: tabBarHeight)
            .trackLifecycle(onAppear: {
                selectedTab = TabItem.JYXQTab[0]
            })
        }
        .frame(height: tabBarHeight)
    }
}

// MARK: - 子视图组件
/// 标签按钮组件
struct TabBarButton: View {
    // MARK: - Properties
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Namespace private var animation
    
    let image: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: image)
                    .themeFont(theme.fonts.title2)
                Text(title)
                    .themeFont(theme.fonts.min)
            }
        }
        .foregroundColor(isSelected ? theme.jyxqPrimary : (colorScheme == .dark ? .gray : theme.subText2))
        .frame(maxWidth: .infinity)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

/// 中心按钮组件
private struct CenterButton: View {
    @Environment(\.theme) private var theme
    @Binding var showModal: Bool
    let size: CGFloat
    let offset: CGFloat
    
    private struct AnimationState {
        var isPressed = false
    }
    
    // 提取动画参数为常量
    private let springAnimation = Animation.spring(response: 0.3, dampingFraction: 0.6)
    private let pressAnimation = Animation.easeInOut(duration: 0.2)
    
    var body: some View {
        ZStack {
            // 背景圆圈
            Circle()
                .fill(Material.bar)
            
            // 中心按钮
            Button {
                showModal.toggle()
            } label: {
                Image("bar_ai_icon")
            }
            .padding(4)
        }
        .frame(width: size, height: size)
        .offset(y: offset)
    }
}
