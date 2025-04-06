import SwiftUI

struct CommentSection: View {
    let article: ArticleContent
    @Environment(\.theme) var theme
    @Binding var showBottomTool: Bool
    
    var body: some View {
        // 评论标题
        HStack {
            Text("评论")
                .themeFont(theme.fonts.title3)
                .foregroundColor(theme.primaryText)
            
            Text("(\(article.commentCount))")
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.subText2)
            
            Spacer()
            
            Button(action: {
                // 添加评论操作
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "square.and.pencil")
                    Text("写评论")
                }
                .themeFont(theme.fonts.button)
                .foregroundColor(theme.jyxqPrimary)
            }
        }
        .trackLifecycle(onAppear: {
            withAnimation(.easeInOut(duration: 0.1)) {
                showBottomTool = true
            }
        },onDisappear: {
            withAnimation(.easeInOut(duration: 0.1)) {
                showBottomTool = false
            }
        })
        
        // 热门评论预览
        ForEach(getPreviewComments()) { comment in
            CommentRow(comment: comment)
        }
        
        // 查看全部评论按钮
        Button(action: {
            // 查看全部评论操作
        }) {
            HStack {
                Text("查看全部\(article.commentCount)条评论")
                    .themeFont(theme.fonts.body)
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
            }
            .foregroundColor(theme.subText2)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(theme.background)
            .cornerRadius(theme.defaultCornerRadius)
        }
    }
} 
