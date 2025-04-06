import SwiftUI
import SwiftUIX

struct ColumnView: View {
    @Environment(\.theme) private var theme
    @StateObject private var viewModel = ColumnViewModel()
    @State private var selectedTab: TabItem?
    
    // 获取所有专栏分类
    private var categories: [String] {
        let allCategories = viewModel.columns.map { $0.category }
        return ["全部"] + Array(Set(allCategories)).sorted()
    }
    
    let tabs = TabItem.columnAllTabs
    
    var body: some View {
        VStack(spacing: 0) {
            // 分类导航
            ScrollableTabBar(selectedTab: $selectedTab,
                             tabs: tabs)
            PageViewController(pages: tabs.map { tab in
                listView(tab: tab)
                    .background(theme.gray6Background)
            }, currentPage: Binding(
                get: { tabs.firstIndex(where: { $0 == selectedTab }) ?? 0 },
                set: { selectedTab = tabs[$0] }
            ))
            .ignoresSafeArea(.all, edges: .bottom)
        }
        .background(theme.gray6Background)
    }
    func listView(tab: TabItem) -> some View {
        List(viewModel.columns) { column in
            ColumnItemView(column: column)
        }
        .listStyle(.plain)
        .listRowSpacing(8)
        .contentMargins(.vertical, 8, for: .scrollContent)
        .frame(width: UIScreen.main.bounds.width)
        .id(tab)
        .refreshable {
            
        }
    }
}

// 专栏列表项组件
struct ColumnItemView: View {
    @Environment(\.theme) private var theme
    let column: Column
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AuthorInfoView(author: column.author)
            ColumnCoverView(column: column)
            
            Text(column.description)
                .themeFont(theme.fonts.small)
                .foregroundColor(theme.subText2)
                .lineLimit(2)
                .padding(.horizontal, 12)
            
            LatestArticlesView(articles: column.articles)
                .padding(.horizontal, 12)
            
            PriceView(price: "299.00")
        }
        .standardListRowStyle()
        .contentCardStyle()
    }
}

// 作者信息视图
private struct AuthorInfoView: View {
    @Environment(\.theme) private var theme
    let author: ColumnAuthor
    
    var body: some View {
        HStack(spacing: 12) {
            AvatarImage(url: author.avatar)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(author.name)
                    .themeFont(theme.fonts.title3.bold())
                    .foregroundColor(theme.primaryText)
                
                AuthorTagsView(title: author.title)
            }
        }
        .padding(.horizontal, 12)
    }
}

// 作者标签视图
private struct AuthorTagsView: View {
    @Environment(\.theme) private var theme
    let title: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text("从业23年")
            Text("•")
            Text(title)
            Text("•")
            Text("认证专家")
        }
        .themeFont(theme.fonts.caption)
        .foregroundColor(theme.subText)
    }
}

// 专栏封面视图
private struct ColumnCoverView: View {
    @Environment(\.theme) private var theme
    let column: Column
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            CoverImage(url: column.coverImage)
            
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 60)
            
            CoverInfoView(title: column.title, 
                         articleCount: column.articleCount,
                         subscriberCount: column.subscriberCount)
        }
        .compositingGroup()
        .cornerRadius(theme.minCornerRadius)
        .padding(.horizontal, 12)
    }
}

// 封面信息视图
private struct CoverInfoView: View {
    @Environment(\.theme) private var theme
    let title: String
    let articleCount: Int
    let subscriberCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .themeFont(theme.fonts.title2.bold())
                .foregroundColor(Color.white)
                .shadow(color: Color.black.opacity(0.5), x: 0, y: 0, blur: 2)
            
            Text("\(articleCount)篇文章 · \(subscriberCount)人订阅")
                .themeFont(theme.fonts.caption)
                .foregroundColor(Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.35), x: 0, y: 0, blur: 2)
        }
        .padding(8)
    }
}

// 价格视图
private struct PriceView: View {
    @Environment(\.theme) private var theme
    let price: String
    
    var body: some View {
        HStack(spacing: 2) {
            HStack(alignment: .bottom, spacing: 0) {
                Text("¥")
                    .themeFont(theme.fonts.small)
                Text(price)
                    .themeFont(theme.fonts.title2.bold())
            }
            .foregroundColor(theme.jyxqPrimary)
            
            Text("/专栏")
                .themeFont(theme.fonts.caption)
                .foregroundColor(theme.subText2)
            
            Spacer()
            
            Text("限时优惠")
                .themeFont(theme.fonts.small)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(theme.jyxqPrimary)
                .cornerRadius(20)
        }
        .padding(.horizontal, 12)
    }
}

// 通用组件
private struct AvatarImage: View {
    @Environment(\.theme) private var theme
    let url: String
    
    var body: some View {
        KFImage(URL(string: url))
            .resizable()
            .placeholder { ProgressView() }
            .fade(duration: 0.35)
            .frame(width: 40, height: 40)
            .scaledToFill()
            .clipShape(Circle())
    }
}

private struct CoverImage: View {
    @Environment(\.theme) private var theme
    let url: String
    
    var body: some View {
        KFImage(URL(string: url))
            .resizable()
            .placeholder { ProgressView() }
            .fade(duration: 0.35)
            .aspectRatio(contentMode: .fill)
            .frame(height: 100)
    }
}

// 视图修饰符
extension View {
    func contentCardStyle() -> some View {
        self
            .padding(.vertical, 12)
            .background(Color("car_bg"))
            .cornerRadius(12)
    }
}

// 最新文章预览组件
struct LatestArticlesView: View {
    
    @Environment(\.theme) private var theme
    let articles: [ColumnArticle]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("最新文章")
                .themeFont(theme.fonts.caption)
                .foregroundColor(theme.subText2)
            
            ForEach(Array(articles.enumerated()), id: \.1.id) { index, item in
                HStack {
                    Text("\(index + 1).")
                    Text(item.title)
                        .lineLimit(1)
                    Text("-（阅读：\(formatReadCount(item.readCount))  点赞\(formatReadCount(item.likeCount))）")
                    Spacer()
                }
                .themeFont(theme.fonts.small)
                .foregroundColor(theme.primaryText)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
    // 格式化阅读数
    private func formatReadCount(_ count: Int) -> String {
        if count >= 10000 {
            let wan = Double(count) / 10000.0
            return String(format: "%.1f万", wan)
        } else if count >= 1000 {
            let qian = Double(count) / 1000.0
            return String(format: "%.1fk", qian)
        } else {
            return "\(count)"
        }
    }
}

#Preview {
    ColumnView()
}
