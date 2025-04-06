import SwiftUI
import UIKit

/// 抽屉容器视图控制器
/// 实现了一个可以从左侧滑出的抽屉效果，支持手势控制和动画
@MainActor
class DrawerContainerViewController: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - Configuration
    /// 抽屉配置参数
    private struct DrawerConfiguration {
        /// 抽屉宽度
        let width: CGFloat
        /// 阴影透明度
        let shadowOpacity: CGFloat = 0.25
        /// 动画持续时间
        let animationDuration: TimeInterval = 0.25
        /// 弹簧动画阻尼
        let springDamping: CGFloat = 0.85
        /// 拖拽阻尼
        let dragDamping: CGFloat = 0.8
        /// 速度阈值
        let velocityThreshold: CGFloat = 400
        /// 边缘触发区域宽度
        let edgeWidth: CGFloat = 32
        /// 吸附阈值
        let snapThreshold: CGFloat = 0.5
    }
    
    /// 抽屉宽度
    private var drawerWidth: CGFloat { configuration.width }
    
    // MARK: - Properties
    /// 主要内容视图控制器
    private let mainContent: UIViewController
    /// 抽屉内容视图控制器
    private let drawerContent: UIViewController
    /// 抽屉配置
    private let configuration: DrawerConfiguration
    /// 抽屉是否可见
    private var drawerVisible = false
    /// 拖用手势开始时主视图的中心点
    private var initialMainCenter: CGPoint = .zero
    /// 用于主视图遮罩效果的视图
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        return view
    }()
    
    // MARK: - 手势识别器
    /// 遮罩视图的点击手势，用于关闭抽屉
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        return gesture
    }()
    
    /// 遮罩视图的拖拽手势，用于关闭抽屉
    private lazy var shadowPanGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        return gesture
    }()
    
    /// 左边缘拖拽手势，用于打开抽屉
    private lazy var edgePanGesture: UIScreenEdgePanGestureRecognizer = {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        gesture.edges = .left
        gesture.delegate = self
        
        return gesture
    }()
    
    // MARK: - 视图状态管理
    /// 动画状态标记
    private var isAnimating = false
    
    /// 抽屉状态变化回调
    /// 用于通知SwiftUI视图状态更新
    var onDrawerStateChange: ((Bool) -> Void)?
    
    /// 抽屉可见状态
    /// 提供给SwiftUI使用的公开属性
    var isDrawerVisible: Bool {
        return drawerVisible
    }
    
    /// 视图生命周期标记
    internal var isViewVisible = true
    
    /// 动态字体大小支持
    internal var currentDynamicTypeSize: UIContentSizeCategory = .large
    
    /// 缓存当前是否为根层级状态
    private var isRootLevelCache: Bool?
    
    /// 上次检查根层级的时间戳
    private var lastRootLevelCheckTime: TimeInterval = 0
    
    /// 缓存刷新间隔（秒）
    private let cacheRefreshInterval: TimeInterval = 0.05
    
    // MARK: - 初始化方法
    /// 初始化抽屉容器
    /// - Parameters:
    ///   - mainContent: 主要内容视图控制器
    ///   - drawerContent: 抽屉内容视图控制器
    ///   - drawerWidth: 抽屉宽度，默认300点
    init(mainContent: UIViewController, drawerContent: UIViewController, drawerWidth: CGFloat = 300) {
        self.mainContent = mainContent
        self.drawerContent = drawerContent
        self.configuration = DrawerConfiguration(width: drawerWidth)
        super.init(nibName: nil, bundle: nil)
        self.view.backgroundColor = UIColor(named: "content_bg") // 确保背景颜色已设置
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestures()
    }
    
    // MARK: - 私有方法
    /// 设置视图层级和布局
    private func setupViews() {
        // 添加主视图（中间层）
        addChild(mainContent)
        view.addSubview(mainContent.view)
        mainContent.view.frame = view.bounds
        mainContent.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mainContent.didMove(toParent: self)
        
        // 添加抽屉视图（最底层）
        addChild(drawerContent)
        view.insertSubview(drawerContent.view, at: 0)
        let drawerContentFrame = CGRect(
            x: -configuration.width/2,
            y: 0,
            width: configuration.width,
            height: view.bounds.height
        )
        drawerContent.view.frame = drawerContentFrame
        drawerContent.view.alpha = 0.0  // 初始状态设置为透明
        drawerContent.didMove(toParent: self)
        
        // 添加遮罩视图到 mainContent.view 上
        mainContent.view.addSubview(shadowView)
        shadowView.frame = mainContent.view.bounds
        shadowView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        shadowView.isUserInteractionEnabled = true
        shadowView.isHidden = true
    }
    
    /// 设置手势识别
    private func setupGestures() {
        // 设置手势代理
        tapGesture.delegate = self
        shadowPanGesture.delegate = self
        
        // 添加手势识别器
        view.addGestureRecognizer(edgePanGesture)  // 边缘手势添加到最外层视图
        shadowView.addGestureRecognizer(tapGesture)
        shadowView.addGestureRecognizer(shadowPanGesture)
    }
    
    // MARK: - 手势处理
    /// 处理拖拽手势
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard !isAnimating, mainContent.view.superview != nil else { return }
        
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .began:
            initialMainCenter = mainContent.view.center
            
        case .changed:
            let newX = initialMainCenter.x + translation.x * configuration.dragDamping
            let centerX = view.bounds.width/2
            let maxX = centerX + configuration.width
            
            // 应用弹性效果
            if gesture === shadowPanGesture {
                mainContent.view.center.x = min(maxX, max(centerX, min(newX, initialMainCenter.x)))
            } else {
                mainContent.view.center.x = max(centerX, min(newX, maxX))
            }
            
            // 优化抽屉位置计算
            let drawerProgress = (mainContent.view.center.x - view.bounds.width/2) / configuration.width
            let drawerX = -configuration.width/2 * (1 - drawerProgress)
            drawerContent.view.frame.origin.x = drawerX
            
            // 更新抽屉内容透明度
            drawerContent.view.alpha = drawerProgress
            
            updateShadowViewFrame()
            
        case .ended, .cancelled:
            let progress = (mainContent.view.center.x - view.bounds.width/2) / configuration.width
            let velocityX = velocity.x
            
            let shouldOpen = velocityX > configuration.velocityThreshold || 
                            (abs(velocityX) < configuration.velocityThreshold && 
                             progress > configuration.snapThreshold)
            
            if shouldOpen {
                openDrawerWithVelocity(velocityX)
            } else {
                closeDrawerWithVelocity(velocityX)
            }
            
        default:
            break
        }
    }
    
    /// 处理遮罩视图的点击手势
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        closeDrawer(animated: true)
    }
    
    /// 打开抽屉
    func openDrawer(animated: Bool = true) {
        let animations = {
            self.mainContent.view.center.x = self.view.bounds.width/2 + self.configuration.width
            self.shadowView.alpha = 0.3
            self.updateShadowViewFrame()
            self.drawerContent.view.center.x = self.configuration.width / 2
            self.drawerContent.view.alpha = 1.0  // 完全显示抽屉内容
            
            // 设置圆角
            self.mainContent.view.layer.cornerRadius = 64
            self.mainContent.view.clipsToBounds = true
        }
        
        shadowView.isHidden = false
        drawerContent.view.isUserInteractionEnabled = true
        
        if animated {
            let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut, animations: animations)
            animator.startAnimation()
        } else {
            animations()
        }
        
        drawerVisible = true
        onDrawerStateChange?(true)
        
        // 添加导航栏配置
        configureNavigationBar(for: mainContent)
    }
    
    /// 关闭抽屉
    func closeDrawer(animated: Bool = true) {
        let animations = {
            self.mainContent.view.center.x = self.view.bounds.width/2
            self.drawerContent.view.center.x = 0
            self.shadowView.alpha = 0
            self.drawerContent.view.alpha = 0.0  // 完全隐藏抽屉内容
            
            // 恢复直角
            self.mainContent.view.layer.cornerRadius = 0
        }
        
        if animated {
            UIView.animate(withDuration: 0.3,
                         delay: 0,
                         options: [.curveEaseInOut, .beginFromCurrentState],
                         animations: animations) { _ in
                self.shadowView.isHidden = true
                self.drawerContent.view.isUserInteractionEnabled = false
            }
        } else {
            animations()
            shadowView.isHidden = true
            drawerContent.view.isUserInteractionEnabled = false
        }
        
        drawerVisible = false
        onDrawerStateChange?(false)
        
        // 添加导航栏配置
        configureNavigationBar(for: mainContent)
    }
    
    /// 使用速度信息打开抽屉
    private func openDrawerWithVelocity(_ velocity: CGFloat) {
        guard !isAnimating else { return }
        isAnimating = true
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            guard let self = self else { return }
            self.isAnimating = false
            self.drawerVisible = true
            self.onDrawerStateChange?(true)
            
            // 触觉反馈
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        
        let animator = UIViewPropertyAnimator(duration: configuration.animationDuration, dampingRatio: configuration.springDamping) {
            self.mainContent.view.center.x = self.view.bounds.width/2 + self.configuration.width
            self.drawerContent.view.frame.origin.x = 0
            self.drawerContent.view.alpha = 1.0  // 完全显示抽屉内容
            self.shadowView.alpha = self.configuration.shadowOpacity
            self.updateShadowViewFrame()
        }
        animator.startAnimation()
        
        CATransaction.commit()
        
        shadowView.isHidden = false
        drawerContent.view.isUserInteractionEnabled = true
        
        // 添加导航栏配置
        configureNavigationBar(for: mainContent)
    }
    
    /// 使用速度信息关闭抽屉
    private func closeDrawerWithVelocity(_ velocity: CGFloat) {
        isAnimating = true
        let distance = mainContent.view.center.x - view.bounds.width/2
        let springVelocity = abs(velocity / distance)
        
        // 添加性能优化
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            guard let self = self else { return }
            self.shadowView.isHidden = true
            self.drawerContent.view.isUserInteractionEnabled = false
            self.isAnimating = false
            self.drawerVisible = false
            self.onDrawerStateChange?(false)
        }
        
        UIView.animate(withDuration: configuration.animationDuration,
                      delay: 0,
                      usingSpringWithDamping: configuration.springDamping,
                      initialSpringVelocity: springVelocity,
                      options: [.curveEaseOut, .allowUserInteraction],
                      animations: {
            self.mainContent.view.center.x = self.view.bounds.width/2
            self.drawerContent.view.frame.origin.x = -self.configuration.width/2
            self.drawerContent.view.alpha = 0.0  // 完全隐藏抽屉内容
            self.shadowView.alpha = 0
        })
        
        CATransaction.commit()
        
        // 添加触觉反馈
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Add navigation bar configuration
        configureNavigationBar(for: mainContent)
    }
    
    /// 更新遮罩视图的frame以匹配主视图
    private func updateShadowViewFrame() {
        shadowView.frame = mainContent.view.bounds
        
        let progress = (mainContent.view.center.x - view.bounds.width/2) / configuration.width
        shadowView.alpha = min(progress * configuration.shadowOpacity, configuration.shadowOpacity)
    }
    
    // MARK: - 视图布局
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let frame = view.bounds
        
        // 更新主视图的frame，确保正确布局
        mainContent.view.frame = frame
        mainContent.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // 更新抽屉视图的frame
        drawerContent.view.frame = CGRect(
            x: 0,
            y: 0,
            width: configuration.width,
            height: frame.height
        )
        
        // 更新主视图的frame，考虑安全区域
        mainContent.view.frame = frame
    }
}

