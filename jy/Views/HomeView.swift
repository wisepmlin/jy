import SwiftUI
import SwiftUIX

// MARK: - HomeView
/// 主页视图，包含干货、专栏和发现三个主要页面
struct HomeView: View {
    // MARK: - Environment Values
    @Environment(\.theme) private var theme
    
    // MARK: - View Model
    @EnvironmentObject private var stackDepth: StackDepthManager
    
    // MARK: - State Properties
    @State private var selectedTopTab = 0 // 当前选中的顶部标签
    @Binding var isDrawerOpen: Bool // 抽屉菜单状态
    @Binding var navigationPath: [NavigationType] // 抽屉菜单状态
    
    // MARK: - Constants
    let tabs = TabItem.allTabs // 内容标签列表
    let topTabs = TabItem.homeTopAllTabs // 顶部标签列表
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationPath) {
            PageViewController(pages: topTabs.map { tab in
                HomeViewFactory(tab: tab, navigationPath: $navigationPath)
                    .environmentObject(stackDepth)
            }, currentPage: $selectedTopTab )
            .navigationDestination(for: NavigationType.self) { type in
                NavigationDestinationView(type: type)
            }
            .background(theme.gray6Background)
            .navigationBarBackground()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    ToolbarLeadingtView(selectedTopTab: $selectedTopTab,
                                      isDrawerOpen: $isDrawerOpen,
                                      topTabs: topTabs)
                }
                ToolbarItem(placement: .confirmationAction) {
                    ToolbarTrailingView(navigationPath: $navigationPath,
                                      selectedTopTab: $selectedTopTab)
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

// MARK: - HomeViewFactory
private struct HomeViewFactory: View {
    // MARK: - View Properties
    @State private var selectedTab: TabItem? // 当前选中的内容标签
    let tab: TabItem
    @Binding var navigationPath: [NavigationType]
    
    var body: some View {
        switch tab.id {
        case "column":
            ColumnView()
        case "discover":
            DiscoverNavigationView()
        default:
            MainContentView(selectedTab: $selectedTab,
                          navigationPath: $navigationPath)
        }
    }
}

// MARK: - MainContentView
private struct MainContentView: View {
    @Environment(\.theme) private var theme
    @Binding var selectedTab: TabItem?
    @Binding var navigationPath: [NavigationType]
    @EnvironmentObject private var stackDepth: StackDepthManager
    let tables = TabItem.allTabs
    // 添加状态管理
    @State private var isScrolling = false
    var body: some View {
        VStack(spacing: 0) {
            ScrollableTabBar(selectedTab: $selectedTab,
                             tabs: tables)

            PageViewController(pages: tables.map { tab in
                TabContentViewFactory(tab: tab, navigationPath: $navigationPath)
                    .environmentObject(stackDepth)
            }, currentPage: Binding(
                get: { tables.firstIndex(where: { $0 == selectedTab }) ?? 0 },
                set: { selectedTab = tables[$0] }
            ))
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

// MARK: - TabContentViewFactory
private struct TabContentViewFactory: View {
    let tab: TabItem
    @Binding var navigationPath: [NavigationType]
    
    var body: some View {
        switch tab.id {
        case "flash":
            FlashNewsView()
        case "follow":
            FollowView()
        case "recommended":
            RecommendContentView(navigationPath: $navigationPath)
        default:
            TabContentView(navigationPath: $navigationPath)
        }
    }
}

// MARK: - NavigationDestinationView
private struct NavigationDestinationView: View {
    let type: NavigationType
    @EnvironmentObject private var stackDepth: StackDepthManager
    
    var body: some View {
        Group {
            switch type {
            case .news(let title):
                NewsDetailView(title: title)
            case .hotTopic(let topic):
                HotTopicDetailView(title: topic)
            case .article(let article):
                ArticleDetailView(article: article)
            case .search, .qa, .profile, .home:
                SearchView()
            }
        }
        .environmentObject(stackDepth)
    }
}

// MARK: - ToolbarLeadingView
/// 导航栏左侧视图，包含抽屉菜单按钮和顶部标签切换
struct ToolbarLeadingtView: View {
    // MARK: - Properties
    @Environment(\.theme) private var theme
    @Binding var selectedTopTab: Int
    @Binding var isDrawerOpen: Bool
    let topTabs: [TabItem]
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 16) {
            MenuButton
            TopTabButtons
        }
        .fixedSize()
    }
    
    private var MenuButton: some View {
        Button(action: {
            isDrawerOpen = true
            print("isDrawerOpen:\(isDrawerOpen)")
        }, label: {
            Image(systemName: "line.3.horizontal.decrease")
                .foregroundColor(theme.primaryText)
                .contentShape(Rectangle())
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 6, height: 6)
                        .offset(x: 4, y: -4)
                }
        })
        .sensoryFeedback(.impact(weight: .heavy), trigger: isDrawerOpen)
    }
    
    private var TopTabButtons: some View {
        HStack(spacing: 8) {
            ForEach(Array(topTabs.enumerated()), id: \.1.id) { index, tab in
                TopTabButton(tab: tab, index: index)
            }
        }
    }
    
    private func TopTabButton(tab: TabItem, index: Int) -> some View {
        Button(action: {
            withAnimation(.interactiveSpring()) {
                selectedTopTab = index
            }
        }) {
            Text(tab.title)
                .font(selectedTopTab == index ? theme.fonts.title2 : theme.fonts.body)
                .fontWeight(selectedTopTab == index ? .bold : .regular)
                .foregroundColor(selectedTopTab == index ? theme.primaryText : theme.subText)
                .frame(width: 40)
                .overlay(alignment: .topTrailing) {
                    BadgeView(tab: tab)
                }
        }
    }
}

