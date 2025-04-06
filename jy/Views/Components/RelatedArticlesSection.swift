import SwiftUI

struct RelatedArticlesSection: View {
    @Environment(\.theme) var theme
    let articles: [ArticleContent.RelatedArticle] // 假设Article是relatedArticles的类型
    
    var body: some View {
        HStack {
            Text("相关文章")
                .themeFont(theme.fonts.title3)
                .foregroundColor(theme.primaryText)
            
            Text("(\(articles.count))")
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.subText2)
            
            Spacer()
        }
        RelatedArticleList(articles: articles)
    }
} 
