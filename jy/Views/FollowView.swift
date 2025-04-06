import SwiftUI

struct FollowView: View {
    @StateObject private var viewModel = FollowViewModel()
    @Environment(\.theme) private var theme
    
    var body: some View {
        List {
            // 关注的作者区域
            FollowedAuthorsSection(authors: viewModel.authors)
            
            // 关注用户的文章
            ForEach(viewModel.followedPosts) { post in
                FollowedPostView(post: post)
                    .standardListRowStyle()
            }
            
            // 推荐写作达人作者区域
            RecommendedAuthorsSection(
                icon: "xmark",
                title: "推荐写作达人作者",
                actionTitle: "查看全部",
                authors: viewModel.recommendedAuthors,
                onFollowToggle: viewModel.toggleFollow
            )
            
            // 关注用户的文章
            ForEach(viewModel.followedPosts) { post in
                FollowedPostView(post: post)
                    .standardListRowStyle()
            }
            
            // 推荐认证达人作者区域
            RecommendedAuthorsSection(
                icon: "xmark",
                title: "推荐认证达人作者",
                actionTitle: "全部关注",
                authors: viewModel.recommendedAuthors,
                onFollowToggle: viewModel.toggleFollow
            )
            
            // 关注用户的文章
            ForEach(viewModel.followedPosts) { post in
                FollowedPostView(post: post)
                    .standardListRowStyle()
            }
            
            // 底部提示
            NoMoreDataView()
        }
        .JYXQListStyle()
        .scrollContentBackground(.hidden)
        .refreshable {
            
        }
    }
}

// MARK: - 关注的作者区域
struct FollowedAuthorsSection: View {
    @Environment(\.theme) private var theme
    let authors: [Author]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: "person.circle")
                        .themeFont(theme.fonts.title3)
                        .foregroundColor(theme.primaryText)
                }
                
                Text("我关注的达人作者")
                    .customFont(fontSize: 20)
                    .foregroundColor(theme.primaryText)
                    .baselineOffset(-2)
                
                Spacer()
                
                Button(action: {}) {
                    Text("查看全部")
                        .themeFont(theme.fonts.body)
                        .foregroundColor(theme.jyxqPrimary)
                }
            }
            .padding(EdgeInsets(top: 12, leading: 12, bottom: 0, trailing: 12))
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 24) {
                    ForEach(authors) { author in
                        AuthorView(author: author)
                    }
                }
                .padding(12)
            }
        }
        .standardListRowStyle()
        .background {
            LinearGradient(colors: [theme.background, theme.background.opacity(0.5)],
                         startPoint: .top,
                         endPoint: .bottom)
            .cornerRadius(theme.defaultCornerRadius)
        }
    }
}

// MARK: - 推荐作者区域
struct RecommendedAuthorsSection: View {
    @Environment(\.theme) private var theme
    let icon: String
    let title: String
    let actionTitle: String
    let authors: [RecommendedAuthor]
    let onFollowToggle: (RecommendedAuthor) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: icon)
                        .themeFont(theme.fonts.title3)
                        .foregroundColor(theme.primaryText)
                }
                
                Text(title)
                    .customFont(fontSize: 20)
                    .foregroundColor(theme.primaryText)
                    .baselineOffset(-2)
                
                Spacer()
                
                Button(action: {}) {
                    Text(actionTitle)
                        .themeFont(theme.fonts.body)
                        .foregroundColor(theme.jyxqPrimary)
                }
            }
            .padding(EdgeInsets(top: 12, leading: 12, bottom: 0, trailing: 12))
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(authors) { author in
                        RecommendedAuthorView(author: author) {
                            onFollowToggle(author)
                        }
                    }
                }
                .padding(12)
            }
        }
        .standardListRowStyle()
        .background {
            LinearGradient(colors: [theme.background, theme.background.opacity(0.5)],
                         startPoint: .top,
                         endPoint: .bottom)
            .cornerRadius(theme.defaultCornerRadius)
        }
    }
}

// MARK: - 底部无更多数据提示
struct NoMoreDataView: View {
    var body: some View {
        Text("没有更多最新数据了")
            .font(.footnote)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(32)
            .padding(.bottom, 64)
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

// MARK: - 关注的文章视图
struct FollowedPostView: View {
    @Environment(\.theme) private var theme
    let post: FollowedPost
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading) {
                Text(post.title)
                    .themeFont(theme.fonts.title3)
                    .lineLimit(2)
                Spacer()
                HStack(spacing: 8) {
                    KFImage(URL(string: post.authorAvatar))
                        .resizable()
                        .cacheOriginalImage()
                        .memoryCacheExpiration(.days(14))
                        .diskCacheExpiration(.days(60))
                        .cancelOnDisappear(true)
                        .loadDiskFileSynchronously()
                        .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 20*2, height: 20*2)))
                        .frame(width: 20, height: 20)
                        .clipShape(Circle())
                    
                    Text(post.authorName)
                        .themeFont(theme.fonts.small)
                        .foregroundColor(theme.subText2)
                    Spacer()
                    Image(systemName: "smallcircle.circle")
                        .themeFont(theme.fonts.caption)
                        .foregroundColor(theme.jyxqPrimary.opacity(0.35))
                    Text(post.date.formatted(date: .numeric, time: .omitted))
                        .themeFont(theme.fonts.caption)
                        .foregroundColor(theme.subText2)
                }
            }
            KFImage(URL(string: post.cover))
                .resizable()
                .cacheOriginalImage()
                .memoryCacheExpiration(.days(14))
                .diskCacheExpiration(.days(60))
                .cancelOnDisappear(true)
                .loadDiskFileSynchronously()
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 92*2, height: 80*2)))
                .aspectRatio(contentMode: .fill)
                .frame(width: 92, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(12)
        .background(theme.background.cornerRadius(theme.defaultCornerRadius))
    }
}

// MARK: - 作者头像和名称视图
struct AuthorView: View {
    let author: Author
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            KFImage(URL(string: author.avatar))
                .resizable()
                .cacheOriginalImage()
                .memoryCacheExpiration(.days(14))
                .diskCacheExpiration(.days(60))
                .cancelOnDisappear(true)
                .loadDiskFileSynchronously()
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 52*2, height: 52*2)))
                .frame(width: 52, height: 52)
                .clipShape(Circle())
            Text(author.name)
                .themeFont(theme.fonts.small)
                .foregroundColor(theme.primaryText)
        }
    }
}

// MARK: - 推荐作者视图
struct RecommendedAuthorView: View {
    @Environment(\.theme) private var theme
    let author: RecommendedAuthor
    let followAction: () -> Void
    
    var body: some View {
        VStack {
            KFImage(URL(string: author.avatar))
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            
            Text(author.name)
                .themeFont(theme.fonts.small)
                .foregroundColor(theme.primaryText)
            
            Text(author.role)
                .themeFont(theme.fonts.caption)
                .foregroundColor(theme.subText2)
            
            Button(action: followAction) {
                Text(author.isFollowing ? "已关注" : "关注")
                    .themeFont(theme.fonts.caption)
                    .foregroundColor(author.isFollowing ? theme.background.opacity(0.5) : theme.background)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(author.isFollowing ? theme.subText2 : theme.jyxqPrimary)
                    .cornerRadius(15)
            }
        }
        .frame(width: 88)
    }
}

#Preview {
    FollowView()
}
