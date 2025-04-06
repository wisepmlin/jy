import SwiftUI
import SwiftUIX

// 用户信息视图
struct MomentUserInfoView: View {
    @Environment(\.theme) private var theme
    let moment: MomentItem
    
    var body: some View {
        HStack(spacing: 8) {
            KFImage(URL(string: moment.userAvatar))
                .resizable()
                .placeholder { ProgressView() }
                .fade(duration: 0.35)
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(moment.userName)
                        .font(theme.fonts.body.bold())
                        .foregroundColor(theme.primaryText)
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(theme.jyxqPrimary)
                        .font(.system(size: 12))
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                }
                
                HStack {
                    if let description = moment.location?.description {
                        Text(description)
                    }
                    Text(moment.publishTime, style: .relative)
                }
                .font(theme.fonts.caption)
                .foregroundColor(theme.subText2)
            }
            
            Spacer()
            FollowButton()
        }
        .padding(.horizontal, 12)
    }
}

// 动态内容视图
struct MomentContentView: View {
    @Environment(\.theme) private var theme
    let content: String
    
    var body: some View {
        Text(content)
            .font(theme.fonts.body)
            .fontWeight(.medium)
            .foregroundColor(theme.primaryText)
            .lineSpacing(4)
            .kerning(0.5)
            .lineLimit(4)
            .padding(.horizontal, 12)
    }
}

// 关联内容视图
struct MomentLinkedContentView: View {
    @Environment(\.theme) private var theme
    let moment: MomentItem
    
    var body: some View {
        VStack(spacing: 0) {
            if let qa = moment.linkedQA {
                LinkedContentView(icon: "questionmark.circle", 
                                title: qa.title, 
                                subtitle: "\(qa.answerCount)个回答 · \(qa.viewCount)次浏览")
            }
            
            if let article = moment.linkedArticle {
                Divider().opacity(0.7).padding(.leading, 12)
                LinkedContentView(icon: "doc.text",
                                title: article.title, 
                                subtitle: article.author)
            }
        }
        .background(theme.gray6Background.opacity(0.75))
        .cornerRadius(theme.minCornerRadius)
        .padding(.horizontal, 12)
    }
}

// 推荐内容视图
struct MomentRecommendationsView: View {
    let moment: MomentItem
    
    var body: some View {
        if !moment.recommendedTools.isEmpty || !moment.recommendedAgents.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                if !moment.recommendedTools.isEmpty {
                    RecommendationRow(icon: "hammer", 
                                    title: "推荐工具", 
                                    items: moment.recommendedTools.map { $0.name })
                }
                
                if !moment.recommendedAgents.isEmpty {
                    RecommendationRow(icon: "wand.and.stars", 
                                    title: "推荐智能体", 
                                    items: moment.recommendedAgents.map { $0.name })
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
    }
}

// 互动按钮视图
struct MomentInteractionView: View {
    let moment: MomentItem
    @Binding var showShareMenu: Bool
    var body: some View {
        HStack(spacing: 0) {
            SquareInteractionButton(icon: "hand.thumbsup", count: moment.collectCount, isAnimation: true, void: {
                
            })
            SquareInteractionButton(icon: "bubble.middle.bottom", count: moment.commentCount, isAnimation: false, void: {
                
            })
            SquareInteractionButton(icon: "suit.heart", count: moment.likeCount, isAnimation: true, void: {
                
            })
            SquareInteractionButton(icon: "ellipsis", count: nil, isAnimation: false, void: {
                showShareMenu.toggle()
            })
        }
    }
}

struct ImageGridView: View {
    @Environment(\.theme) private var theme
    let moment: MomentItem
    
    // 缓存计算值
    private let containerWidth = UIScreen.main.bounds.width - 16
    private let padding: CGFloat = 24 // 左右各12的padding
    private let spacing: CGFloat = 2
    
    // 提前计算布局相关的值避免重复计算
    private var layoutValues: (imageWidth: CGFloat, imageHeight: CGFloat, gridRows: [[String?]], totalHeight: CGFloat) {
        let imgWidth = moment.images.count == 1 ? 
            (containerWidth - padding) : 
            (containerWidth - padding - spacing * 2) / 3
        
        let imgHeight = imgWidth * 2 / 3.56
        
        let rows: [[String?]] = {
            switch moment.images.count {
            case 0: return []
            case 1: return [[moment.images[0]]]
            default:
                return moment.images
                    .chunked(into: 3)
                    .map { row in
                        row + Array(repeating: nil, count: 3 - row.count)
                    }
            }
        }()
        
        let height = CGFloat(rows.count) * imgHeight + CGFloat(max(0, rows.count - 1)) * spacing
        
        return (imgWidth, imgHeight, rows, height)
    }
    
