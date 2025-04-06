import SwiftUI

/// 标签项样式修饰器
/// - 处理标签项的字体、颜色、徽章显示等样式
/// - 支持选中状态样式切换
/// - 支持徽章显示（小红点和数字徽章）
struct TabItemStyle: ViewModifier {
    @Environment(\.theme) private var theme
    let isSelected: Bool
    let item: TabItem
    
    func body(content: Content) -> some View {
        content
            .font(theme.fonts.body)
            .foregroundColor(isSelected ? theme.primaryText : theme.subText)
            .fontWeight(isSelected ? .bold : .regular)
            .overlay(alignment: .topTrailing) {
                if item.showBadge {
                    BadgeView(count: item.badgeCount)
                }
            }
    }
}

/// 徽章视图
private struct BadgeView: View {
    let count: Int?
    
    var body: some View {
        ZStack {
            // 小红点徽章
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
                .offset(x: 8, y: -4)
            
            // 数字徽章
            if let count = count, count > 0 {
                Text("\(min(count, 99))")
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .offset(x: 12, y: -8)
            }
        }
    }
}

/// 标签按钮
private struct ScrollableTabBarTabButton: View {
    @Environment(\.theme) private var theme
    let tab: TabItem
    let index: Int
    let selectedTab: TabItem?
    let tabHeight: CGFloat
    let onWidthChange: (CGFloat) -> Void
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack {
                if tab.title != "快讯" {
                    Text(tab.title)
                        .modifier(TabItemStyle(
                            isSelected: selectedTab == tab,
                            item: tab
                        ))
                } else {
                    Image("flash_new_icon")
                }
            }
            .contentShape(Rectangle())
            .background {
                GeometryReader { innerGeo in
                    Color.clear
                        .onAppear { onWidthChange(innerGeo.size.width) }
                        .onChange(of: innerGeo.size.width) { _, newWidth in
                            onWidthChange(newWidth)
                        }
                }
            }
            .frame(height: tabHeight)
        }
        .id(tab.id)
    }
}

/// 底部指示器
private struct BottomIndicator: View {
    let offsetX: CGFloat
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let color: Color
    let isDragging: Bool
    let dragOffset: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(color)
            .frame(width: width, height: height)
            .offset(x: offsetX + (isDragging ? dragOffset * 0.1 : 0))
            .animation(
                isDragging ? .interactiveSpring(response: 0.6, dampingFraction: 0.6) :
                    .spring(response: 0.3, dampingFraction: 0.7),
                value: offsetX
            )
    }
}

/// 更多按钮
private struct MoreButton: View {
    @Environment(\.theme) private var theme
    @Binding var isMoreTab: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            Divider()
                .frame(height: 16)
            Button(action: { isMoreTab.toggle() }) {
                Image(systemName: "rectangle.grid.2x2")
                    .themeFont(theme.fonts.title3)
                    .foregroundColor(theme.subText2)
                    .padding(12)
                    .background(theme.gray6Background)
            }
        }
    }
}

/// 可滚动标签栏组件
/// - 支持水平滚动的标签栏，带有下划线指示器和徽章显示
/// - 特性：
///   - 支持标签项的自适应宽度
///   - 带有底部滑动指示器
///   - 支持徽章显示
///   - 支持触感反馈
///   - 支持更多标签页面
struct ScrollableTabBar: View {
    // MARK: - Environment & Binding
    @Environment(\.theme) private var theme
    @Binding var selectedTab: TabItem?
    let tabs: [TabItem]
    
    // MARK: - 自定义配置项
    var spacing: CGFloat = 24
    var indicatorColor: Color = .orange
    var indicatorHeight: CGFloat = 4
    var indicatorCornerRadius: CGFloat = 1.5
    var tabHeight: CGFloat = 32
    var horizontalPadding: CGFloat = 16
    
    // MARK: - 状态管理
    @State private var tabWidths: [CGFloat]
    @State private var isDragging = false
    @State private var isMoreTab = false
    @GestureState private var dragOffset: CGFloat = 0
    
