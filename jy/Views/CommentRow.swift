//
//  CommentRow.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

// 添加评论行视图
struct CommentRow: View {
    let comment: Comment
    @Environment(\.theme) private var theme
    @State private var isLiked: Bool
    
    init(comment: Comment) {
        self.comment = comment
        _isLiked = State(initialValue: comment.isLiked)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 用户信息
            HStack(spacing: 8) {
                // 头像
                KFImage(URL(string: "https://img0.baidu.com/it/u=3033927961,683661730&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"))
                    .resizable()
                    .cacheOriginalImage()
                    .memoryCacheExpiration(.days(14))
                    .diskCacheExpiration(.days(60))
                    .cancelOnDisappear(true)
                    .loadDiskFileSynchronously()
                    .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 36 * 2, height: 36 * 2)))
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    // 用户名和VIP标识
                    HStack(spacing: 4) {
                        Text(comment.username)
                            .themeFont(theme.fonts.small.bold())
                            .foregroundColor(theme.primaryText)
                        
                        if comment.isVIP {
                            Text("VIP")
                                .themeFont(theme.fonts.minButton)
                                .foregroundColor(.white)
                                .padding(.horizontal, 4)
                                .background(theme.jyxqPrimary)
                                .cornerRadius(3)
                        }
                    }
                    
                    // 时间戳
                    Text(comment.timestamp)
                        .themeFont(theme.fonts.caption)
                        .foregroundColor(theme.subText2)
                }
                
                Spacer()
                
                // 点赞按钮
                Button(action: {
                    withAnimation { isLiked.toggle() }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .themeFont(theme.fonts.body)
                        Text("\(comment.likeCount)")
                            .themeFont(theme.fonts.body)
                    }
                    .foregroundColor(isLiked ? .red : theme.subText2)
                }
            }
            
            // 评论内容
            Text(comment.content)
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.primaryText)
                .lineSpacing(4)
        }
        .padding(12)
        .background(theme.background)
        .cornerRadius(theme.defaultCornerRadius)
    }
}
