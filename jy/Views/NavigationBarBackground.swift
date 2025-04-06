import SwiftUI

struct NavigationBarBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.theme) private var theme
    let image: Image
    
    func body(content: Content) -> some View {
        ZStack {
            content
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if UIDevice.current.userInterfaceIdiom != .pad {
                        Image("topbar_bg")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: geometry.safeAreaInsets.top + 44)
                            .ignoresSafeArea()
                            .opacity(colorScheme == .dark ? 0.75 : 1)
                    }
                    Spacer()
                }
                .frame(height: geometry.safeAreaInsets.top + 44)
                .allowsHitTesting(false)  // 添加这一行，使整个 VStack 不接收点击事件
            }
            .allowsHitTesting(false)  // 添加这一行，使 GeometryReader 不接收点击事件
        }
    }
}

extension View {
    func navigationBarBackground(_ image: Image) -> some View {
        modifier(NavigationBarBackground(image: image))
    }
    
    func navigationBarBackground() -> some View {
        let image = Image("nav_background")
        return modifier(NavigationBarBackground(image: image))
    }
}
