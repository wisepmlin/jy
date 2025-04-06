//
//  AuthorSectionView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

// MARK: - Author Section
struct AuthorSectionView: View {
    let author: ArticleContent.Author
    let publishDate: String
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack(spacing: theme.articleDetail.headerSpacing) {
            // 头像
            AuthorAvatarView(avatar: author.avatar)
            
            // 作者信息
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(author.name)
                        .themeFont(theme.fonts.body.bold())
                        .foregroundColor(theme.primaryText)
                    if author.isVIP {
                        VIPBadgeView()
                    }
                }
                
                Text(publishDate)
                    .themeFont(theme.fonts.caption)
                    .foregroundColor(theme.subText2)
            }
            
            Spacer()
            
            // 关注按钮
            FollowButton()
        }
    }
}
