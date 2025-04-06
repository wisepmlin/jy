import SwiftUI

// MARK: - Theme Styles
// MARK: - 文章详情样式
struct ArticleDetailStyle {
    // 布局相关
    let avatarSize: CGFloat
    let headerSpacing: CGFloat
    let contentSpacing: CGFloat
    let tagHeight: CGFloat
    let interactionSpacing: CGFloat
    let buttonCornerRadius: CGFloat
    
    // 颜色
    let summaryBackground: Color
    let tagBackground: Color
    let followButtonBackground: Color
    
    // 内边距
    let contentPadding: EdgeInsets
    let tagPadding: EdgeInsets
    let headerPadding: EdgeInsets
}

// MARK: - 主题协议
protocol ThemeProtocol {
    // 颜色
    var jyxqPrimary: Color { get }
    var jyxqPrimary2: Color { get }
    var background: Color { get }
    var gray6Background: Color { get }
    var primaryText: Color { get }
    var subText: Color { get }
    var subText2: Color { get }
    var subText3: Color { get }
    
    // 字体
    var fonts: ThemeFonts { get }
    
    // 间距和圆角
    var spacing: CGFloat { get }
    var defaultCornerRadius: CGFloat { get }
    var minCornerRadius: CGFloat { get }
    
    // 组件样式
    var articleDetail: ArticleDetailStyle { get }
}

// MARK: - 主题字体
struct ThemeFonts {
    // 标题字体
    let title: Font
    let title1: Font
    let title2: Font
    let title3: Font
    
    // 正文字体
    let body: Font
    let subBody: Font
    let caption: Font
    
    // 按钮字体
    let button: Font
    let minButton: Font
    let small: Font
    let min: Font
}

// MARK: - 默认主题
struct DefaultTheme: ThemeProtocol {
    // 颜色定义
    let jyxqPrimary: Color = Color("brandPrimary")
    let jyxqPrimary2: Color = Color("brandPrimary_2")
    let background: Color = Color("car_bg")
    let gray6Background: Color = Color("content_bg")
    let primaryText: Color = Color("textPrimary")
    let subText: Color = Color("subText")
    let subText2: Color = Color("subText2")
    let subText3: Color = Color(uiColor: .quaternaryLabel)
    
    // 字体定义
    let fonts = ThemeFonts(
        title: .system(size: 28, weight: .bold),
        title1: .system(size: 24, weight: .bold),
        title2: .system(size: 20, weight: .semibold),
        title3: .system(size: 17, weight: .medium),
        body: .system(size: 16),
        subBody: .system(size: 15),
        caption: .system(size: 12),
        button: .system(size: 16, weight: .medium),
        minButton: .system(size: 12, weight: .medium),
        small: .system(size: 14),
        min: .system(size: 10)
    )
    
    // 基础间距和圆角
    let spacing: CGFloat = 10
    let defaultCornerRadius: CGFloat = 12
    let minCornerRadius: CGFloat = 6
    
    // 文章详情组件样式
    let articleDetail = ArticleDetailStyle(
        avatarSize: 44,
        headerSpacing: 12,
        contentSpacing: 20,
        tagHeight: 28,
        interactionSpacing: 30,
        buttonCornerRadius: 16,
        
        summaryBackground: Color(uiColor: .secondarySystemBackground),
        tagBackground: Color(uiColor: .secondarySystemFill),
        followButtonBackground: Color(uiColor: .systemOrange),
        
        contentPadding: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        tagPadding: EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12),
        headerPadding: EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    )
}

// MARK: - 主题环境
private struct ThemeKey: EnvironmentKey {
    static let defaultValue: ThemeProtocol = DefaultTheme()
}

extension EnvironmentValues {
    var theme: ThemeProtocol {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

// MARK: - 主题管理器
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    @Published private(set) var current: ThemeProtocol = DefaultTheme()
    
    private init() {}
    
    func updateTheme(_ theme: ThemeProtocol) {
        current = theme
    }
}

// MARK: - 视图扩展
extension View {
    func withTheme(_ theme: ThemeProtocol) -> some View {
        self.environment(\.theme, theme)
    }
    
    func themeFont(_ font: Font) -> some View {
        self.font(font)
    }
}
