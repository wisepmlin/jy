//
//  Comment.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

// 添加评论数据模型
struct Comment: Identifiable {
    let id = UUID()
    let avatar: String
    let username: String
    let isVIP: Bool
    let content: String
    let timestamp: String
    let likeCount: Int
    var isLiked: Bool
}

// 添加预览评论数据
func getPreviewComments() -> [Comment] {
    [
        Comment(
            avatar: "avatar_placeholder",
            username: "投资达人",
            isVIP: true,
            content: "非常专业的分析，对企业财务指标的解读很到位。建议可以再补充一下现金流相关的指标分析。",
            timestamp: "2小时前",
            likeCount: 88,
            isLiked: false
        ),
        Comment(
            avatar: "avatar_placeholder",
            username: "财务小白",
            isVIP: false,
            content: "通俗易懂，对新手很友好，期待更多类似的文章分享！",
            timestamp: "3小时前",
            likeCount: 45,
            isLiked: true
        ),
        Comment(
            avatar: "avatar_placeholder",
            username: "财务小白",
            isVIP: false,
            content: "通俗易懂，对新手很友好，期待更多类似的文章分享！",
            timestamp: "3小时前",
            likeCount: 45,
            isLiked: true
        ),
        Comment(
            avatar: "avatar_placeholder",
            username: "财务小白",
            isVIP: false,
            content: "通俗易懂，对新手很友好，期待更多类似的文章分享！",
            timestamp: "3小时前",
            likeCount: 45,
            isLiked: true
        ),
        Comment(
            avatar: "avatar_placeholder",
            username: "财务小白",
            isVIP: false,
            content: "通俗易懂，对新手很友好，期待更多类似的文章分享！",
            timestamp: "3小时前",
            likeCount: 45,
            isLiked: true
        )   
    ]
}
