import SwiftUI

struct PushNotification: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let body: String
    let timestamp: Date
    let route: NavigationType?
    
    static func == (lhs: PushNotification, rhs: PushNotification) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // 模拟推送消息数据
    static let mockNotifications: [PushNotification] = [
        PushNotification(
            title: "热门文章推荐",
            body: "5个关键财务比率，快速诊断企业健康状况",
            timestamp: Date(),
            route: .news(title: "5个关键财务比率，快速诊断企业健康状况")
        ),
        PushNotification(
            title: "热门话题更新",
            body: "企业税务筹划：如何合理节税与风险防控",
            timestamp: Date().addingTimeInterval(-3600),
            route: .hotTopic(topic: "企业税务筹划")
        ),
        PushNotification(
            title: "问答回复提醒",
            body: "您的问题已收到新回复",
            timestamp: Date().addingTimeInterval(-7200),
            route: .qa(id: "12345")
        ),
        PushNotification(
            title: "用户关注提醒",
            body: "税务专家关注了您",
            timestamp: Date().addingTimeInterval(-14400),
            route: .profile(userId: "67890")
        )
    ]
}
