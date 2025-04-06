import Foundation

// 专栏数据模型
struct Column: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String           // 专栏标题
    let coverImage: String      // 封面图URL
    let articleCount: Int       // 文章数量
    let subscriberCount: Int    // 订阅人数
    let description: String     // 专栏简介
    let category: String        // 专栏分类
    let price: Double          // 专栏价格
    let author: ColumnAuthor          // 作者信息
    let articles: [ColumnArticle]     // 文章列表
    let hot: String
    
    static func == (lhs: Column, rhs: Column) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(coverImage)
        hasher.combine(articleCount)
        hasher.combine(subscriberCount)
        hasher.combine(description)
        hasher.combine(category)
        hasher.combine(price)
        hasher.combine(author)
        hasher.combine(articles)
        hasher.combine(hot)
    }
}

// 作者信息模型
struct ColumnAuthor: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String           // 作者姓名
    let avatar: String         // 头像URL
    let title: String          // 职称/头衔
    let description: String    // 作者简介
    
    static func == (lhs: ColumnAuthor, rhs: ColumnAuthor) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(avatar)
        hasher.combine(title)
        hasher.combine(description)
    }
}

// 文章模型
struct ColumnArticle: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String         // 文章标题
    let publishDate: Date     // 发布日期
    let readCount: Int        // 阅读数
    let likeCount: Int        // 点赞数
    let commentCount: Int     // 评论数
    let isPaid: Bool          // 是否付费文章
    
    static func == (lhs: ColumnArticle, rhs: ColumnArticle) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(publishDate)
        hasher.combine(readCount)
        hasher.combine(likeCount)
        hasher.combine(commentCount)
        hasher.combine(isPaid)
    }
}

