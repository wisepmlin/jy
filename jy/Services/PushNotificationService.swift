import SwiftUI
import UserNotifications

class PushNotificationService: NSObject, ObservableObject {
    static let shared = PushNotificationService()
    
    @Published var deviceToken: String = ""
    private var notificationTimer: Timer?
    private var currentNotificationIndex = 0
    
    override init() {
        super.init()
        registerForPushNotifications()
        setupNotificationTimer()
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    private func setupNotificationTimer() {
        // 取消Timer的使用，改为在sendNextNotification中设置下一次通知的触发时间
        sendNextNotification()
    }
    
    private func sendNextNotification() {
        guard !PushNotification.mockNotifications.isEmpty else { return }
        
        // 获取下一条要发送的通知
        let notification = PushNotification.mockNotifications[currentNotificationIndex]
        
        // 创建通知内容
        let content = UNMutableNotificationContent()
        content.title = notification.title
        content.body = notification.body
        content.sound = .default
        
        // 如果有路由信息，添加到userInfo中
        if let route = notification.route {
            content.userInfo = [
                "route": [
                    "type": String(describing: route),
                    "parameters": [:] // 添加参数字段
                ]
            ]
        }
        
        // 创建时间触发器，设置为120分钟后触发
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 120 * 60, repeats: false)
        
        // 创建通知请求
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        // 添加通知请求
        UNUserNotificationCenter.current().add(request) { [weak self] error in
            if let error = error {
                print("Error scheduling notification: \(error)")
                return
            }
            
            // 更新索引，确保循环使用通知数据
            guard let self = self else { return }
            self.currentNotificationIndex = (self.currentNotificationIndex + 1) % PushNotification.mockNotifications.count
            
            // 延迟120分钟后安排下一条通知
            DispatchQueue.main.asyncAfter(deadline: .now() + 120 * 60) {
                self.sendNextNotification()
            }
        }
    }
    
    func handleNotification(_ userInfo: [AnyHashable: Any], completion: @escaping () -> Void) {
        // 添加详细的错误日志
        print("开始处理推送通知数据：", userInfo)
        
        guard let routeData = userInfo["route"] as? [String: Any] else {
            print("错误：推送数据中缺少route字段或格式错误")
            completion()
            return
        }
        
        guard let routeType = routeData["type"] as? String else {
            print("错误：route数据中缺少type字段或格式错误")
            completion()
            return
        }
        
        // 解析路由参数
        let parameters = routeData["parameters"] as? [String: Any] ?? [:]
        print("解析到路由类型：\(routeType)，参数：\(parameters)")
        
        // 构建路由目标
        let destination = NavigationType.from(routeType: routeType, parameters: parameters)
        
        // 发送路由通知
        NotificationCenter.default.post(
            name: .init("HandlePushNotificationRoute"),
            object: nil,
            userInfo: ["destination": destination]
        )
        
        print("推送通知处理完成，目标路由：\(destination)")
        completion()
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension PushNotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        handleNotification(notification.request.content.userInfo) {
            completionHandler([.banner, .sound])
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        handleNotification(response.notification.request.content.userInfo) {
            completionHandler()
        }
    }
}

// MARK: - NavigationType Extension
extension NavigationType {
    static func from(routeType: String, parameters: [String: Any]) -> NavigationType {
        print("开始解析路由类型：\(routeType)，参数：\(parameters)")
        
        switch routeType {
        case "article":
            if let articleId = parameters["id"] as? String {
                print("解析到文章路由，ID：\(articleId)")
                return .article(id: articleId)
            } else {
                print("错误：文章路由缺少有效的ID参数")
            }
        case "qa":
            if let qaId = parameters["id"] as? String {
                print("解析到问答路由，ID：\(qaId)")
                return .qa(id: qaId)
            } else {
                print("错误：问答路由缺少有效的ID参数")
            }
        case "profile":
            if let userId = parameters["userId"] as? String {
                print("解析到用户资料路由，用户ID：\(userId)")
                return .profile(userId: userId)
            } else {
                print("错误：用户资料路由缺少有效的用户ID参数")
            }
        case "hotTopic":
            if let topic = parameters["topic"] as? String {
                print("解析到热门话题路由，话题：\(topic)")
                return .hotTopic(topic: topic)
            } else {
                print("错误：热门话题路由缺少有效的话题参数")
            }
        default:
            print("警告：未知的路由类型：\(routeType)，将跳转到首页")
        }
        
        return .home
    }
}
