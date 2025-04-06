import SwiftUI

// 地理位置信息
struct Location: Hashable {
    let latitude: Double
    let longitude: Double
    let description: String
}

struct MomentItem: Identifiable, Equatable, Hashable {
    let id = UUID()
    let userAvatar: String
    let userName: String
    let content: String
    let images: [String]
    let publishTime: Date
    let likeCount: Int
    let commentCount: Int
    // 是否已收藏
    let isCollected: Bool
    // 收藏数量
    var collectCount: Int
    let location: Location?
    
    // 关联内容
    var linkedQA: LinkedQA?
    var linkedArticle: LinkedArticle?
    var recommendedTools: [RecommendedTool]
    var recommendedAgents: [RecommendedAgent]
    
    // Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MomentItem, rhs: MomentItem) -> Bool {
        lhs.id == rhs.id
    }
}

// 关联的问答
struct LinkedQA: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let answerCount: Int
    let viewCount: Int
}

// 关联的文章
struct LinkedArticle: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let author: String
    let coverImage: String?
}
