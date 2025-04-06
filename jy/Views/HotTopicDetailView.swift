import SwiftUI

struct HotTopicDetailView: View {
    let title: String
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var stackDepth: StackDepthManager
    @Environment(\.theme) var theme
    @State var showAuthorInNav = false
    @State var isEditing = false
    @State var heighState: (Bool, Int) = (false, 1)
    @State var commentText = ""
    @State var height: CGFloat = 24
    // 更多菜单，朗读，AI解读
    @State var showShareMenu = false
    @State var ideaText = ""
    let article = ArticleContent.article
    let friends: [Friend] = [
        Friend(name: "财务总监", avatar: "https://img2.baidu.com/it/u=2919443825,85323390&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"),
        Friend(name: "会计主管", avatar: "https://img2.baidu.com/it/u=278246514,3170436431&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"),
        Friend(name: "税务专员", avatar: "https://img2.baidu.com/it/u=1567480039,3605884834&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500"),
        Friend(name: "成本会计", avatar: "https://img1.baidu.com/it/u=3513841559,2892662125&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"),
        Friend(name: "审计经理", avatar: "https://img0.baidu.com/it/u=4233203734,1642094654&fm=253&fmt=auto&app=138&f=JPEG?w=800&h=800"),
        Friend(name: "财务分析师", avatar: "https://img1.baidu.com/it/u=3201861296,3147953300&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"),
        Friend(name: "出纳主管", avatar: "https://img0.baidu.com/it/u=1740280333,3850630008&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"),
        Friend(name: "预算专员", avatar: "https://img0.baidu.com/it/u=2626860580,3349748790&fm=253&fmt=auto?w=500&h=500"),
        Friend(name: "资金主管", avatar: "https://img0.baidu.com/it/u=2176787830,3321947122&fm=253&fmt=auto?w=500&h=500")
    ]
    
    @State private var showBottomTool = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                AuthorSectionView(author: article.author, publishDate: article.publishDate)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onChange(of: geometry.frame(in: .global).minY) { oldMinY,newMinY  in
                                    withAnimation(.interactiveSpring) {
                                        showAuthorInNav = newMinY < 60
                                    }
                                }
                        }
                    )
                KFImage(URL(string: article.imageUrl))
                    .resizable()
                    .placeholder {
                        ProgressView() // 加载中显示进度条
                            .frame(minHeight: 200)
                    }
                    .fade(duration: 0.35) // 加载完成后的动画
                    .cacheOriginalImage()
                    .memoryCacheExpiration(.days(14))
                    .diskCacheExpiration(.days(60))
                    .cancelOnDisappear(true)
                    .loadDiskFileSynchronously()
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: (UIScreen.main.bounds.width - 16) * 2, height: 134 * 2)))
                    .scaledToFill()
                    .frame(width: UIScreen.main.bounds.width - 16, height: 134)
                    .cornerRadius(theme.defaultCornerRadius)
                
                JYXQRichText(html: article.content)
                    .lineHeight(160)
                    .colorScheme(.auto)
                    .imageRadius(theme.minCornerRadius)
                    .fontType(.system)
                    .foregroundColor(light: Color.black, dark: Color.white)
                    .linkColor(light: theme.jyxqPrimary, dark: theme.jyxqPrimary)
                    .colorPreference(forceColor: .onlyLinks)
                    .linkOpenType(.SFSafariView())
                    .placeholder {
                        ProgressView()
                    }
                    .transition(.smooth)
                
                // 相关标签
                TagsSection(tags: article.tags)
                
                if !article.recommendedTools.isEmpty {
                    RecommendedToolsSection(tools: article.recommendedTools)
                }
                
                // 推荐的智能体和工具
                if !article.recommendedAgents.isEmpty {
                    RecommendedAgentsSection(agents: article.recommendedAgents)
                }
                
                // 邀请讨论
                InviteDiscussionSection()
                    .cornerRadius(theme.defaultCornerRadius)
                
                // 文章交互
                InteractionSectionView(
                    likeCount: article.likeCount,
                    commentCount: article.commentCount,
                    collectCount: article.collectCount,
                    onLike: {},
                    onComment: {}
                )
                .cornerRadius(theme.defaultCornerRadius)
                
                // 相关文章和评论区域
                RelatedArticlesSection(articles: article.relatedArticles)
                    .cornerRadius(theme.defaultCornerRadius)
                
                CommentSection(article: article, showBottomTool: $showBottomTool)
                    .cornerRadius(theme.defaultCornerRadius)

                Text("——精英大大，我底线到了——")
                    .themeFont(theme.fonts.caption)
                    .foregroundColor(Color.gray.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 88)
            }
        }
        .contentMargins(.horizontal, 8 , for: .scrollContent)
        .dismissKeyboardOnScroll()
        .background(theme.gray6Background)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if showAuthorInNav {
                    NavBarAuthorView(author: article.author)
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                shareButton
            }
        }
        .safeAreaInset(edge: .bottom) {
            BottomToolView(
                showBottomTool: $showBottomTool,
                commentText: $commentText,
                heighState: $heighState,
                showShareMenu: $showShareMenu
            )
        }
        .updateStackDepth(depth: $stackDepth.depth)
        .updateStackDepthOnDisappear(depth: $stackDepth.depth)
    }
}