    // MARK: - 触感反馈
    private let feedbackGenerator = UISelectionFeedbackGenerator()
    
    // MARK: - 初始化
    init(selectedTab: Binding<TabItem?>,
         tabs: [TabItem],
         spacing: CGFloat = 24,
         indicatorColor: Color = Color("brandPrimary"),
         indicatorHeight: CGFloat = 3,
         indicatorCornerRadius: CGFloat = 1.5,
         tabHeight: CGFloat = 40,
         horizontalPadding: CGFloat = 16) {
        self._selectedTab = selectedTab
        self.tabs = tabs
        self.spacing = spacing
        self.indicatorColor = indicatorColor
        self.indicatorHeight = indicatorHeight
        self.indicatorCornerRadius = indicatorCornerRadius
        self.tabHeight = tabHeight
        self.horizontalPadding = horizontalPadding
        self._tabWidths = State(initialValue: Array(repeating: 0, count: tabs.count))
    }
    
    // MARK: - 私有方法
    private func updateTabWidth(index: Int, width: CGFloat) {
        guard index < tabWidths.count else { return }
        if tabWidths[index] != width {
            tabWidths[index] = width
        }
    }
    
    private func calculateIndicatorOffset(for selectedTab: TabItem?) -> (offset: CGFloat, width: CGFloat) {
        guard let selectedTab = selectedTab,
              let index = tabs.firstIndex(of: selectedTab),
              !tabWidths.isEmpty && index < tabWidths.count else {
            return (0, 20)
        }
        let offsetX = tabWidths.prefix(index).reduce(0, +) + CGFloat(index) * spacing
        let width = max(tabWidths[index] * 0.4, 20)
        return (offsetX + (tabWidths[index] - width) / 2, width)
    }
    
    // MARK: - 视图构建
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                mainTabContent(proxy: proxy)
            }
            .frame(height: tabHeight)
            .safeAreaInset(edge: .trailing) {
                MoreButton(isMoreTab: $isMoreTab)
            }
            .onAppear {
                if selectedTab == nil && !tabs.isEmpty {
                    selectedTab = tabs[0]
                }
            }
        }
        .frame(height: tabHeight)
    }
    
    // MARK: - 辅助视图
    @ViewBuilder
    private func mainTabContent(proxy: ScrollViewProxy) -> some View {
        HStack(spacing: spacing) {
            ForEach(enumerating: tabs) { index, tab in
                tabButton(for: tab, at: index, proxy: proxy)
                    .id(tab)
            }
        }
        .background(alignment: .bottom) {
            indicatorOverlay
        }
        .padding(.horizontal, horizontalPadding)
        .frame(height: tabHeight)
        .onChange(of: selectedTab) { _, newValue in
            withAnimation(.smooth) {
                proxy.scrollTo(newValue, anchor: .center)
            }
        }
    }
    
    @ViewBuilder
    private func tabButton(for tab: TabItem, at index: Int, proxy: ScrollViewProxy) -> some View {
        ScrollableTabBarTabButton(
            tab: tab,
            index: index,
            selectedTab: selectedTab,
            tabHeight: tabHeight,
            onWidthChange: { width in
                updateTabWidth(index: index, width: width)
            },
            onTap: {
                feedbackGenerator.selectionChanged()
                withAnimation(.smooth) {
                    selectedTab = tab
                    proxy.scrollTo(tab, anchor: .center)
                }
            }
        )
    }
    
    @ViewBuilder
    private var indicatorOverlay: some View {
        if !tabWidths.isEmpty,
           let selectedTab = selectedTab,
           let index = tabs.firstIndex(of: selectedTab),
           index < tabWidths.count {
            GeometryReader { geometry in
                let (offsetX, width) = calculateIndicatorOffset(for: selectedTab)
                BottomIndicator(
                    offsetX: offsetX,
                    width: width,
                    height: indicatorHeight,
                    cornerRadius: indicatorCornerRadius,
                    color: indicatorColor,
                    isDragging: isDragging,
                    dragOffset: dragOffset
                )
            }
            .frame(height: indicatorHeight)
        }
    }
}
