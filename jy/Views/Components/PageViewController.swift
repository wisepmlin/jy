import SwiftUI
import UIKit

struct PageViewController<Page: View>: UIViewControllerRepresentable {
    // 新增SwiftUI 6.0特性支持
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    /// 要显示的页面数组，每个页面都是一个SwiftUI视图
    var pages: [Page]
    
    /// 当前显示的页面索引
    /// 使用@Binding实现双向绑定，当页面切换时可以更新外部状态
    @Binding var currentPage: Int
    
    /// 是否启用循环滚动
    /// 当设置为true时，滑动到最后一页后可以继续滑动回到第一页，反之亦然
    var isLoopEnabled: Bool
    
    /// 是否启用滑动切换
    var isSwipeEnabled: Bool
    
    /// 实现Equatable协议，用于优化视图更新
    /// 只有当currentPage发生变化时才会触发视图更新
    static func == (lhs: PageViewController, rhs: PageViewController) -> Bool {
        lhs.currentPage == rhs.currentPage
    }
    
    /// 初始化PageViewController
    /// - Parameters:
    ///   - pages: 要显示的页面数组
    ///   - currentPage: 当前页面索引的绑定
    ///   - isLoopEnabled: 是否启用循环滚动，默认为true
    ///   - isSwipeEnabled: 是否启用滑动切换，默认为true
    init(pages: [Page], currentPage: Binding<Int>, isLoopEnabled: Bool = false, isSwipeEnabled: Bool = true) {
        self.pages = pages
        self._currentPage = currentPage
        self.isLoopEnabled = isLoopEnabled
        self.isSwipeEnabled = isSwipeEnabled
    }
    