// 专栏视图模型
@MainActor
class ColumnViewModel: ObservableObject {
    @Published var columns: [Column] = [
        Column(
            title: "企业财务管理实战指南",
            coverImage: "https://img0.baidu.com/it/u=2777626075,3143999342&fm=253&fmt=auto&app=138&f=JPEG?w=1333&h=500",
            articleCount: 25,
            subscriberCount: 12800,
            description: "深入解析企业财务管理的核心要素，从实战角度剖析财务决策与风险控制",
            category: "财务管理",
            price: 299.0,
            author: ColumnAuthor(
                name: "张明",
                avatar: "https://q8.itc.cn/q_70/images03/20241001/524544d2aa004b8892b4ed45c5f65231.jpeg",
                title: "资深财务顾问",
                description: "前某500强企业财务总监，20年企业财务管理经验"            
            ),
            articles: [
                ColumnArticle(title: "现金流管理的艺术", publishDate: Date(), readCount: 3500, likeCount: 286, commentCount: 45, isPaid: true),
                ColumnArticle(title: "预算控制实战技巧", publishDate: Date().addingTimeInterval(-86400*2), readCount: 2800, likeCount: 195, commentCount: 32, isPaid: false)
            ],
            hot: "234"
        ),
        Column(
            title: "企业税务筹划精讲",
            coverImage: "https://img1.baidu.com/it/u=1596304263,1262721936&fm=253&fmt=auto&app=138&f=JPEG?w=1200&h=470",
            articleCount: 28,
            subscriberCount: 11600,
            description: "系统讲解企业税务筹划方法，助力企业合法节税",
            category: "税务管理",
            price: 399.0,
            author: ColumnAuthor(
                name: "李华",
                avatar: "https://iknow-pic.cdn.bcebos.com/023b5bb5c9ea15cebe696b97a4003af33b87b2ad",
                title: "税务专家",
                description: "注册税务师，为上百家企业提供税务咨询服务"
            ),
            articles: [
                ColumnArticle(title: "企业所得税筹划技巧", publishDate: Date(), readCount: 3100, likeCount: 268, commentCount: 38, isPaid: true),
                ColumnArticle(title: "增值税优化方案", publishDate: Date().addingTimeInterval(-86400*3), readCount: 2800, likeCount: 245, commentCount: 35, isPaid: true)
            ],
            hot: "345"
        ),
        Column(
            title: "内部控制体系建设",
            coverImage: "https://img1.baidu.com/it/u=1425497793,3843829568&fm=253&fmt=auto&app=120&f=JPEG?w=990&h=500",
            articleCount: 32,
            subscriberCount: 9600,
            description: "企业内控体系搭建与优化指南，提升企业管理水平",
            category: "内控管理",
            price: 499.0,
            author: ColumnAuthor(
                name: "王芳",
                avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg",
                title: "内控专家",
                description: "资深内控顾问，参与过多家上市公司内控体系建设"
            ),
            articles: [
                ColumnArticle(title: "内控体系框架设计", publishDate: Date(), readCount: 2200, likeCount: 186, commentCount: 42, isPaid: true),
                ColumnArticle(title: "内控缺陷整改方案", publishDate: Date().addingTimeInterval(-86400*1), readCount: 1800, likeCount: 155, commentCount: 38, isPaid: true)
            ],
            hot: "5745"
        ),
        Column(
            title: "财务报表分析实战",
            coverImage: "https://img2.baidu.com/it/u=1913226150,3200289325&fm=253&fmt=auto&app=138&f=JPEG?w=1280&h=400",
            articleCount: 25,
            subscriberCount: 10400,
            description: "深度解析财务报表，掌握企业经营状况",
            category: "财务分析",
            price: 399.0,
            author: ColumnAuthor(
                name: "刘强",
                avatar: "https://img2.baidu.com/it/u=370507614,3281933238&fm=253&fmt=auto&app=138&f=JPEG?w=1297&h=500",
                title: "财务分析专家",
                description: "资深财务分析师，曾任多家上市公司财务总监"
            ),
            articles: [
                ColumnArticle(title: "资产负债表分析", publishDate: Date(), readCount: 2800, likeCount: 235, commentCount: 45, isPaid: true),
                ColumnArticle(title: "现金流量表解读", publishDate: Date().addingTimeInterval(-86400*2), readCount: 2500, likeCount: 198, commentCount: 39, isPaid: true)
            ],
            hot: "464"
        ),
        Column(
            title: "成本管理与控制",
            coverImage: "https://img1.baidu.com/it/u=2669756351,479704775&fm=253&fmt=auto&app=138&f=JPEG?w=1214&h=406",
            articleCount: 28,
            subscriberCount: 8800,
            description: "企业成本控制与管理优化方案",
            category: "成本管理",
            price: 349.0,
            author: ColumnAuthor(
                name: "陈静",
                avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg",
                title: "成本管理专家",
                description: "制造业成本管理专家，推动过多个成本优化项目"
            ),
            articles: [
                ColumnArticle(title: "成本控制体系建设", publishDate: Date(), readCount: 2400, likeCount: 175, commentCount: 32, isPaid: true),
                ColumnArticle(title: "成本差异分析方法", publishDate: Date().addingTimeInterval(-86400*1), readCount: 2100, likeCount: 155, commentCount: 28, isPaid: false)
            ],
            hot: "454"
        ),
        Column(
            title: "财务信息化建设",
            coverImage: "https://img0.baidu.com/it/u=1757179098,724885791&fm=253&fmt=auto&app=138&f=JPEG?w=1433&h=500",
            articleCount: 24,
            subscriberCount: 7800,
            description: "企业财务信息化解决方案与实施指南",
            category: "财务信息化",
            price: 299.0,
            author: ColumnAuthor(
                name: "赵伟",
                avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg",
                title: "财务信息化专家",
                description: "资深财务信息化顾问，主导过多个大型ERP项目实施"
            ),
            articles: [
                ColumnArticle(title: "财务系统选型指南", publishDate: Date(), readCount: 2100, likeCount: 165, commentCount: 28, isPaid: true),
                ColumnArticle(title: "财务数据治理方案", publishDate: Date().addingTimeInterval(-86400*2), readCount: 1900, likeCount: 145, commentCount: 25, isPaid: false)
            ],
            hot: "345"
        ),
        Column(
            title: "预算管理体系建设",
            coverImage: "https://img0.baidu.com/it/u=96286047,3158966995&fm=253&fmt=auto&app=138&f=JPEG?w=1200&h=500",
            articleCount: 26,
            subscriberCount: 9200,
            description: "全面预算管理体系的构建与实施指南",
            category: "预算管理",
            price: 399.0,
            author: ColumnAuthor(
                name: "孙琳",
                avatar: "https://ww2.sinaimg.cn/mw690/006fLFOwgy1hszbx5ykafj30u00u0tu1.jpg",
                title: "预算管理专家",
                description: "大型企业集团预算管理专家，具有丰富的预算体系建设经验"
            ),
            articles: [
                ColumnArticle(title: "预算编制方法", publishDate: Date(), readCount: 2600, likeCount: 188, commentCount: 35, isPaid: true),
                ColumnArticle(title: "预算执行与控制", publishDate: Date().addingTimeInterval(-86400*1), readCount: 2300, likeCount: 165, commentCount: 30, isPaid: false)
            ],
            hot: "2345"
        ),
        Column(
            title: "财务风险防控",
            coverImage: "https://img1.baidu.com/it/u=1766163049,1167000197&fm=253&fmt=auto&app=138&f=JPEG?w=1423&h=500",
            articleCount: 30,
            subscriberCount: 10500,
            description: "企业财务风险识别与防控体系建设指南",
            category: "风险管理",
            price: 449.0,
            author: ColumnAuthor(
                name: "张伟",
                avatar: "https://q8.itc.cn/q_70/images03/20241001/524544d2aa004b8892b4ed45c5f65231.jpeg",
                title: "财务风控专家",
                description: "资深财务风控顾问，服务过多家大型企业集团"
            ),
            articles: [
                ColumnArticle(title: "财务风险识别方法", publishDate: Date(), readCount: 2800, likeCount: 216, commentCount: 38, isPaid: true),
                ColumnArticle(title: "财务风控体系建设", publishDate: Date().addingTimeInterval(-86400*2), readCount: 2500, likeCount: 185, commentCount: 32, isPaid: true)
            ],
            hot: "4356"
        ),
        Column(
            title: "财务共享服务建设",
            coverImage: "https://img0.baidu.com/it/u=1453275347,3974031794&fm=253&fmt=auto&app=120&f=JPEG?w=1882&h=500",
            articleCount: 28,
            subscriberCount: 8600,
            description: "财务共享服务中心建设与运营管理指南",
            category: "财务共享",
            price: 399.0,
            author: ColumnAuthor(
                name: "李明",
                avatar: "https://iknow-pic.cdn.bcebos.com/023b5bb5c9ea15cebe696b97a4003af33b87b2ad",
                title: "财务共享专家",
                description: "某大型企业集团财务共享中心负责人，具有丰富的实战经验"
            ),
            articles: [
                ColumnArticle(title: "共享中心建设方案", publishDate: Date(), readCount: 2400, likeCount: 175, commentCount: 32, isPaid: true),
                ColumnArticle(title: "共享服务流程优化", publishDate: Date().addingTimeInterval(-86400*1), readCount: 2100, likeCount: 155, commentCount: 28, isPaid: false)
            ],
            hot: "7689"
        ),
        Column(
            title: "资金管理实务",
            coverImage: "https://img2.baidu.com/it/u=1853962398,3429494918&fm=253&fmt=auto&app=138&f=JPEG?w=1548&h=500",
            articleCount: 25,
            subscriberCount: 9800,
            description: "企业资金管理与运营实务指南",
            category: "资金管理",
            price: 399.0,
            author: ColumnAuthor(
                name: "王强",
                avatar: "https://q8.itc.cn/q_70/images03/20241001/524544d2aa004b8892b4ed45c5f65231.jpeg",
                title: "资金管理专家",
                description: "大型企业集团资金管理专家，具有丰富的资金运营经验"
            ),
            articles: [
                ColumnArticle(title: "资金预算与控制", publishDate: Date(), readCount: 2700, likeCount: 198, commentCount: 36, isPaid: true),
                ColumnArticle(title: "资金池建设方案", publishDate: Date().addingTimeInterval(-86400*2), readCount: 2400, likeCount: 175, commentCount: 30, isPaid: false)
            ],
            hot: "4365"
        )
    ]
    @Published var isLoading = false
    @Published var selectedCategory = "全部"
    
    // 获取专栏列表
    func fetchColumns(category: String) async {
        isLoading = true
        // TODO: 实现网络请求获取专栏数据
        isLoading = false
    }
    
    // 刷新数据
    func refreshData() async {
        await fetchColumns(category: selectedCategory)
    }
    
    // 格式化数字
    func formatCount(_ count: Int) -> String {
        if count >= 10000 {
            let wan = Double(count) / 10000.0
            return String(format: "%.1f万", wan)
        } else if count >= 1000 {
            let qian = Double(count) / 1000.0
            return String(format: "%.1fk", qian)
        } else {
            return "\(count)"
        }
    }
}