// MARK: - BadgeView
private struct BadgeView: View {
    let tab: TabItem
    
    var body: some View {
        if tab.showBadge {
            if let count = tab.badgeCount, count > 0 {
                Text("\(min(count, 99))")
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .clipShape(Capsule())
                    .offset(x: 12, y: -8)
            } else {
                Circle()
                    .fill(Color.red)
                    .frame(width: 6, height: 6)
                    .offset(x: 8, y: -4)
            }
        }
    }
}

// MARK: - ToolbarTrailingView
/// 导航栏右侧视图，包含搜索按钮
struct ToolbarTrailingView: View {
    // MARK: - Environment Values
    @Environment(\.theme) private var theme
    
    // MARK: - Properties
    @Binding var navigationPath: [NavigationType]
    @Binding var selectedTopTab: Int
    @State private var trigger = false
    @State private var isEditView = false
    
    // MARK: - Body
    var body: some View {
        HStack {
            Button(action: {
                trigger.toggle()
                navigationPath.append(NavigationType.search)
            }, label: {
                TopBarLeftItemButtonView(image: "search_icon")
            })
            .sensoryFeedback(.impact(weight: .heavy), trigger: trigger)
            
            Button(action: {
                isEditView.toggle()
            }, label: {
                TopBarLeftItemButtonView(image: "add_icon")
            })
            .sensoryFeedback(.impact(weight: .heavy), trigger: isEditView)
            .fullScreenCover(isPresented: $isEditView) {
                DemoContentView(isEditView: $isEditView)
            }
        }
    }
}

#Preview {
    HomeView(isDrawerOpen: .constant(false), navigationPath: .constant([]))
}

struct SearchHistoryItem: Identifiable, Hashable {
    let id = UUID()
    let keyword: String
    let timestamp: Date
    
    static func == (lhs: SearchHistoryItem, rhs: SearchHistoryItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct HotSearchItem: Identifiable, Hashable {
    let id = UUID()
    let keyword: String
    let subKeyword: String
    
    static func == (lhs: HotSearchItem, rhs: HotSearchItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
