//
//  ArticleRowView.swift
//  jy
//
//  Created by 林晓彬 on 2025/1/30.
//
import SwiftUI

// 文章行视图组件
struct ArticleRowView: View {
    
    @Environment(\.theme) private var theme
    let article: Article
    
    var body: some View {
        NavigationLink(value: NavigationType.article(id: article.title)) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(article.title)
                        .font(.system(size: 16))
                        .lineLimit(2)
                        .foregroundColor(theme.primaryText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    HStack(spacing: 8) {
                        Text(article.source)
                            .font(.system(size: 12))
                            .foregroundColor(theme.subText2)
                        
                        Text(article.time)
                            .font(.system(size: 12))
                            .foregroundColor(theme.subText2)
                        
                        Spacer()
                        
                        Text("\(article.collectionCount)个收藏")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                ProgressView()
                    .frame(width: 60, height: 60)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