    var body: some View {
        if !moment.images.isEmpty {
            let values = layoutValues // 只计算一次布局值
            
            Grid(alignment: .leading, horizontalSpacing: spacing, verticalSpacing: spacing) {
                ForEach(values.gridRows.indices, id: \.self) { rowIndex in
                    GridRow {
                        ForEach(values.gridRows[rowIndex].indices, id: \.self) { colIndex in
                            if let imageUrl = values.gridRows[rowIndex][colIndex] {
                                KFImage(URL(string: imageUrl))
                                    .resizable()
                                    .placeholder {
                                        // 使用静态占位符提升性能
                                        Color.gray.opacity(0.2)
                                    }
                                    .fade(duration: 0.2)
                                    .cacheOriginalImage()
                                    .memoryCacheExpiration(.days(14))
                                    .diskCacheExpiration(.days(60))
                                    .cancelOnDisappear(true)
                                    .loadDiskFileSynchronously()
                                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: values.imageWidth * 2, height: values.imageHeight * 2)))
                                    .aspectRatio(contentMode: .fill)
                                    .frame(
                                        width: values.imageWidth,
                                        height: values.imageHeight
                                    )
                                    .gridCellColumns(moment.images.count == 1 ? 3 : 1)
                                    .cornerRadius(theme.minCornerRadius)
                            } else {
                                Color.clear
                                    .frame(width: 0, height: 0)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 12)
            .frame(width: containerWidth, alignment: .leading)
            .frame(height: values.totalHeight)
        }
    }
}

// 延迟加载视图的包装器
private struct LazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}

// 用于数组分块的扩展
private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

struct LinkedContentView: View {
    @Environment(\.theme) private var theme
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .themeFont(theme.fonts.title1)
                .fontWeight(.light)
                .foregroundColor(theme.subText2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(theme.fonts.small)
                    .foregroundColor(theme.primaryText)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(theme.fonts.caption)
                    .foregroundColor(theme.subText2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(theme.fonts.caption)
                .foregroundColor(theme.subText3)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
    }
}

struct RecommendationRow: View {
    @Environment(\.theme) private var theme
    let icon: String
    let title: String
    let items: [String]
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .themeFont(theme.fonts.small)
                .foregroundColor(theme.jyxqPrimary)
                .frame(width: 20, height: 20)
            
            Text(title)
                .font(theme.fonts.small)
                .foregroundColor(theme.subText2)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(items.enumerated()), id: \.element) { index, item in
                        Text(item)
                            .font(theme.fonts.caption)
                            .foregroundColor(theme.jyxqPrimary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(theme.jyxqPrimary.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
        }
    }
}

struct SquareInteractionButton: View {
    @Environment(\.theme) private var theme
    let icon: String
    let count: Int?
    let isAnimation: Bool
    @State private var numberOfLikes: Int = 1
    @State private var isLiked = false
    var void: () -> ()
    var body: some View {
        Button(action: {
            isLiked.toggle()
            if isLiked {
                numberOfLikes += 1
            } else {
                numberOfLikes -= 1
            }
            void()
        }) {
            HStack(spacing: 8) {
                ZStack{
                    if isAnimation {
                        Image(systemName: icon)
                            .imageScale(.medium)
                            .font(isLiked ? .title2 : theme.fonts.body)
                            .foregroundColor(Color(isLiked ? .systemPink : theme.subText2))
                            .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: isLiked)
                        Circle()
                            .strokeBorder(lineWidth: isLiked ? 0 : 35)
                            .animation(.easeInOut(duration: 0.5).delay(0.1),value: isLiked)
                            .frame(width: 32, height: 32, alignment: .center)
                            .foregroundColor(theme.jyxqPrimary)
                            .hueRotation(.degrees(isLiked ? 300 : 200))
                            .scaleEffect(isLiked ? 1.1 : 0)
                            .animation(.easeInOut(duration: 0.5), value: isLiked)
                        
                        SplashView()
                            .opacity(isLiked ? 0 : 1)
                            .animation(.easeInOut(duration: 0.5).delay(0.25), value: isLiked)
                            .scaleEffect(isLiked ? 1.1 : 0)
                            .animation(.easeInOut(duration: 0.5), value: isLiked)
                        
                        SplashView()
                            .rotationEffect(.degrees(90))
                            .opacity(isLiked ? 0 : 1)
                            .offset(y: isLiked ? 3 : -3)
                            .animation(.easeInOut(duration: 0.5).delay(0.2), value: isLiked)
                            .scaleEffect(isLiked ? 1.2 : 0)
                            .animation(.easeOut(duration: 0.5), value: isLiked)
                    } else {
                        Image(systemName: icon)
                            .imageScale(.medium)
                            .font(theme.fonts.body)
                            .foregroundColor(theme.subText2)
                    }
                }
                .frame(width: 20, height: 20)
                if let count = count {
                    Text("\(count)")
                        .font(theme.fonts.small)
                        .foregroundColor(theme.subText2)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
} 
