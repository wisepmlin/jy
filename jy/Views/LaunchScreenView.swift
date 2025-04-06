import SwiftUI

/// 启动屏幕视图
/// 负责展示应用启动时的过渡动画，包括Logo动画和内容视图的切换效果
struct LaunchScreenView: View {
    // MARK: - 环境与状态属性
    
    /// 主题环境变量
    @Environment(\.theme) private var theme
    /// 控制是否显示主内容视图
    @State private var isLaunchScreenView = true
    /// 控制Logo动画的状态
    @State private var logoScale: CGFloat = 1
    @State private var logoOpacity: Double = 0
    @Binding var navigationPath: [NavigationType] // 导航路径
    
    // MARK: - 动画参数
    
    /// Logo动画的时长和曲线参数
    private let initialDelay: Double = 0.3
    private let logoAnimationDuration: Double = 1.2
    private let logoDampingFraction: Double = 0.7
    private let logoBlendDuration: Double = 0.35
    private let contentTransitionDuration: Double = 0.35
    
    var body: some View {
        Group {
            // 内容层
            if isLaunchScreenView {
                LaunchScreen()
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.00)),
                            removal: .opacity.combined(with: .scale(scale: 1.5))
                        )
                    )
            } else {
                ContentView(navigationPath: $navigationPath)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 1.05)).combined(with: .opacity),
                            removal: .opacity.combined(with: .scale(scale: 0.98))
                        )
                    )
            }
        }
        // 控制整体视图切换的动画效果
        .onAppear {
            // 第一阶段：Logo渐入动画
            withAnimation(.easeOut(duration: logoAnimationDuration).delay(initialDelay)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }
            
            // 第二阶段：Logo消失和背景淡出动画
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: contentTransitionDuration)) {
                    isLaunchScreenView = false
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView(navigationPath: .constant([]))
}
