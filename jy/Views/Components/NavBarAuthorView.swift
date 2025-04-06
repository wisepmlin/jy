import SwiftUI

struct NavBarAuthorView: View {
    @Environment(\.theme) var theme
    let author: ArticleContent.Author
    
    var body: some View {
        HStack(spacing: 4) {
            // 导航栏中的作者头像
            Circle()
                .fill(theme.subText.opacity(0.2))
                .frame(width: 36, height: 36)
                .overlay {
                    KFImage(URL(string: "https://img1.baidu.com/it/u=728383910,3448060628&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"))
                        .resizable()
                        .placeholder {
                            ProgressView() // 加载中显示进度条
                        }
                        .fade(duration: 0.35) // 加载完成后的动画
                        .scaledToFill()
                        .clipShape(Circle())
                }
            
            // 作者名字
            VStack(alignment: .leading, spacing: 0) {
                Text(author.name)
                    .themeFont(theme.fonts.caption.bold())
                    .foregroundColor(theme.primaryText)
                    .lineSpacing(10)
                TopBarFollowButton()
            }
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
} 
