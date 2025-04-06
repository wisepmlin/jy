//
//  RelatedArticleList.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

struct RelatedArticleList: View {
    let articles: [ArticleContent.RelatedArticle]
    @Environment(\.theme) private var theme
    
    var body: some View {
        ForEach(articles) { relatedArticle in
            RelatedArticleRow(article: relatedArticle)
        }
    }
}
