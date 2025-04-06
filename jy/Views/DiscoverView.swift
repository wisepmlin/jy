import SwiftUI

struct DiscoverItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct DiscoverNavigationView: View {
    @Environment(\.theme) private var theme
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 高管必备工具
                DiscoverSectionView(title: "高管必备工具", items: [
                    DiscoverItem(icon: "chart.pie.fill", title: "经营分析", description: "实时经营数据、业绩追踪、预警"),
                    DiscoverItem(icon: "person.2.circle.fill", title: "团队管理", description: "OKR制定、绩效考核、人才盘点"),
                    DiscoverItem(icon: "doc.text.magnifyingglass", title: "决策助手", description: "竞品分析、市场洞察、风险评估")
                ])
                
                // 每日必用工具
                DiscoverSectionView(title: "每日必用工具", items: [
                    DiscoverItem(icon: "function", title: "财务计算", description: "财务计算、汇率转换、税费计算等"),
                    DiscoverItem(icon: "calendar", title: "日程管理", description: "会议安排、任务提醒、时间规划"),
                    DiscoverItem(icon: "cloud.sun.fill", title: "天气预报", description: "出行、会议安排等场景必备")
                ])
                
                // 行业动态与趋势
                DiscoverSectionView(title: "行业动态与趋势", items: [
                    DiscoverItem(icon: "newspaper.fill", title: "实时资讯", description: "行业新闻、政策变化、市场动态"),
                    DiscoverItem(icon: "chart.line.uptrend.xyaxis", title: "趋势分析", description: "行业报告、数据解读")
                ])
                
                // 社交与 Networking
                DiscoverSectionView(title: "社交与 Networking", items: [
                    DiscoverItem(icon: "location.fill", title: "找附近同伴", description: "基于地理位置寻找同行"),
                    DiscoverItem(icon: "person.3.fill", title: "行业圈子", description: "加入或创建行业讨论组"),
                    DiscoverItem(icon: "person.2.circle.fill", title: "人脉推荐", description: "推荐潜在合作伙伴或导师")
                ])
                
                // 学习与提升
                DiscoverSectionView(title: "学习与提升", items: [
                    DiscoverItem(icon: "book.fill", title: "在线课程", description: "管理、金融、技术等领域课程"),
                    DiscoverItem(icon: "books.vertical.fill", title: "读书推荐", description: "商业、管理、心理学等书籍"),
                    DiscoverItem(icon: "chart.bar.fill", title: "技能测评", description: "职业能力测试")
                ])
                
                // 投资与理财
                DiscoverSectionView(title: "投资与理财", items: [
                    DiscoverItem(icon: "dollarsign.circle.fill", title: "投资建议", description: "股票、基金、房地产等投资"),
                    DiscoverItem(icon: "creditcard.fill", title: "理财规划", description: "制定长期财务计划"),
                    DiscoverItem(icon: "doc.text.fill", title: "税务优化", description: "税务咨询和优化建议")
                ])
            }
            .padding(8)
            .padding(.bottom, 64)
        }
        .refreshable {

        }
    }
}

struct DiscoverSectionView: View {
    @Environment(\.theme) private var theme
    let title: String
    let items: [DiscoverItem]
    let columns: Int
    var onItemTap: ((DiscoverItem) -> Void)?
    
    init(title: String, 
         items: [DiscoverItem], 
         columns: Int = 3,
         onItemTap: ((DiscoverItem) -> Void)? = nil) {
        self.title = title
        self.items = items
        self.columns = columns
        self.onItemTap = onItemTap
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .themeFont(theme.fonts.title3.bold())
                .foregroundColor(theme.primaryText)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: columns), spacing: 12) {
                ForEach(items) { item in
                    Button(action: {
                        onItemTap?(item)
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: item.icon)
                                .font(.system(size: 24))
                                .foregroundColor(theme.jyxqPrimary)
                                .frame(width: 48, height: 48)
                                .background(theme.jyxqPrimary.opacity(0.1))
                                .cornerRadius(12)
                            
                            Text(item.title)
                                .themeFont(theme.fonts.subBody.weight(.medium))
                                .foregroundColor(theme.primaryText)
                            
                            Text(item.description)
                                .themeFont(theme.fonts.caption)
                                .foregroundColor(theme.subText2)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(theme.background)
                        .cornerRadius(theme.defaultCornerRadius)
                    }
                }
            }
        }
    }
}

struct DiscoverView: View {
    @Environment(\.theme) private var theme
    
    let toolItems: [DiscoverItem] = [
        DiscoverItem(icon: "wrench.and.screwdriver", title: "工具箱", description: "常用工具集合"),
        DiscoverItem(icon: "chart.bar.fill", title: "数据分析", description: "数据可视化分析"),
        DiscoverItem(icon: "doc.text.fill", title: "文档处理", description: "智能文档处理")
    ]
    
    let newsItems: [DiscoverItem] = [
        DiscoverItem(icon: "newspaper.fill", title: "行业资讯", description: "最新行业动态"),
        DiscoverItem(icon: "chart.line.uptrend.xyaxis", title: "市场趋势", description: "市场分析报告"),
        DiscoverItem(icon: "building.2.fill", title: "企业动态", description: "企业新闻资讯")
    ]
    
    let socialItems: [DiscoverItem] = [
        DiscoverItem(icon: "person.2.fill", title: "社区交流", description: "专业交流平台"),
        DiscoverItem(icon: "bubble.left.and.bubble.right.fill", title: "在线咨询", description: "专家在线解答"),
        DiscoverItem(icon: "person.3.fill", title: "团队协作", description: "高效团队协作")
    ]
    
    let learningItems: [DiscoverItem] = [
        DiscoverItem(icon: "book.fill", title: "在线课程", description: "专业技能提升"),
        DiscoverItem(icon: "graduationcap.fill", title: "职业培训", description: "职业发展规划"),
        DiscoverItem(icon: "person.fill.checkmark", title: "认证考试", description: "专业资格认证")
    ]
    
    let financeItems: [DiscoverItem] = [
        DiscoverItem(icon: "dollarsign.circle.fill", title: "财务管理", description: "智能财务分析"),
        DiscoverItem(icon: "chart.pie.fill", title: "投资理财", description: "理财产品推荐"),
        DiscoverItem(icon: "creditcard.fill", title: "支付服务", description: "便捷支付方案")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                DiscoverSectionView(title: "常用工具", items: toolItems, columns: 3)
                DiscoverSectionView(title: "资讯中心", items: newsItems, columns: 3)
                DiscoverSectionView(title: "社交平台", items: socialItems, columns: 3)
                DiscoverSectionView(title: "学习成长", items: learningItems, columns: 3)
                DiscoverSectionView(title: "财务金融", items: financeItems, columns: 3)
            }
            .padding(16)
        }
        .background(theme.gray6Background)
        .refreshable {
            // 添加下拉刷新逻辑
        }
    }
}