extension HotTopicDetailView {
    var shareButton: some View {
        Button(action: {
            showShareMenu = true
        }) {
            Image(systemName: "ellipsis")
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.primaryText)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
        }
        .sheet(isPresented: $showShareMenu) {
            ShareOverlayView(
                showShareMenu: $showShareMenu,
                ideaText: $ideaText,
                article: article,
                friends: friends
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .background(theme.background)
        }
    }
    
    // 分享粉丝好友列表
    func shareFriendList(friends: [Friend]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(friends) { friend in
                    shareHumanButton(title: friend.name, image: friend.avatar)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    func shareButton(
        title: String,
        image: String,
        style: ShareButtonStyle = .default,
        action: (() -> Void)? = nil
    ) -> some View {
        Button(action: { action?() }) {
            VStack(spacing: 8) {
                // 图标容器
                Image(image)
                    .frame(width: style.size, height: style.size)
                    .background(.bar)
                    .cornerRadius(style.size / 2)
                // 标题文本
                Text(title)
                    .themeFont(theme.fonts.caption)
                    .foregroundColor(style.titleColor ?? theme.primaryText)
            }
        }
        .buttonStyle(.plain)
    }
    
    func shareHumanButton(
        title: String,
        image: String,
        style: ShareButtonStyle = .default,
        action: (() -> Void)? = nil
    ) -> some View {
        Button(action: { action?() }) {
            VStack(spacing: 8) {
                // 图标容器
                KFImage(URL(string: image))
                    .resizable()
                    .placeholder {
                        ProgressView() // 加载中显示进度条
                    }
                    .fade(duration: 0.35) // 加载完成后的动画
                    .scaledToFit()
                    .frame(width: style.size, height: style.size)
                    .cornerRadius(style.size / 2)
                
                // 标题文本
                Text(title)
                    .themeFont(theme.fonts.caption)
                    .foregroundColor(style.titleColor ?? theme.primaryText)
            }
        }
        .buttonStyle(.plain)
    }
    
    //分析到多种社交媒体平台
    func shareList(platforms: [ShareType]) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(platforms) { platform in
                    shareButton(
                        title: platform.type,
                        image: platform.image,
                        action: {
                            if platform.type == "系统" {
                                
                            }
                            // 其他平台的分享可以根据需要添加
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 34)
    }
    
    // 分享按钮样式配置
    struct ShareButtonStyle {
        var backgroundColor: Color = .red
        var size: CGFloat = 52
        var cornerRadius: CGFloat = 26
        var iconColor: Color = .white
        var titleColor: Color?
        
        static let `default` = ShareButtonStyle()
    }
}

