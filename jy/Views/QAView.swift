import SwiftUI
import SwiftUIX

struct QAView: View {
    @Environment(\.theme) private var theme
    @State private var selectedTopTab = 0
    let topTabs = TabItem.QAAllTabs

    var body: some View {
        NavigationStack {
            PageViewController(pages: topTabs.map { tab in
                QAContentView()
                    .background(theme.gray6Background)
            }, currentPage: $selectedTopTab )
            .navigationBarTitleDisplayMode(.inline)
            .background(theme.gray6Background)
            .navigationBarBackground()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    QAToolbarLeadingView(selectedTopTab: $selectedTopTab,
                                              topTabs: topTabs)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    QAToolbarTrailingView(selectedTopTab: $selectedTopTab,
                                              topTabs: topTabs)
                }
            }
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

// 问答内容视图
struct QAContentView: View {
    @Environment(\.theme) private var theme
    @State private var selectedBottomTab: TabItem?
    let bottomTabs = TabItem.QANewBottomAllTabs
    let qaItems = MockQAData.qaItems
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollableTabBar(selectedTab: $selectedBottomTab,
                           tabs: bottomTabs)
            
            QATabContent(selectedTab: $selectedBottomTab,
                        bottomTabs: bottomTabs,
                        qaItems: qaItems)
        }
    }
}

// MARK: - QA Tab Content
private struct QATabContent: View {
    @Binding var selectedTab: TabItem?
    let bottomTabs: [TabItem]
    let qaItems: [QAItem]
    @Environment(\.theme) private var theme
    
    var body: some View {
        PageViewController(pages: bottomTabs.map { tab in
            QAListView(qaItems: qaItems)
                .background(theme.gray6Background)
        }, currentPage: Binding(
            get: { bottomTabs.firstIndex(where: { $0 == selectedTab }) ?? 0 },
            set: { selectedTab = bottomTabs[$0] }
        ))
    }
}

// MARK: - QA List View
private struct QAListView: View {
    let qaItems: [QAItem]
    @Environment(\.theme) private var theme
    
    var body: some View {
        List {
            QABannerImage()
                .standardListRowStyle()
            
            ForEach(qaItems) { qaItem in
                QACard(qaItem: qaItem)
                    .standardListRowStyle()
            }
        }
        .contentMargins(.bottom, 88, for: .scrollContent)
        .listStyle(.plain)
        .listRowSpacing(8)
        .contentMargins(.vertical, 8, for: .scrollContent)
        .background(theme.gray6Background)
        .ignoresSafeArea(.container, edges: .bottom)
        .refreshable { }
    }
}

// MARK: - QA Banner Image
private struct QABannerImage: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        KFImage(URL(string: "https://scatbay-test.oss-cn-shanghai.aliyuncs.com/dt9lnvtsbej.png"))
            .resizable()
            .placeholder {
                ProgressView()
            }
            .fade(duration: 0.35)
            .scaledToFill()
            .frame(height: 134)
            .cornerRadius(theme.defaultCornerRadius)
    }
}

struct QAToolbarLeadingView: View {
    @Environment(\.theme) private var theme
    @Binding var selectedTopTab: Int
    let topTabs: [TabItem]
    
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(Array(topTabs.enumerated()), id: \.1.id) { index, tab in
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
                }
            }
        }
        .fixedSize()
    }
}

struct QAToolbarTrailingView: View {
    @Environment(\.theme) private var theme
    @Binding var selectedTopTab: Int
    let topTabs: [TabItem]
    @State private var isEditView = false
    var body: some View {
        Button(action: {
            isEditView.toggle()
        }, label: {
            TopBarLeftItemButtonView(image: "add_icon")
        })
        .fullScreenCover(isPresented: $isEditView, onDismiss: nil) {
            DemoContentView(isEditView: $isEditView)
             .interactiveDismissDisabled()
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: isEditView)
    }
}

// 问答卡片组件
struct QACard: View {
    @Environment(\.theme) private var theme
    let qaItem: QAItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 问题内容
            Text(qaItem.title)
                .themeFont(theme.fonts.title3)
                .foregroundColor(theme.primaryText)
                .padding(.horizontal, 12)
                .lineLimit(2)
                .lineSpacing(4)
                .kerning(0.5)
            // 回答内容
            Text(qaItem.content)
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.subText2)
                .padding(.horizontal, 12)
                .lineLimit(2)
                .lineSpacing(4)
                .kerning(0.5)
            
            Divider().opacity(0.7)
            
            // 互动信息
            HStack(spacing: 16) {
                HStack {
                    KFImage(URL(string: qaItem.user.avatar))
                        .resizable()
                        .placeholder {
                            ProgressView() // 加载中显示进度条
                        }
                        .fade(duration: 0.35) // 加载完成后的动画
                        .aspectRatio(contentMode: .fill)
                        .compositingGroup()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                        .cornerRadius(theme.defaultCornerRadius)
                    
                    Text(qaItem.user.name)
                        .themeFont(theme.fonts.small)
                        .foregroundColor(theme.subText2)
                    Text("\(qaItem.user.title) · \(qaItem.user.company)")
                        .themeFont(theme.fonts.small)
                        .foregroundColor(theme.subText2)
                }
                Spacer()
                Text("阅读 \(qaItem.readCount)")
                    .themeFont(theme.fonts.small)
                    .foregroundColor(theme.subText2)
            }
            .font(.system(size: 12))
            .foregroundColor(.gray)
            .padding(.horizontal, 12)
        }
        .padding(.vertical, 12)
        .background(theme.background)
        .cornerRadius(theme.defaultCornerRadius)
    }
}

#Preview {
    QAView()
}
