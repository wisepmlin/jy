import Foundation

struct TabItem: Identifiable, Equatable, Hashable {
    let uuid: UUID = UUID()
    let id: String
    let title: String
    var showBadge: Bool
    var badgeCount: Int?
    
    static let JYXQTab: [TabItem] = [
        TabItem(id: "home", title: "首页", showBadge: false),
        TabItem(id: "circle", title: "金圈", showBadge: false),
        TabItem(id: "consult", title: "咨询", showBadge: false),
        TabItem(id: "my", title: "我的", showBadge: false)
    ]
    
    static let notificationTopAllTabs: [TabItem] = [
        TabItem(id: "all", title: "全部", showBadge: false),
        TabItem(id: "interaction", title: "互动", showBadge: false),
        TabItem(id: "business", title: "业务", showBadge: false),
        TabItem(id: "system", title: "系统", showBadge: false)
    ]
    
    static let homeTopAllTabs: [TabItem] = [
        TabItem(id: "content", title: "干货", showBadge: false),
        TabItem(id: "column", title: "专栏", showBadge: false),
        TabItem(id: "discover", title: "发现", showBadge: false)
    ]
    
    static let squareAllTabs: [TabItem] = [
        TabItem(id: "square", title: "动态", showBadge: false),
        TabItem(id: "contacts", title: "金脉", showBadge: false),
    ]
    
    static let QAAllTabs: [TabItem] = [
        TabItem(id: "new", title: "最新", showBadge: false),
        TabItem(id: "light", title: "亮答", showBadge: false),
    ]
    
    static let QANewBottomAllTabs: [TabItem] = [
        TabItem(id: "all", title: "全部", showBadge: false),
        TabItem(id: "finance", title: "财务", showBadge: false),
        TabItem(id: "tax", title: "税务", showBadge: false),
        TabItem(id: "control", title: "内控", showBadge: false),
        TabItem(id: "myquestion", title: "我问", showBadge: false),
        TabItem(id: "think", title: "智库", showBadge: false),
    ]
    
    static let squareBottomAllTabs: [TabItem] = [
        TabItem(id: "hot", title: "热门", showBadge: false),
        TabItem(id: "new", title: "最新", showBadge: false),
        TabItem(id: "follow", title: "关注", showBadge: false),
        TabItem(id: "circle", title: "圈子", showBadge: false), 
        TabItem(id: "trade", title: "联盟", showBadge: false),
    ]
    
    static let contactsBottomToabs: [TabItem] = [
        TabItem(id: "recommend", title: "推荐", showBadge: false),
        TabItem(id: "hub", title: "才汇", showBadge: false),
        TabItem(id: "friend", title: "好友", showBadge: false),
        TabItem(id: "follow", title: "关注", showBadge: false),
        TabItem(id: "fans", title: "粉丝", showBadge: false),
    ]
    
    static let allTabs: [TabItem] = [
        TabItem(id: "latest", title: "最新", showBadge: false),
        TabItem(id: "recommended", title: "推荐", showBadge: false),
        TabItem(id: "flash", title: "快讯", showBadge: false),
        TabItem(id: "follow", title: "关注", showBadge: true),
        TabItem(id: "hot", title: "热门", showBadge: false),
        TabItem(id: "industry", title: "行业", showBadge: false),
        TabItem(id: "material", title: "材料", showBadge: false),
        TabItem(id: "tech", title: "科技", showBadge: false),
        TabItem(id: "finance", title: "财经", showBadge: false),
        TabItem(id: "talent", title: "人才", showBadge: false),
        TabItem(id: "informatization", title: "信息化", showBadge: false)
    ]
    
    static let flashNewsAllTabs: [TabItem] = [
        TabItem(id: "all", title: "全部", showBadge: false),
        TabItem(id: "management", title: "企业管理", showBadge: false),
        TabItem(id: "finance", title: "财务管理", showBadge: false),
        TabItem(id: "tax", title: "税务筹划", showBadge: true),
        TabItem(id: "control", title: "内部控制", showBadge: false),
        TabItem(id: "risk", title: "风险管理", showBadge: false)
    ]
    
    static let editType: [TabItem] = [
        TabItem(id: "capital", title: "文章", showBadge: false),
        TabItem(id: "action", title: "动态", showBadge: false),
        TabItem(id: "qa", title: "问答", showBadge: false)
    ]
    
    static let columnAllTabs: [TabItem] = [
        TabItem(id: "internal_control", title: "内控管理", showBadge: false),
        TabItem(id: "cost_management", title: "成本管理", showBadge: false),
        TabItem(id: "tax_management", title: "税务管理", showBadge: false),
        TabItem(id: "financial_informatization", title: "财务信息化", showBadge: true),
        TabItem(id: "financial_sharing", title: "财务共享", showBadge: false),
        TabItem(id: "financial_analysis", title: "财务分析", showBadge: false),
        TabItem(id: "financial_management", title: "财务管理", showBadge: false),
        TabItem(id: "fund_management", title: "资金管理", showBadge: false),
        TabItem(id: "budget_management", title: "预算管理", showBadge: false),
        TabItem(id: "analysis_management", title: "分析管理", showBadge: false),
        TabItem(id: "financial_top", title: "财务顶层", showBadge: false)
    ]
    
    static let aiViewType: [TabItem] = [
        TabItem(id: "history", title: "历史", showBadge: false),
        TabItem(id: "jy", title: "金鹰AI", showBadge: false),
        TabItem(id: "ai", title: "AI订阅", showBadge: false),
        TabItem(id: "tool", title: "工具", showBadge: false)
    ]
    
    static let contactListViewAllTags: [TabItem] = [
        TabItem(id: "hr", title: "HR圈", showBadge: false),
        TabItem(id: "product", title: "产品圈", showBadge: false),
        TabItem(id: "brand", title: "品牌圈", showBadge: false),
        TabItem(id: "strategy", title: "战略圈", showBadge: true),
        TabItem(id: "tech", title: "技术圈", showBadge: false),
        TabItem(id: "investment", title: "投资圈", showBadge: false),
        TabItem(id: "legal", title: "法务圈", showBadge: false),
        TabItem(id: "marketing", title: "营销圈", showBadge: false),
        TabItem(id: "finance", title: "财务圈", showBadge: false),
        TabItem(id: "executive", title: "高管人脉", showBadge: false)
    ]
}
