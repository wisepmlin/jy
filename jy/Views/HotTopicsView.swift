import SwiftUI
import SwiftUIX

struct TopicItem: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let source: String
    let time: String
    let collectionCount: Int
    let imageUrl: String?
    let isTOp: Bool
    
    static func == (lhs: TopicItem, rhs: TopicItem) -> Bool {
        // 实现比较逻辑，例如：
        return lhs.id == rhs.id
    }
}

struct TopicsView: View {
    @Environment(\.theme) private var theme
    @Binding var navigationPath: [NavigationType]
    let tops = [
        TopicItem(
            title: "财务小白入门指南：5分钟看懂三大财务报表",
            source: "金鹰财通",
            time: "最近",
            collectionCount: 872,
            imageUrl: "https://n.sinaimg.cn/sinakd20240101s/126/w2048h2878/20240101/4ee1-2168bfe1e628c041b8ee68af38a44813.jpg",
            isTOp: true
        ),
        TopicItem(
            title: "企业税务筹划：如何合理节税与风险防控",
            source: "税务专家",
            time: "2小时前",
            collectionCount: 654,
            imageUrl: "https://wx2.sinaimg.cn/large/a8b6f5cbly4gks9lxi2kjj20p00gojsu.jpg",
            isTOp: true
        )]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(tops.enumerated()), id: \.element.id) { index, topic in
                TopicRow(topic: topic)
                    .onTapGesture {
                        navigationPath.append(NavigationType.hotTopic(topic: "热门话题"))
                    }
                if index != tops.count - 1 {
                    Divider()
                        .opacity(0.7)
                        .padding(.leading, 12)
                }
            }
        }
        .background(theme.background)
        .standardListRowStyle()
        .cornerRadius(theme.defaultCornerRadius)
       
    }
}

// MARK: - Helper Views

private struct CoverImageView: View {
    let url: String
    
    var body: some View {
        KFImage(URL(string: url))
            .resizable()
            .placeholder {
                ProgressView()
            }
            .fade(duration: 0.35)
            .scaledToFill()
            .frame(width: 90, height: 120)
    }
}

struct TopicRow: View {
    @Environment(\.theme) private var theme
    let topic: TopicItem
    
    var body: some View {
        HStack(spacing: 16) {
            contentStack
            topicImage
        }
        .padding(12)
        .background(theme.background)
        .containerShape(Rectangle())
    }
    
    private var contentStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            titleView
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            metadataView
        }
    }
    
    private var titleView: some View {
        Text(topic.title)
            .themeFont(theme.fonts.title3)
            .foregroundColor(theme.primaryText)
            .lineLimit(2)
    }
    
    private var metadataView: some View {
        HStack(spacing: 8) {
            if topic.isTOp {
                topTag
            }
            
            Text("\(topic.source)    \(topic.time)")
                .themeFont(theme.fonts.caption)
                .foregroundColor(theme.subText)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            Text("\(topic.collectionCount)个收藏")
                .font(.system(size: 12))
                .foregroundColor(theme.subText)
            }
    }
    
    private var topTag: some View {
        Text("置顶")
            .customFont(fontSize: 14)
            .foregroundColor(theme.jyxqPrimary)
            .baselineOffset(-2)
            .padding(.vertical, 1)
            .padding(.horizontal, 4)
            .background {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(theme.jyxqPrimary, style: .init(lineWidth: 1))
            }
    }
    
    private var topicImage: some View {
        ZStack {
            if let url = topic.imageUrl {
                // 配置示例
                KFImage(URL(string: url))
                    .resizable()
                    .placeholder {
                        // 使用占位图片替代loading提升体验
                        Rectangle()
                            .fill(theme.gray6Background)
                            .frame(width: 92, height: 80)
                    }
                    .fade(duration: 0.2)
                    .cacheOriginalImage()
                    .memoryCacheExpiration(.days(14))
                    .diskCacheExpiration(.days(60))
                    .cancelOnDisappear(true)
                    .loadDiskFileSynchronously()
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 92*2, height: 80*2)))
                    .scaledToFill()
                    .frame(width: 92, height: 80)
                    .compositingGroup()
                    .cornerRadius(theme.minCornerRadius)
            } else {
                RoundedRectangle(cornerRadius: theme.minCornerRadius)
                   .fill(theme.gray6Background)
                   .frame(width: 92, height: 80)
            }
        }
    }
}

struct RecommendRow: View {
    @Environment(\.theme) private var theme
    let topic: TopicItem
    
    var body: some View {
        VStack(spacing: 12) {
            topicImage
            VStack(alignment: .leading, spacing: 8) {
                titleView
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                metadataView
            }
        }
        .padding(12)
        .background(theme.background)
        .containerShape(Rectangle())
    }
    