extension DrawerContainerViewController {
    // MARK: - UIGestureRecognizerDelegate
    /// 决定手势识别器是否应该开始工作
    /// - Parameter gestureRecognizer: 当前的手势识别器
    /// - Returns: 如果手势识别器应该开始工作则返回true，否则返回false
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 如果正在执行动画，不允许任何手势开始
        guard !isAnimating else { return false }
        
        // 对于边缘滑动手势，只有在根视图层级时才允许开始
        if gestureRecognizer === edgePanGesture {
            return checkRootLevel()
        }
        
        // 对于遮罩层的点击和滑动手势，只有在抽屉可见时才允许开始
        if gestureRecognizer === tapGesture || gestureRecognizer === shadowPanGesture {
            return drawerVisible
        }
        
        // 其他手势默认允许开始
        return true
    }
    
    /// 处理手势识别器的优先级
    /// - Parameters:
    ///   - gestureRecognizer: 当前手势识别器
    ///   - otherGestureRecognizer: 其他手势识别器
    /// - Returns: 如果当前手势应该优先于其他手势则返回true
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 如果是边缘手势且在根层级，则具有最高优先级
        if gestureRecognizer === edgePanGesture && checkRootLevel() {
            // 排除自身的其他手势
            if otherGestureRecognizer === tapGesture || otherGestureRecognizer === shadowPanGesture {
                return false
            }
            return true
        }
        return false
    }
    
    // MARK: - Helper Methods
    /// 检查是否在根层级，使用缓存机制提高性能
    /// - Returns: 如果当前视图控制器在导航栈的根层级则返回true，否则返回false
    /// - Note: 使用缓存机制避免频繁计算，提升性能
    private func checkRootLevel() -> Bool {
        let currentTime = CACurrentMediaTime()
        
        // 如果缓存存在且未超时，直接返回缓存值
        if let cachedValue = isRootLevelCache, currentTime - lastRootLevelCheckTime < cacheRefreshInterval {
            return cachedValue
        }
        
        // 重新计算根层级状态
        let isRoot = calculateRootLevel()
        
        // 更新缓存
        isRootLevelCache = isRoot
        lastRootLevelCheckTime = currentTime
        
        return isRoot
    }
    
    /// 计算当前视图控制器是否处于导航栈的根层级
    /// - Returns: 如果是根层级返回true，否则返回false
    private func calculateRootLevel() -> Bool {
        // 安全检查：确保视图当前可见
        guard isViewVisible else { return false }
        
        // 检查主内容视图是否已添加到窗口层级
        guard mainContent.view.window != nil else { return false }
        
        // 检查导航控制器层级
        // 如果主内容本身是导航控制器，检查其视图控制器栈
        if let navigationController = mainContent as? UINavigationController {
            return navigationController.viewControllers.count == 1
        } 
        // 如果主内容被嵌入在导航控制器中，检查父导航控制器的视图控制器栈
        else if let parentNav = mainContent.navigationController {
            return parentNav.viewControllers.count == 1
        }
        
        // 确保导航栏配置正确
        configureNavigationBar(for: mainContent)
        
        // 如果不在导航控制器中，则视为根层级
        return true
    }
    
    /// 视图即将显示时调用
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 进入视图时刷新缓存
        isRootLevelCache = nil
    }
    
    /// 视图已经消失时调用
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 离开视图时清除缓存
        isRootLevelCache = nil
    }
    
    /// 配置导航栏
    /// - Parameters:
    ///   - viewController: 需要配置导航栏的视图控制器
    /// - Note: 确保导航栏在抽屉操作时保持可见状态
    private func configureNavigationBar(for viewController: UIViewController) {
        if let navigationController = viewController.navigationController {
            navigationController.setNavigationBarHidden(false, animated: false)
            navigationController.navigationBar.isHidden = false
        }
    }
}
