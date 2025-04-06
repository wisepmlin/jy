import SwiftUI
import SwiftUIX

struct FlashNewsItem: Identifiable {
    let id: Int
    let title: String
    let time: String
    let tag: String
    let content: String
    let isMe: Bool
}

struct FlashNewsView: View {
    @StateObject private var viewModel = FlashNewsViewModel()
    @Environment(\.theme) private var theme
    let tables = TabItem.flashNewsAllTabs
    @State private var isEdit: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            // 顶部标签栏
            CategoryTabBar(selectedTab: $viewModel.selectedCategory, categories: tables)
            
            // 快讯列表页面
            PageViewController(pages: tables.map { tab in
                newsListView(for: tab)
                    .background(theme.gray6Background)
            }, currentPage: Binding(
                get: { tables.firstIndex(where: { $0 == viewModel.selectedCategory }) ?? 0 },
                set: { viewModel.selectedCategory = tables[$0] }
            ))
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .task {
            await viewModel.fetchNews(category: TabItem.flashNewsAllTabs[0])
        }
    }
    
    @ViewBuilder
    private func newsListView(for category: TabItem) -> some View {
        List {
            ForEach(FlashNewsViewModel.mockData) { news in
                FlashNewsCard(news: news)
            }
        }
        .background(theme.gray6Background)
        .contentMargins(.vertical, 12, for: .scrollContent)
        .listStyle(.plain)
        .refreshable {
            
        }
        .safeAreaInset(edge: .top, spacing: 0, content: {
            FlashNewsConfigBubble(isEdit: $isEdit)
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
        })
    }
}

// 完善个人快讯配置
struct FlashNewsConfigBubble: View {
    @Environment(\.theme) private var theme
    @Binding var isEdit: Bool
    var body: some View {
        HStack {
            KFImage(URL(string: "https://img0.baidu.com/it/u=1077282731,2234353719&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"))
                .resizable()
                .placeholder {
                    ProgressView() // 加载中显示进度条
                }
                .fade(duration: 0.35) // 加载完成后的动画
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 26))
            VStack(alignment: .leading, spacing: 0) {
                Text("HI, WISE")
                    .themeFont(theme.fonts.small)
                    .foregroundColor(theme.primaryText)
                Text("订阅信息，获取私人定制快讯")
                    .themeFont(theme.fonts.caption)
                    .foregroundColor(theme.subText2)
            }
            Spacer()
            Button(action: {
                isEdit.toggle()
            }, label: {
                Text("立即订阅")
                    .themeFont(theme.fonts.small)
                    .foregroundColor(theme.background)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(height: 32)
                    .background(theme.jyxqPrimary)
                    .cornerRadius(20)
                    .padding(6)
            })
        }
        .padding(4)
        .frame(height: 52)
        .background {
            RoundedRectangle(cornerRadius: 26)
                .fill(Material.bar)
        }
    }
}

// 分类标签栏
struct CategoryTabBar: View {
    @Binding var selectedTab: TabItem?
    let categories: [TabItem]
    
    // 将滚动逻辑抽取为单独的方法
    private func scrollToCategory(_ category: TabItem, 
                                in proxy: ScrollViewProxy,
                                geometry: GeometryProxy) {
        if categories.firstIndex(of: category) != nil {
            withAnimation(.spring()) {
                proxy.scrollTo(category.id, anchor: .center)
            }
        }
    }
    
    // 将按钮创建逻辑抽取为单独的方法
    @ViewBuilder
    private func categoryButton(for category: TabItem,
                              proxy: ScrollViewProxy,
                              geometry: GeometryProxy) -> some View {
        TabButton(
            title: category.title,
            isSelected: selectedTab == category
        ) {
            selectedTab = category
            scrollToCategory(category, in: proxy, geometry: geometry)
        }
        .id(category.id)
    }
    
    init(selectedTab: Binding<TabItem?>,
         categories: [TabItem]) {
        self._selectedTab = selectedTab
        self.categories = categories
    }
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(categories) { category in
                            categoryButton(
                                for: category,
                                proxy: proxy,
                                geometry: geometry
                            )
                            .id(category)
                        }
                    }
                    .padding(.horizontal)
                    .animation(.interactiveSpring, value: selectedTab)
                }
                .frame(height: 36)
                .onAppear {
                    if selectedTab == nil && !categories.isEmpty {
                        selectedTab = categories[0]
                    }
                }
                .task(id: selectedTab) {
                    if let selectedTab {
                        scrollToCategory(selectedTab, in: proxy, geometry: geometry)
                    }
                }
            }
        }
        .frame(height: 36)
    }
}

// 标签按钮
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @Namespace private var animation
    @Environment(\.theme) private var theme
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? theme.jyxqPrimary : theme.subText2)
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isSelected ? theme.jyxqPrimary.opacity(0.1) : Color.clear)
                )
                .frame(height: 36)
                .matchedGeometryEffect(id: "tab_\(title)", in: animation)
        }
        .buttonStyle(.plain)
        .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }    
}

// 快讯卡片
struct FlashNewsCard: View {
    let news: FlashNewsItem
    @Environment(\.theme) private var theme
    @State var isMore: Bool = false
    var body: some View {
        HStack {
            Text(news.time)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .background(RoundedRectangle(cornerRadius: 12).fill(theme.background))
                .frame(width: 52, height: 20, alignment: .trailing)
                .frame(maxHeight: .infinity, alignment: .top)
                .overlay(alignment: .topTrailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("2025")
                            .font(.system(size: 16).bold())
                            .foregroundColor(.secondary)
                        Text("12月12日")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 24)
                }

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Divider().frame(height: 7)
                }
                Circle()
                    .fill(theme.jyxqPrimary)
                    .frame(width: 6, height: 6)
                HStack(spacing: 0) {
                    Divider()
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // 标题
                Text(news.title)
                    .themeFont(theme.fonts.title3.bold())
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                VStack(alignment: .leading, spacing: 12) {
                    // 内容
                    Text(news.content)
                        .themeFont(theme.fonts.small)
                        .foregroundColor(theme.subText2)
                        .lineLimit(isMore ? 200 : 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // 处理点击事件
                            withAnimation() {
                                isMore.toggle()
                            }
                            print("Tapped news: \(news.title)")
                        }
                    
                    Text("[原文链接]")
                        .font(.system(size: 14))
                        .foregroundColor(theme.jyxqPrimary)
                    HStack(spacing: 20) {
                        Text(news.tag)
                            .font(.system(size: 12))
                            .foregroundColor(theme.subText2)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(theme.subText.opacity(0.06))
                            )
                        Spacer()
                        FlashNewsToolbarButton(icon: "tray.and.arrow.up", label: "更多") {
                            
                        }
                        .opacity(0.5)
                        if news.isMe {
                            Text("咨询服务")
                                .font(theme.fonts.caption.bold())
                                .foregroundColor(Color.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(theme.jyxqPrimary)
                                )
                        }
                    }
                }
                .padding(12)
                .background(theme.background.cornerRadius(theme.defaultCornerRadius))
                .padding(.bottom, 24)
            }
        }
        .standardListRowStyle()
    }
}

#Preview {
    NavigationView {
        FlashNewsView()
    }
}
