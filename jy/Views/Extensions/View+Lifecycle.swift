import SwiftUI
import UIKit
import Network

public extension View {
    /// 跟踪视图的生命周期事件
    @ViewBuilder
    func trackLifecycle(
        onAppear: (() -> Void)? = nil,
        onDisappear: (() -> Void)? = nil
    ) -> some View {
        self
            .onAppear {
                onAppear?()
            }
            .onDisappear {
                onDisappear?()
            }
    }
    
    /// 仅跟踪视图出现事件
    func trackAppearance(action: @escaping () -> Void) -> some View {
        trackLifecycle(onAppear: action)
    }
    
    /// 仅跟踪视图消失事件
    func trackDisappearance(action: @escaping () -> Void) -> some View {
        trackLifecycle(onDisappear: action)
    }
    
    /// 跟踪应用前台/后台生命周期
    @ViewBuilder
    func trackAppLifecycle(
        onEnterForeground: (() -> Void)? = nil,
        onEnterBackground: (() -> Void)? = nil
    ) -> some View {
        self.onAppear {
            if let onEnterForeground = onEnterForeground {
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("UIApplicationWillEnterForegroundNotification"),
                    object: nil,
                    queue: .main
                ) { _ in
                    onEnterForeground()
                }
            }
            
            if let onEnterBackground = onEnterBackground {
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("UIApplicationDidEnterBackgroundNotification"),
                    object: nil,
                    queue: .main
                ) { _ in
                    onEnterBackground()
                }
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(
                self,
                name: NSNotification.Name("UIApplicationWillEnterForegroundNotification"),
                object: nil
            )
            NotificationCenter.default.removeObserver(
                self,
                name: NSNotification.Name("UIApplicationDidEnterBackgroundNotification"),
                object: nil
            )
        }
    }
    
    /// 仅跟踪前台事件
    func trackForeground(action: @escaping () -> Void) -> some View {
        trackAppLifecycle(onEnterForeground: action)
    }
    
    /// 仅跟踪后台事件
    func trackBackground(action: @escaping () -> Void) -> some View {
        trackAppLifecycle(onEnterBackground: action)
    }
    
    /// 跟踪详细的应用生命周期事件
    @ViewBuilder
    func trackDetailedAppLifecycle(
        onBecomeActive: (() -> Void)? = nil,    // 应用变为活跃状态时调用
        onResignActive: (() -> Void)? = nil,    // 应用即将进入非活跃状态时调用
        onMemoryWarning: (() -> Void)? = nil,   // 收到内存警告时调用
        onWillTerminate: (() -> Void)? = nil    // 应用即将终止时调用
    ) -> some View {
        self.onAppear {
            if let onBecomeActive = onBecomeActive {
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("UIApplicationDidBecomeActiveNotification"),
                    object: nil,
                    queue: .main
                ) { _ in
                    onBecomeActive()
                }
            }
            
            if let onResignActive = onResignActive {
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("UIApplicationWillResignActiveNotification"),
                    object: nil,
                    queue: .main
                ) { _ in
                    onResignActive()
                }
            }
            
            if let onMemoryWarning = onMemoryWarning {
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("UIApplicationDidReceiveMemoryWarningNotification"),
                    object: nil,
                    queue: .main
                ) { _ in
                    onMemoryWarning()
                }
            }
            
            if let onWillTerminate = onWillTerminate {
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("UIApplicationWillTerminateNotification"),
                    object: nil,
                    queue: .main
                ) { _ in
                    onWillTerminate()
                }
            }
        }
        .onDisappear {
            // 清理所有观察者
            let notifications: [NSNotification.Name] = [
                NSNotification.Name("UIApplicationDidBecomeActiveNotification"),
                NSNotification.Name("UIApplicationWillResignActiveNotification"),
                NSNotification.Name("UIApplicationDidReceiveMemoryWarningNotification"),
                NSNotification.Name("UIApplicationWillTerminateNotification")
            ]
            
            notifications.forEach { notification in
                NotificationCenter.default.removeObserver(
                    self,
                    name: notification,
                    object: nil
                )
            }
        }
    }
    
    /// 跟踪应用活跃状态变化
    func trackActiveState(
        onBecomeActive: @escaping () -> Void,    // 变为活跃状态时调用
        onResignActive: @escaping () -> Void     // 变为非活跃状态时调用
    ) -> some View {
        trackDetailedAppLifecycle(
            onBecomeActive: onBecomeActive,
            onResignActive: onResignActive
        )
    }
    
    /// 跟踪内存警告
    func trackMemoryWarning(action: @escaping () -> Void) -> some View {
        trackDetailedAppLifecycle(onMemoryWarning: action)
    }
    
    /// 跟踪应用终止事件
    func trackTermination(action: @escaping () -> Void) -> some View {
        trackDetailedAppLifecycle(onWillTerminate: action)
    }
    
    /// 跟踪网络状态变化
    @ViewBuilder
    func trackNetworkStatus(
        onConnected: (() -> Void)? = nil,           // 网络连接时调用
        onDisconnected: (() -> Void)? = nil,        // 网络断开时调用
        onCellular: (() -> Void)? = nil,            // 切换到蜂窝网络时调用
        onWiFi: (() -> Void)? = nil                 // 切换到WiFi时调用
    ) -> some View {
        self.onAppear {
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { path in
                DispatchQueue.main.async {
                    if path.status == .satisfied {
                        onConnected?()
                        if path.usesInterfaceType(.cellular) {
                            onCellular?()
                        } else if path.usesInterfaceType(.wifi) {
                            onWiFi?()
                        }
                    } else {
                        onDisconnected?()
                    }
                }
            }
            monitor.start(queue: DispatchQueue.global())
        }
    }
    
    /// 跟踪用户交互事件
    @ViewBuilder
    func trackUserInteraction(
        onScreenshot: (() -> Void)? = nil,          // 截屏时调用
        onScreenRecording: (() -> Void)? = nil,     // 开始录屏时调用
        onShake: (() -> Void)? = nil,               // 摇动设备时调用
        onOrientationChange: (() -> Void)? = nil    // 设备方向改变时调用
    ) -> some View {
        self.onAppear {
            // 截屏监听
            if let onScreenshot = onScreenshot {
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("UIApplicationUserDidTakeScreenshotNotification"),
                    object: nil,
                    queue: .main
                ) { _ in
                    onScreenshot()
                }
            }
            
            // 录屏监听
            if let onScreenRecording = onScreenRecording {
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("UIScreenCapturedDidChangeNotification"),
                    object: nil,
                    queue: .main
                ) { _ in
                    onScreenRecording()
                }
            }
            
            // 设备方向监听
            if let onOrientationChange = onOrientationChange {
                NotificationCenter.default.addObserver(
                    forName: NSNotification.Name("UIDeviceOrientationDidChangeNotification"),
                    object: nil,
                    queue: .main
                ) { _ in
                    onOrientationChange()
                }
            }
        }
        .onDisappear {
            // 清理观察者
            let notifications: [NSNotification.Name] = [
                NSNotification.Name("UIApplicationUserDidTakeScreenshotNotification"),
                NSNotification.Name("UIScreenCapturedDidChangeNotification"),
                NSNotification.Name("UIDeviceOrientationDidChangeNotification")
            ]
            
            notifications.forEach { notification in
                NotificationCenter.default.removeObserver(
                    self,
                    name: notification,
                    object: nil
                )
            }
        }
    }
    
    /// 仅跟踪网络连接状态
    func trackConnectivity(
        onConnected: @escaping () -> Void,
        onDisconnected: @escaping () -> Void
    ) -> some View {
        trackNetworkStatus(
            onConnected: onConnected,
            onDisconnected: onDisconnected
        )
    }
    
    /// 仅跟踪网络类型
    func trackNetworkType(
        onCellular: @escaping () -> Void,
        onWiFi: @escaping () -> Void
    ) -> some View {
        trackNetworkStatus(
            onCellular: onCellular,
            onWiFi: onWiFi
        )
    }
    
    /// 仅跟踪截屏事件
    func trackScreenshot(action: @escaping () -> Void) -> some View {
        trackUserInteraction(onScreenshot: action)
    }
    
    /// 仅跟踪录屏事件
    func trackScreenRecording(action: @escaping () -> Void) -> some View {
        trackUserInteraction(onScreenRecording: action)
    }
    
    /// 跟踪用户活跃度
    @ViewBuilder
    func trackUserActivity(
        onBecomeIdle: (() -> Void)? = nil,          // 用户变为空闲状态时调用
        onBecomeActive: (() -> Void)? = nil,        // 用户重新活跃时调用
        onFocusChange: ((Bool) -> Void)? = nil,     // 焦点状态改变时调用
        idleTimeout: TimeInterval = 300             // 空闲超时时间（默认5分钟）
    ) -> some View {
        self
            .onAppear {
                // 焦点监听
                if let onFocusChange = onFocusChange {
                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name("UIWindowDidBecomeKeyNotification"),
                        object: nil,
                        queue: .main
                    ) { _ in
                        onFocusChange(true)
                    }
                    
                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name("UIWindowDidResignKeyNotification"),
                        object: nil,
                        queue: .main
                    ) { _ in
                        onFocusChange(false)
                    }
                }
            }
            .onTapGesture {
                onBecomeActive?()
                // 重置空闲计时器
                resetIdleTimer()
            }
            .onAppear {
                startIdleTimer(timeout: idleTimeout) {
                    onBecomeIdle?()
                }
            }
            .onDisappear {
                stopIdleTimer()
                // 清理观察者
                NotificationCenter.default.removeObserver(
                    self,
                    name: NSNotification.Name("UIWindowDidBecomeKeyNotification"),
                    object: nil
                )
                NotificationCenter.default.removeObserver(
                    self,
                    name: NSNotification.Name("UIWindowDidResignKeyNotification"),
                    object: nil
                )
            }
    }
    
    /// 跟踪内容保护
    @ViewBuilder
    func trackContentProtection(
        onCopy: (() -> Void)? = nil,                // 复制时调用
        onPaste: (() -> Void)? = nil,               // 粘贴时调用
        onSelection: (() -> Void)? = nil,           // 选择内容时调用
        onLongPress: (() -> Void)? = nil            // 长按时调用
    ) -> some View {
        self
            .onAppear {
                if let onCopy = onCopy {
                    NotificationCenter.default.addObserver(
                        forName: NSNotification.Name("UIPasteboardChangedNotification"),
                        object: nil,
                        queue: .main
                    ) { _ in
                        onCopy()
                    }
                }
            }
            .onLongPressGesture {
                onLongPress?()
            }
            .gesture(
                TapGesture()
                    .simultaneously(with: SelectionGesture())
                    .onEnded { _ in
                        onSelection?()
                    }
            )
            .onDisappear {
                NotificationCenter.default.removeObserver(
                    self,
                    name: NSNotification.Name("UIPasteboardChangedNotification"),
                    object: nil
                )
            }
    }
    
    /// 仅跟踪用户空闲状态
    func trackIdle(
        timeout: TimeInterval = 300,
        onBecomeIdle: @escaping () -> Void
    ) -> some View {
        trackUserActivity(
            onBecomeIdle: onBecomeIdle,
            idleTimeout: timeout
        )
    }
    
    /// 仅跟踪焦点变化
    func trackFocus(onChange: @escaping (Bool) -> Void) -> some View {
        trackUserActivity(onFocusChange: onChange)
    }
    
    /// 仅跟踪复制事件
    func trackCopy(action: @escaping () -> Void) -> some View {
        trackContentProtection(onCopy: action)
    }
    
    /// 仅跟踪长按事件
    func trackLongPress(action: @escaping () -> Void) -> some View {
        trackContentProtection(onLongPress: action)
    }
    
    /// 设置滚动时收起键盘的行为
    func dismissKeyboardOnScroll(mode: ScrollDismissesKeyboardMode = .immediately) -> some View {
        self.scrollDismissesKeyboard(mode)
    }
}

// MARK: - Private Helper Methods
private extension View {
    func startIdleTimer(timeout: TimeInterval, action: @escaping () -> Void) {
        // 实现空闲计时器逻辑
    }
    
    func resetIdleTimer() {
        // 重置计时器逻辑
    }
    
    func stopIdleTimer() {
        // 停止计时器逻辑
    }
}

// MARK: - Custom Gestures
private struct SelectionGesture: Gesture {
    let onSelection: () -> Void
    
    init(onSelection: @escaping () -> Void = {}) {
        self.onSelection = onSelection
    }
    
    var body: some Gesture {
        DragGesture(minimumDistance: 0)
            .onEnded { _ in
                onSelection()
            }
    }
} 