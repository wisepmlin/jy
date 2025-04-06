//
//  jyApp.swift
//  jy
//
//  Created by 林晓彬 on 2025/1/24.
//

import SwiftUI
import UserNotifications
import MonkeyKing

// MARK: - 通知常量
extension Notification.Name {
    static let handlePushNotificationRoute = Notification.Name("HandlePushNotificationRoute")
}

// MARK: - App Delegate
class AppDelegate: NSObject, ObservableObject {
    static let shared = AppDelegate()
    private var isInitialized = false
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        if true {
            clearAllLocalTokens()
        }
        
        MonkeyKing.registerLaunchFromWeChatMiniAppHandler { messageExt in
            print("messageExt:", messageExt)
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return MonkeyKing.handleOpenURL(url)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return MonkeyKing.handleOpenURL(url)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return MonkeyKing.handleOpenUserActivity(userActivity)
    }
    
    private func clearAllLocalTokens() {
        let secItemClasses = [kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity]
        for itemClass in secItemClasses {
            let spec: NSDictionary = [kSecClass: itemClass]
            SecItemDelete(spec)
        }

        UserDefaults.standard
            .dictionaryRepresentation().keys
            .forEach(UserDefaults.standard.removeObject)
    }

    
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // 注册远程通知
        UNUserNotificationCenter.current().delegate = self
        isInitialized = true
        
        // 处理启动时的推送
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any],
           let dict = notification as? [String: Any] {
            print("通过推送启动应用：", notification)
            UserDefaults.standard.setValue(dict, forKey: "PendingPushNotification")
            UserDefaults.standard.synchronize()
        }
        
        // 注册微信
        MonkeyKing.registerAccount(
            .weChat(
                appID: "xxx",
                appKey: "yyy",
                miniAppID: nil,
                universalLink: nil // FIXME: You have to adopt Universal Link otherwise your app name becomes "Unauthorized App"(未验证应用)...
            )
        )
        
        return true
    }
    
    func application(_ application: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        PushNotificationService.shared.deviceToken = token
    }
    
    func application(_ application: UIApplication,
                    didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("推送注册失败: \(error)")
    }
    
    // 如果您在项目中使用UIScene，请记得处理用户活动：
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        _ = MonkeyKing.handleOpenUserActivity(userActivity)
    }
    
    // MARK: - 推送处理
    func handlePushNotification(_ userInfo: [AnyHashable: Any]) {
        guard isInitialized else {
            print("错误：应用尚未初始化完成，无法处理推送通知")
            return
        }
        
        guard let dict = userInfo as? [String: Any] else {
            print("错误：推送数据格式转换失败，原始数据：", userInfo)
            return
        }
        
        print("开始处理推送数据：", dict)
        UserDefaults.standard.setValue(dict, forKey: "PendingPushNotification")
        UserDefaults.standard.synchronize()
        
        PushNotificationService.shared.handleNotification(dict) {
            print("推送路由处理完成")
        }
    }
    
}

// MARK: - 推送通知代理
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("用户点击推送：", userInfo)
        handlePushNotification(userInfo)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                              willPresent notification: UNNotification,
                              withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("应用前台收到推送，仅显示通知：", userInfo)
        completionHandler([.banner, .sound])
    }
}

// MARK: - App 主入口
@main
struct jyApp: App {
    @StateObject private var appDelegate = AppDelegate.shared
    @StateObject private var pushNotificationService = PushNotificationService.shared
    @State private var navigationPath: [NavigationType] = []
    
    var body: some Scene {
        WindowGroup {
            LaunchScreenView(navigationPath: $navigationPath)
                .trackDetailedAppLifecycle(
                    onBecomeActive: {
                        print("应用变为活跃状态")
                        // 检查并处理待处理的推送通知
                        if let pendingNotification = UserDefaults.standard.dictionary(forKey: "PendingPushNotification") {
                            print("检测到待处理的推送通知：", pendingNotification)
                            UserDefaults.standard.removeObject(forKey: "PendingPushNotification")
                            UserDefaults.standard.synchronize()
                            
                            // 处理推送通知
                            PushNotificationService.shared.handleNotification(pendingNotification) {
                                print("待处理的推送通知路由处理完成")
                            }
                        }
                    }
                )
                .onReceive(NotificationCenter.default.publisher(for: .handlePushNotificationRoute)) { notification in
                    print("收到路由通知：", notification.userInfo ?? [:])
                    handleNotificationRoute(notification)
                }
                .environmentObject(pushNotificationService)
        }
        .handlesExternalEvents(matching: Set(arrayLiteral: "*"))
    }
    
    // MARK: - 路由处理
    private func handleNotificationRoute(_ notification: NotificationCenter.Publisher.Output) {
        guard let userInfo = notification.userInfo else {
            print("错误：通知数据为空")
            return
        }
        
        print("开始处理路由通知：", userInfo)
        
        if let destination = userInfo["destination"] as? NavigationType {
            print("成功解析到目标路由：", destination)
            DispatchQueue.main.async {
                navigationPath.append(destination)
            }
            return
        }
        
        // 尝试手动解析路由
        if let rawDestination = userInfo["destination"] as? [String: Any],
           let type = rawDestination["type"] as? String {
            print("尝试手动解析路由类型：", type)
            switch type {
            case "hotTopic":
                if let topic = rawDestination["topic"] as? String {
                    print("成功解析热门话题路由，话题：", topic)
                    let destination = NavigationType.hotTopic(topic: topic)
                    DispatchQueue.main.async {
                        navigationPath.append(destination)
                    }
                } else {
                    print("错误：热门话题路由缺少topic参数")
                }
            default:
                print("错误：未知的路由类型：", type)
            }
        } else {
            print("错误：无法解析目标路由，数据格式不正确")
        }
    }
}
