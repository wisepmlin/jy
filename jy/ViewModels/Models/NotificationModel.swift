import Foundation

// 通知项目模型
struct NotificationItem: Identifiable, Equatable, Hashable {
    static func == (lhs: NotificationItem, rhs: NotificationItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id: String
    let type: String // 通知类型：interaction, business, system
    let icon: String // SF Symbol 图标名称
    let title: String
    let content: String
    let time: String
    var isRead: Bool
    let preview: NotificationPreviewItem?
    
    // 根据通知类型获取对应的图标
    static func getIcon(for type: String) -> String {
        switch type {
        case "interaction":
            return "person.2.fill"
        case "business":
            return "briefcase.fill"
        case "system":
            return "bell.fill"
        default:
            return "bell"
        }
    }
}

// 通知预览项目模型
struct NotificationPreviewItem {
    let title: String
    let subtitle: String?
    let imageUrl: String?
}

// 通知视图模型
class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var isLoading = false
    
    // 加载通知列表
    func loadNotifications(type: String) {
        isLoading = true
        
        // 模拟加载数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.notifications = self.getMockNotifications(type: type)
            self.isLoading = false
        }
    }
    
    // 刷新通知列表
    func refreshNotifications(type: String) async {
        isLoading = true
        
        // 模拟网络请求延迟
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        await MainActor.run {
            self.notifications = self.getMockNotifications(type: type)
            self.isLoading = false
        }
    }
    
    // 获取模拟数据
    private func getMockNotifications(type: String) -> [NotificationItem] {
        if type == "all" {
            return mockAllNotifications
        } else {
            return mockAllNotifications.filter { $0.type == type }
        }
    }
    
    // 模拟通知数据
    private let mockAllNotifications = [
        NotificationItem(
            id: "1",
            type: "interaction",
            icon: "person.2.fill",
            title: "新的关注",
            content: "张三关注了你",
            time: "10分钟前",
            isRead: false,
            preview: NotificationPreviewItem(
                title: "张三",
                subtitle: "财务分析师 | 企业顾问",
                imageUrl: "https://example.com/avatar1.jpg"
            )
        ),
        NotificationItem(
            id: "2",
            type: "business",
            icon: "briefcase.fill",
            title: "订单状态更新",
            content: "您的订单 #12345 已发货",
            time: "1小时前",
            isRead: true,
            preview: NotificationPreviewItem(
                title: "企业财务分析服务",
                subtitle: "订单金额：¥2,999",
                imageUrl: nil
            )
        ),
        NotificationItem(
            id: "3",
            type: "system",
            icon: "bell.fill",
            title: "系统维护通知",
            content: "系统将于今晚22:00-23:00进行例行维护，期间部分服务可能暂时无法使用。",
            time: "2小时前",
            isRead: false,
            preview: nil
        ),
        NotificationItem(
            id: "4",
            type: "interaction",
            icon: "person.2.fill",
            title: "新的评论",
            content: "李四评论了你的文章《如何做好企业现金流管理》",
            time: "3小时前",
            isRead: true,
            preview: NotificationPreviewItem(
                title: "如何做好企业现金流管理",
                subtitle: "李四：这篇文章很有帮助，特别是关于现金流预测的部分...",
                imageUrl: "https://example.com/article1.jpg"
            )
        )
    ]
}
