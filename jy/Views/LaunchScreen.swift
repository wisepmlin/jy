import SwiftUI

/// 启动屏幕动画组件
/// 负责展示应用启动时的Logo动画效果，包括光晕、描边和缩放动画
struct LaunchScreen: View {
    // MARK: - 状态属性
    /// 主题环境变量
    @Environment(\.theme) private var theme
    
    // MARK: - 动画状态
    @State private var textOpacity: Double = 0
    @State private var subtitleOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.9
    
    // MARK: - 动画参数
    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    private let animationDuration: Double = 1.2
    
    var body: some View {
        ZStack {
            // 渐变背景
            LinearGradient(colors: [Color("ffb300"), theme.jyxqPrimary], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ZStack(alignment: .bottom) {
                // Logo动画
                Image("action_logo")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .padding(.bottom, UIScreen.main.bounds.height * 0.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .scaleEffect(logoScale)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: logoScale)
                
                // 文字动画
                VStack(spacing: 8) {
                    Text("金鹰星球・成为精英")
                        .customFont(fontSize: 24)
                        .foregroundStyle(theme.background)
                        .kerning(1.5)
                        .opacity(textOpacity)
                    
                    Text("———企业管理的高赋值全能智能参谋———")
                        .themeFont(theme.fonts.min)
                        .foregroundStyle(theme.background)
                        .kerning(0.3)
                        .opacity(subtitleOpacity)
                }
                .padding(34)
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .onAppear {
            // 启动动画序列
            withAnimation(.easeOut(duration: 0.8)) {
                logoScale = 1.0
            }
            
            withAnimation(.easeIn(duration: 0.6).delay(0.3)) {
                textOpacity = 1
            }
            
            withAnimation(.easeIn(duration: 0.6).delay(0.6)) {
                subtitleOpacity = 0.5
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
