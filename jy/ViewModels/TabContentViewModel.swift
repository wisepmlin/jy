import SwiftUI

// 首先创建一个服务层
class ContentService {
    static let shared = ContentService()
    
    private var cache: NSCache<NSString, NSArray> = {
        let cache = NSCache<NSString, NSArray>()
        cache.countLimit = 10
        return cache
    }()
    
    private init() {}
    
    func getCachedData(for page: Int) -> [TopicItem]? {
        return cache.object(forKey: "page_\(page)" as NSString) as? [TopicItem]
    }
    
    func cacheData(_ data: [TopicItem], for page: Int) {
        cache.setObject(data as NSArray, forKey: "page_\(page)" as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}

@MainActor
class TabContentViewModel: ObservableObject {
    @Published private(set) var topicGroups: [[TopicItem]] = []
    @Published private(set) var isLoading = false
    @Published private(set) var hasMoreData = true
    
    private var currentPage = 1
    private let pageSize = 5 // 每组5篇文章
    private var isPreloading = false // 预加载标志
    
    // 添加任务取消支持
    private var refreshTask: Task<Void, Never>?
    private var preloadTask: Task<Void, Never>?
    
    // 使用依赖注入
    private let contentService: ContentService
    
    init(contentService: ContentService = .shared) {
        self.contentService = contentService
    }
    
    func refreshData() async {
        // 取消之前的任务
        refreshTask?.cancel()
        preloadTask?.cancel()
        
        guard !isLoading else { return }
        isLoading = true
        currentPage = 1
        
        refreshTask = Task {
            do {
                try await Task.sleep(nanoseconds: 100_000_000)
                
                if let cachedData = contentService.getCachedData(for: 1) {
                    await MainActor.run {
                        topicGroups = [cachedData]
                        hasMoreData = true
                    }
                } else {
                    let firstGroup = await loadGroupData()
                    contentService.cacheData(firstGroup, for: 1)
                    
                    if !Task.isCancelled {
                        await MainActor.run {
                            topicGroups = [firstGroup]
                            hasMoreData = true
                        }
                    }
                }
                
                // 预加载下一页
                if !Task.isCancelled {
                    preloadTask = Task {
                        await preloadNextPage()
                    }
                }
            } catch {
                print("Error refreshing data: \(error)")
            }
            
            if !Task.isCancelled {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func preloadNextPage() async {
        guard !isPreloading && hasMoreData && !isLoading else { return }
        isPreloading = true
        
        do {
            // 检查缓存
            let nextPage = currentPage + 1
            if let cachedData = contentService.getCachedData(for: nextPage) {
                if !Task.isCancelled {
                    await MainActor.run {
                        topicGroups.append(cachedData)
                        currentPage += 1
                        hasMoreData = currentPage < 40
                    }
                }
            } else {
                try await Task.sleep(nanoseconds: 10_000_000)
                let nextGroup = await loadGroupData()
                
                // 存入缓存
                contentService.cacheData(nextGroup, for: nextPage)
                
                if !Task.isCancelled && !nextGroup.isEmpty {
                    await MainActor.run {
                        topicGroups.append(nextGroup)
                        currentPage += 1
                        hasMoreData = currentPage < 40
                    }
                }
            }
        } catch {
            print("Error preloading data: \(error)")
        }
        
        isPreloading = false
    }
    
    // 清理资源
    deinit {
        refreshTask?.cancel()
        preloadTask?.cancel()
        contentService.clearCache()
    }
    
    // 加载更多数据
    func loadMoreData() async {
        guard !isLoading && hasMoreData && !isPreloading else { return }
        isLoading = true
        
        // 如果已经预加载了数据，直接使用预加载的数据
        if topicGroups.count < currentPage + 1 {
            let newGroup = await loadGroupData()
            if !newGroup.isEmpty {
                topicGroups.append(newGroup)
                currentPage += 1
                hasMoreData = currentPage < 40
                
                // 开始预加载下一页
                Task {
                    await preloadNextPage()
                }
            }
        }
        
        isLoading = false
    }
    
    // 模拟加载一组数据
    private func loadGroupData() async -> [TopicItem] {
        // 模拟新的一组数据
        return [
            TopicItem(
                title: "企业财务风险防范：识别和应对关键风险点",
                source: "风控专家",
                time: "1天前",
                collectionCount: 756,
                imageUrl: "https://wx4.sinaimg.cn/mw690/007bMPwCgy1hrmo7lelavj30yi0yin1j.jpg",
                isTOp: false
            ),
            TopicItem(
                title: "财务分析技巧：如何读懂企业经营状况",
                source: "金鹰课程",
                time: "2天前",
                collectionCount: 543,
                imageUrl: "https://bkimg.cdn.bcebos.com/pic/fc1f4134970a304e251f7b207e80b086c9177e3ef69a",
                isTOp: false
            ),
            TopicItem(
                title: "内部控制体系搭建：确保企业规范运营",
                source: "管理视角",
                time: "2天前",
                collectionCount: 432,
                imageUrl: "https://a.53326.com/dydao/d/20200417/1dmwhel2gpf.jpg",
                isTOp: false
            ),
            TopicItem(
                title: "内部控制体系搭建：确保企业规范运营",
                source: "管理视角",
                time: "2天前",
                collectionCount: 345,
                imageUrl: "https://a.53326.com/dydao/d/20200417/1dmwhel2gpf.jpg",
                isTOp: false
            ),
            TopicItem(
                title: "内部控制体系搭建：确保企业规范运营",
                source: "管理视角",
                time: "2天前",
                collectionCount: 5434,
                imageUrl: "https://a.53326.com/dydao/d/20200417/1dmwhel2gpf.jpg",
                isTOp: false
            ),
            TopicItem(
                title: "内部控制体系搭建：确保企业规范运营",
                source: "管理视角",
                time: "2天前",
                collectionCount: 433452,
                imageUrl: "https://a.53326.com/dydao/d/20200417/1dmwhel2gpf.jpg",
                isTOp: false
            )
        ]
    }
} 

// 首先创建一个文章数据模型
struct Article: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    let source: String
    let time: String
    let collectionCount: String
    let imageUrl: String
    let content: String
    // 添加其他需要的属性
    
    static func == (lhs: Article, rhs: Article) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