    /// 创建并配置UIPageViewController实例
    /// - Parameter context: 上下文对象，包含协调器等信息
    /// - Returns: 配置好的UIPageViewController实例
    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: layoutDirection == .rightToLeft ? .horizontal : .horizontal,
            options: [UIPageViewController.OptionsKey.interPageSpacing: 0]  // 减小页面间距
        )
        
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        pageViewController.view.backgroundColor = .clear
        
        // Ensure navigation bar is visible
        DispatchQueue.main.async {
            if let navigationController = pageViewController.navigationController {
                navigationController.setNavigationBarHidden(false, animated: false)
                navigationController.navigationBar.isHidden = false
            }
        }
        
        // 优化滚动视图配置
        if let scrollView = pageViewController.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            // 减少滚动阻力
            if #available(iOS 13.0, *) {
                scrollView.contentInsetAdjustmentBehavior = .never
            }
        }
        
        // 设置初始页面
        if let initialVC = context.coordinator.controllers[safe: currentPage] {
            pageViewController.setViewControllers([initialVC], direction: .forward, animated: false)
        }
        
        return pageViewController
    }
    
    /// 更新UIPageViewController的状态
    /// 当绑定的currentPage值改变时，更新显示的页面
    /// - Parameters:
    ///   - pageViewController: 要更新的UIPageViewController实例
    ///   - context: 上下文对象
    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        context.coordinator.updateLifecycle()
        context.coordinator.updateDynamicTypeSize(dynamicTypeSize)
        context.coordinator.parent = self
        
        // Ensure navigation bar is visible
        DispatchQueue.main.async {
            if let navigationController = pageViewController.navigationController {
                navigationController.setNavigationBarHidden(false, animated: false)
                navigationController.navigationBar.isHidden = false
            }
        }
        
        // 检查并更新当前页面
        if let currentVC = pageViewController.viewControllers?.first,
           let currentIndex = context.coordinator.controllers.firstIndex(of: currentVC),
           currentIndex != currentPage,
           let targetVC = context.coordinator.controllers[safe: currentPage] {
            
            pageViewController.setViewControllers(
                [targetVC],
                direction: currentPage > currentIndex ? .forward : .reverse,
                animated: isSwipeEnabled,
                completion: nil
            )
        }
    }
    
    /// 创建协调器实例
    /// 协调器负责处理UIPageViewController的数据源和委托方法
    /// - Returns: 配置好的协调器实例
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    /// 协调器类，处理UIPageViewController的数据源和委托
    /// 负责：
    /// - 管理页面控制器的缓存
    /// - 处理页面切换事件
    /// - 响应内存警告
    /// - 提供相邻页面的访问
    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        // 新增生命周期管理
        private var isVisible = true
        private var preferredContentSize: CGSize = .zero
        
        // 动态字体大小支持
        private var currentDynamicTypeSize: DynamicTypeSize = .large
        /// 对父视图控制器的引用
        /// 注意：这里不使用weak，因为PageViewController是值类型（结构体）
        var parent: PageViewController
        
        /// 页面控制器的缓存
        /// 使用NSCache提供自动缓存管理，在内存压力大时自动清理
        private let controllerCache = NSCache<NSNumber, UIViewController>()
        private let maxCacheSize = 3 // 最大缓存数量
        private var lastCleanupTime = Date()
        private let cleanupInterval: TimeInterval = 30 // 30秒清理一次
        
        /// 延迟加载的控制器数组
        /// 只有在首次访问时才会创建所有控制器
        lazy var lazyControllers: [UIViewController] = {
            (0..<parent.pages.count).map { getController(for: $0) }
        }()
        
        /// 获取所有页面控制器的数组
        /// 这是一个计算属性，每次访问都会返回lazyControllers
        var controllers: [UIViewController] {
            lazyControllers
        }
        
        init(_ pageViewController: PageViewController) {
            // 初始化新增属性
            self.currentDynamicTypeSize = pageViewController.dynamicTypeSize
            self.isVisible = true
            self.parent = pageViewController
            super.init()
            
            // 设置缓存限制
            controllerCache.countLimit = maxCacheSize
            controllerCache.totalCostLimit = 3000 * 1024 * 1024  // 3000MB
            
            // 注册内存警告通知
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleMemoryWarning),
                name: UIApplication.didReceiveMemoryWarningNotification,
                object: nil
            )
            
            // Add lifecycle observers
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(applicationDidEnterBackground),
                name: UIApplication.didEnterBackgroundNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(applicationWillEnterForeground),
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
        }
        
        /// 获取指定索引的控制器
        /// 优先从缓存中获取，如果缓存中不存在则创建新的控制器
        /// - Parameter index: 要获取的控制器索引
        /// - Returns: 对应索引的UIViewController实例
        private func getController(for index: Int) -> UIViewController {
            let key = NSNumber(value: index)
            if let cached = controllerCache.object(forKey: key) {
                return cached
            }
            
            // 改进 UIHostingController 的创建和配置
            let hostingController = UIHostingController(rootView: parent.pages[index])
            hostingController.view.backgroundColor = .clear
            
            // 添加适当的视图控制器容器管理
            hostingController.willMove(toParent: nil)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            
            // 确保视图尺寸正确
            hostingController.view.frame = UIScreen.main.bounds
            hostingController.view.layoutIfNeeded()
            
            controllerCache.setObject(hostingController, forKey: key, cost: 1024 * 1024)
            
            return hostingController
        }
        
        /// 预加载当前页面相邻的页面
        /// 提前加载前一页和后一页，优化用户体验
        /// - Parameter index: 当前页面的索引
        private func preloadAdjacentControllers(for index: Int) {
            // 预加载前一页
            if index > 0 {
                let prevKey = NSNumber(value: index - 1)
                if controllerCache.object(forKey: prevKey) == nil {
                    let controller = UIHostingController(rootView: parent.pages[index - 1])
                    controller.view.backgroundColor = .clear
                    controllerCache.setObject(controller, forKey: prevKey)
                }
            }
            
            // 预加载后一页
            if index < parent.pages.count - 1 {
                let nextKey = NSNumber(value: index + 1)
                if controllerCache.object(forKey: nextKey) == nil {
                    let controller = UIHostingController(rootView: parent.pages[index + 1])
                    controller.view.backgroundColor = .clear
                    controllerCache.setObject(controller, forKey: nextKey)
                }
            }
        }
        
        /// 清理不需要的缓存
        /// 只保留当前页面及其相邻页面的缓存，释放其他页面的内存
        /// - Parameter currentIndex: 当前页面的索引
        private func cleanupCache(currentIndex: Int) {
            let now = Date()
            // 检查是否需要执行清理
            guard now.timeIntervalSince(lastCleanupTime) >= cleanupInterval else {
                return
            }
            
            lastCleanupTime = now
            
            let indices = [
                currentIndex - 1,
                currentIndex,
                currentIndex + 1
            ]
            
            let keysToKeep: Set<NSNumber> = Set(indices.compactMap { index in
                guard index >= 0,
                      index < parent.pages.count else { return nil }
                return NSNumber(value: index)
            })
            
            // 获取所有缓存的键
            let allKeys = (0..<parent.pages.count).map { NSNumber(value: $0) }
            
            // 清理不需要保留的缓存
            allKeys.forEach { key in
                if !keysToKeep.contains(key) {
                    controllerCache.removeObject(forKey: key)
                }
            }
        }
        
        /// 处理系统内存警告
        /// 当收到内存警告时，清理除当前页面及其相邻页面外的所有缓存
        @objc private func handleMemoryWarning() {
            cleanupCache(currentIndex: parent.currentPage)
        }
        
        /// 获取指定视图控制器的前一个视图控制器
        /// 如果启用了循环滚动，当前是第一页时返回最后一页
        /// - Parameters:
        ///   - pageViewController: 页面视图控制器
        ///   - viewController: 当前的视图控制器
        /// - Returns: 前一个视图控制器，如果不存在则返回nil
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else { return nil }
            
            if parent.isLoopEnabled {
                return index == 0 ? controllers.last : controllers[index - 1]
            }
            return index == 0 ? nil : controllers[index - 1]
        }
        
        /// 获取指定视图控制器的后一个视图控制器
        /// 如果启用了循环滚动，当前是最后一页时返回第一页
        /// - Parameters:
        ///   - pageViewController: 页面视图控制器
        ///   - viewController: 当前的视图控制器
        /// - Returns: 后一个视图控制器，如果不存在则返回nil
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            guard let index = controllers.firstIndex(of: viewController) else { return nil }
            
            if parent.isLoopEnabled {
                return index == controllers.count - 1 ? controllers.first : controllers[index + 1]
            }
            return index == controllers.count - 1 ? nil : controllers[index + 1]
        }
        
        /// 页面切换动画完成后的回调
        /// 更新currentPage并清理缓存
        /// - Parameters:
        ///   - pageViewController: 页面视图控制器
        ///   - finished: 动画是否完成
        ///   - previousViewControllers: 之前的视图控制器数组
        ///   - completed: 转场是否完成
        func pageViewController(
            _ pageViewController: UIPageViewController,
            didFinishAnimating finished: Bool,
            previousViewControllers: [UIViewController],
            transitionCompleted completed: Bool
        ) {
            guard finished,
                  let currentVC = pageViewController.viewControllers?.first,
                  let index = controllers.firstIndex(of: currentVC) else { return }
            
            // 清理之前的视图控制器
            previousViewControllers.forEach { cleanupViewController($0) }
            
            // 使用主线程延迟更新，避免动画过程中的状态更新
            DispatchQueue.main.async { [weak self] in
                if completed {
                    self?.parent.currentPage = index
                    self?.cleanupCache(currentIndex: index)
                    
                    // 确保当前视图布局正确
                    (currentVC as? UIHostingController<Page>)?.view.layoutIfNeeded()
                }
            }
        }
        
        /// 递归搜索视图层级中的UIScrollView
        func findScrollView(in view: UIView) -> UIScrollView? {
            for subview in view.subviews {
                if let scrollView = subview as? UIScrollView {
                    return scrollView
                }
                if let found = findScrollView(in: subview) {
                    return found
                }
            }
            return nil
        }
        
        /// 切换到指定页面
        /// - Parameters:
        ///   - targetPage: 目标页面索引
        ///   - animated: 是否使用动画效果
        func switchToPage(_ targetPage: Int, animated: Bool = true) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                
                // 递归查找 UIPageViewController
                func findPageViewController(in viewController: UIViewController) -> UIPageViewController? {
                    if let pageVC = viewController as? UIPageViewController {
                        return pageVC
                    }
                    
                    for child in viewController.children {
                        if let pageVC = findPageViewController(in: child) {
                            return pageVC
                        }
                    }
                    
                    return nil
                }
                
                if let pageViewController = findPageViewController(in: rootViewController) {
                    parent.switchToPage(pageViewController, coordinator: self, targetPage: targetPage, animated: animated)
                }
            }
        }
        
        // 更新生命周期状态
        func updateLifecycle() {
            if !isVisible {
                cleanupCache(currentIndex: parent.currentPage)
            }
        }
        
        // 处理动态字体大小变化
        func updateDynamicTypeSize(_ newSize: DynamicTypeSize) {
            guard newSize != currentDynamicTypeSize else { return }
            currentDynamicTypeSize = newSize
            
            // 重新加载当前页面以适应新的字体大小
            if let currentVC = controllers[safe: parent.currentPage] {
                (currentVC as? UIHostingController<Page>)?.rootView = parent.pages[parent.currentPage]
            }
        }
        
        @objc private func applicationDidEnterBackground() {
            // Store navigation bar state if needed
        }
        
        @objc private func applicationWillEnterForeground() {
            // Enhanced navigation bar restoration
        }
        
        deinit {
            // 确保清理所有缓存的视图控制器
            controllerCache.removeAllObjects()
            NotificationCenter.default.removeObserver(self)
        }
        
        // 改进视图控制器生命周期管理
        private func cleanupViewController(_ viewController: UIViewController) {
            viewController.willMove(toParent: nil)
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
            viewController.didMove(toParent: nil)
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            willTransitionTo pendingViewControllers: [UIViewController]
        ) {
            // 预处理即将显示的视图控制器
            pendingViewControllers.forEach { viewController in
                (viewController as? UIHostingController<Page>)?.view.layoutIfNeeded()
            }
        }
    }
    
    /// 以编程方式切换到指定页面
    /// - Parameters:
    ///   - pageViewController: UIPageViewController实例
    ///   - coordinator: Coordinator实例
    ///   - targetPage: 目标页面索引
    ///   - animated: 是否使用动画效果
    private func switchToPage(
        _ pageViewController: UIPageViewController,
        coordinator: Coordinator,
        targetPage: Int,
        animated: Bool = true
    ) {
        guard targetPage >= 0 && targetPage < pages.count else { return }
        
        let direction: UIPageViewController.NavigationDirection = targetPage > currentPage ? .forward : .reverse
        if let targetVC = coordinator.controllers[safe: targetPage] {
            // 确保目标视图控制器准备就绪
            (targetVC as? UIHostingController<Page>)?.view.layoutIfNeeded()
            
            // 使用同步动画避免状态不一致
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                DispatchQueue.main.async {
                    self.currentPage = targetPage
                }
            }
            
            pageViewController.setViewControllers(
                [targetVC],
                direction: direction,
                animated: animated && isSwipeEnabled,
                completion: nil
            )
            
            CATransaction.commit()
        }
    }
}

// 集合安全访问扩展
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
