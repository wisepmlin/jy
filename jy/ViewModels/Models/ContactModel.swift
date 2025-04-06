import SwiftUI

// 用户标签
struct UserTag: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let color: Color
}

// 社交互动统计
struct SocialStats {
    let messageCount: Int
    let lastInteractionDate: Date
    let commonInterests: [String]
    let mutualConnections: Int
}

// 职业信息
struct ProfessionalInfo {
    let title: String
    let company: String
    let industry: String
    let experience: Int
    let education: String?
}

// 人脉联系人
struct Contact: Identifiable, Equatable, Hashable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id = UUID()
    let avatar: String
    let name: String
    let professionalInfo: ProfessionalInfo
    let location: Location?
    let tags: [UserTag]
    let isFollowing: Bool
    let socialStats: SocialStats
    let verifiedStatus: Bool
    let introduction: String?
    
    // 社交媒体账号
    let socialMediaLinks: [String: String]?
    
    // 最近动态
    var recentMoments: [MomentItem]?
    
    // 共同关注的话题或领域
    var commonTopics: [String]?
    
    // 推荐理由
    var recommendationReason: String?
    
    // 联系方式
    var contactInfo: [String: String]?
    
    // 是否是重点人脉
    var isKeyContact: Bool
    
    // 人脉分组
    var groups: [String]
    
    // 备注信息
    var notes: String?
}

// 人脉分组
struct ContactGroup: Identifiable {
    let id = UUID()
    let name: String
    let description: String?
    let contacts: [Contact]
    let color: Color
    let icon: String
}