    private var topicImage: some View {
        ZStack {
            if let url = topic.imageUrl {
                // 配置示例
                KFImage(URL(string: url))
                    .resizable()
                    .placeholder {
                        // 使用占位图片替代loading提升体验
                        Rectangle()
                            .fill(theme.gray6Background)
                            .frame(width: UIScreen.main.bounds.width - 32, height: 180)
                    }
                    .fade(duration: 0.2)
                    .cacheOriginalImage()
                    .memoryCacheExpiration(.days(14))
                    .diskCacheExpiration(.days(60))
                    .cancelOnDisappear(true)
                    .loadDiskFileSynchronously()
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: (UIScreen.main.bounds.width - 32)*2, height: 180*2)))
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 32, height: 180)
                    .compositingGroup()
                    .cornerRadius(theme.minCornerRadius)
            } else {
                RoundedRectangle(cornerRadius: theme.minCornerRadius)
                   .fill(theme.gray6Background)
                   .frame(width: UIScreen.main.bounds.width - 32, height: 180)
            }
        }
    }
    
    private var titleView: some View {
        Text(topic.title)
            .themeFont(theme.fonts.title3)
            .foregroundColor(theme.primaryText)
            .multilineTextAlignment(.leading)
            .lineLimit(2)
    }
    
    private var metadataView: some View {
        HStack(spacing: 8) {
            // Avatar
            KFImage(URL(string: "https://q1.itc.cn/q_70/images03/20240414/d477378709494a9e8adf154fb5200feb.jpeg"))
                .resizable()
                .placeholder {
                    ProgressView()
                }
                .fade(duration: 0.35)
                .scaledToFill()
                .frame(width: 20, height: 20)
                .cornerRadius(10)
            
            // Top tag if needed
            if topic.isTOp {
                topTag
            }
            
            // Source and time
            Text("\(topic.source)    \(topic.time)")
                .themeFont(theme.fonts.caption)
                .foregroundColor(theme.subText)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            // Collection count
            Text("\(topic.collectionCount)个收藏")
                .font(.system(size: 12))
                .foregroundColor(theme.subText2)
            }
    }
    
    private var topTag: some View {
        Text("置顶")
            .themeFont(theme.fonts.caption)
            .foregroundColor(theme.jyxqPrimary)
            .padding(.vertical, 1)
            .padding(.horizontal, 6)
            .background {
                RoundedRectangle(cornerRadius: 3)
                    .stroke(theme.jyxqPrimary, style: .init(lineWidth: 1))
            }
    }
}

struct TopicsListView: View {
    @Environment(\.theme) private var theme
    @Binding var navigationPath: [NavigationType]
    @ObservedObject var viewModel: TabContentViewModel
    
    var body: some View {
        // 文章分组列表
        ForEach(enumerating: viewModel.topicGroups) { index, topics in
            ArticleView(navigationPath: $navigationPath, topics: topics, isLastGroup: index == viewModel.topicGroups.count - 1) { isLastItem in
                if isLastItem {
                    Task {
                        await viewModel.loadMoreData()
                    }
                }
            }
        }
    }
}

struct RecommendListView: View {
    @Environment(\.theme) private var theme
    @Binding var navigationPath: [NavigationType]
    @ObservedObject var viewModel: TabContentViewModel
    var body: some View {
        // 文章分组列表
        ForEach(Array(viewModel.topicGroups.enumerated()), id: \.offset) { index, topics in
            RecommendArticleView(navigationPath: $navigationPath,
                                 topics: topics,
                                 isLastGroup: index == viewModel.topicGroups.count - 1) { isLastItem in
                if isLastItem {
                    Task {
                        await viewModel.loadMoreData()
                    }
                }
            }
        }
    }
}

#Preview {
    TopicsView(navigationPath: .constant([]))
}

struct ExtractedView: View {
    @Environment(\.theme) private var theme
    let count: Int
    let index: Int
    var body: some View {
        HStack {
            Text("热门栏目")
                .customFont(fontSize: 20)
                .foregroundColor(theme.primaryText)
                .baselineOffset(-2)
                .overlay(alignment: .topLeading) {
                    Circle()
                        .stroke(theme.jyxqPrimary, lineWidth: 2)
                        .frame(width: 12, height: 12)
                        .offset(y: -2)
                }
            Text("（\(index + 1)/\(count)）")
                .themeFont(theme.fonts.small)
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button(action: {
                
            }, label: {
                HStack(spacing: 2) {
                    Text("更多")
                        .themeFont(theme.fonts.small)
                        .foregroundColor(theme.primaryText)
                    Image(systemName: "chevron.right")
                        .themeFont(theme.fonts.caption)
                        .foregroundColor(theme.subText2)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.gray6Background)
                }
            })
        }
    }
}
