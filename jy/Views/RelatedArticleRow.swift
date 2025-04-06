//
//  RelatedArticleRow.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

// 相关文章行视图
struct RelatedArticleRow: View {
    let article: ArticleContent.RelatedArticle
    @Environment(\.theme) private var theme
    @EnvironmentObject private var stackDepth: StackDepthManager
    
    var body: some View {
        HStack(spacing: theme.spacing) {
            // 文章信息
            VStack(alignment: .leading, spacing: 8) {
                // 标题
                Text(article.title)
                    .themeFont(theme.fonts.body.weight(.medium))
                    .foregroundColor(theme.primaryText)
                    .lineLimit(2)
                
                Spacer()
                // 底部信息
                HStack(spacing: 8) {
                    // 作者
                    Text(article.author)
                        .themeFont(theme.fonts.minButton)
                        .foregroundColor(theme.subText2)
                    
                    // 阅读数
                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                            .font(.system(size: 10))
                        Text("\(article.readCount)")
                            .themeFont(theme.fonts.minButton)
                    }
                    .foregroundColor(theme.subText2)
                    
                    // 标签
                    ForEach(article.tags.prefix(2), id: \.self) { tag in
                        Text(tag)
                            .themeFont(theme.fonts.minButton)
                            .foregroundColor(theme.jyxqPrimary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(theme.articleDetail.tagBackground)
                            .cornerRadius(8)
                    }
                }
            }
            
            Spacer()
            
            // 缩略图
            if let thumbnail = article.thumbnail {
                KFImage(URL(string: thumbnail))
                    .resizable()
                    .placeholder {
                        ProgressView() // 加载中显示进度条
                    }
                    .fade(duration: 0.2) // 加载完成后的动画
                    .cacheOriginalImage()
                    .memoryCacheExpiration(.days(14))
                    .diskCacheExpiration(.days(60))
                    .cancelOnDisappear(true)
                    .loadDiskFileSynchronously()
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 80 * 2, height: 80 * 2)))
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .cornerRadius(theme.defaultCornerRadius)
            }
        }
        .padding(12)
        .environmentObject(stackDepth)
        .background(theme.background)
        .cornerRadius(theme.defaultCornerRadius)
    }
}
