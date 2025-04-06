import Foundation

struct QAItem: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String           // 问题标题
    let content: String         // 回答内容
    let user: QAUser           // 回答者信息
    let readCount: Int         // 阅读数
    let createdAt: Date        // 创建时间
    let tags: [String]         // 问题标签
    let likeCount: Int         // 点赞数
    let commentCount: Int      // 评论数
}

struct QAUser: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String           // 用户名
    let avatar: String         // 头像URL
    let title: String          // 职位
    let company: String        // 公司
    let isVerified: Bool       // 是否认证
    let level: Int            // 用户等级
}

// 模拟数据
struct MockQAData {
    static let qaItems: [QAItem] = [
        QAItem(
            title: "如何制定和优化企业税务筹划方案以实现合法节税？",
            content: "税务筹划需要考虑企业实际情况，主要从以下几个方面着手：1. 合理运用税收优惠政策；2. 优化业务结构；3. 规范财务管理制度。具体实施时需要注意合法合规。",
            user: QAUser(name: "张三", avatar: "https://img0.baidu.com/it/u=2922784866,1995204354&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800", title: "税务总监", company: "", isVerified: true, level: 3),
            readCount: 12500,
            createdAt: Date(),
            tags: ["税务筹划", "企业管理"],
            likeCount: 238,
            commentCount: 45
        ),
        QAItem(
            title: "企业并购重组中如何开展全面的财务尽职调查工作？",
            content: "财务尽职调查是并购重组的关键环节，主要包括：1. 财务报表真实性核查；2. 资产负债状况评估；3. 现金流和盈利能力分析；4. 税务合规性检查；5. 或有负债识别。建议聘请专业机构协助开展。",
            user: QAUser(name: "赵六", avatar: "https://img1.baidu.com/it/u=1097906340,2119324872&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800", title: "首席财务官", company: "", isVerified: true, level: 5),
            readCount: 18900,
            createdAt: Date().addingTimeInterval(-259200),
            tags: ["并购重组", "尽职调查", "企业管理"],
            likeCount: 425,
            commentCount: 89
        ),
        QAItem(
            title: "企业IPO上市前需要重点关注哪些财务规范化工作？",
            content: "IPO前财务规范化重点包括：1. 会计政策统一性；2. 关联交易合规性；3. 财务报表质量；4. 内控体系完善；5. 税务合规性；6. 资产权属清晰。需要提前2-3年开展规范化工作。",
            user: QAUser(name: "李十", avatar: "https://img0.baidu.com/it/u=3582999362,3809132610&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800", title: "上市办主任", company: "", isVerified: true, level: 5),
            readCount: 32100,
            createdAt: Date().addingTimeInterval(-604800),
            tags: ["IPO", "财务规范"],
            likeCount: 567,
            commentCount: 121
        ),
        QAItem(
            title: "如何构建科学有效的集团企业投融资决策框架体系？",
            content: "科学的投融资决策框架应包含：1. 战略匹配度评估；2. 财务可行性分析；3. 风险评估体系；4. 投后管理机制；5. 退出机制设计。决策过程要做到科学规范。",
            user: QAUser(name: "王十一", avatar: "https://img2.baidu.com/it/u=509687025,3322990829&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800", title: "投资总监", company: "", isVerified: true, level: 5),
            readCount: 28900,
            createdAt: Date().addingTimeInterval(-691200),
            tags: ["投资决策", "企业管理"],
            likeCount: 478,
            commentCount: 95
        ),
        QAItem(
            title: "企业数字化转型中如何推进财务管理变革与创新？",
            content: "财务数字化转型要点：1. 财务流程重构；2. 数据治理体系；3. 智能化工具应用；4. 人才能力提升；5. 财务共享建设。要充分利用新技术提升财务管理效率。",
            user: QAUser(name: "钱十二", avatar: "https://img0.baidu.com/it/u=4137345866,3691667538&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800", title: "数字化总监", company: "", isVerified: true, level: 4),
            readCount: 24600,
            createdAt: Date().addingTimeInterval(-777600),
            tags: ["数字化转型", "财务管理"],
            likeCount: 412,
            commentCount: 87
        ),
        QAItem(
            title: "如何实现企业战略规划与预算管理的有效协同与落地？",
            content: "战略预算协同管理关键点：1. 战略目标分解；2. 预算编制标准；3. 资源优化配置；4. 考核激励机制；5. 动态调整机制。确保预算管理服务于战略实现。",
            user: QAUser(name: "周十三", avatar: "https://img0.baidu.com/it/u=1008951549,1654888911&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800", title: "战略规划总监", company: "", isVerified: true, level: 5),
            readCount: 19800,
            createdAt: Date().addingTimeInterval(-864000),
            tags: ["战略规划", "预算管理"],
            likeCount: 345,
            commentCount: 76
        ),
        QAItem(
            title: "大型企业集团如何建立高效的资金集中管理体系？",
            content: "资金集中管理的核心要素：1. 资金池搭建；2. 授信额度管理；3. 内部结算中心；4. 资金计划管理；5. 融资统筹安排。要平衡效率与风险。",
            user: QAUser(name: "孙十四", avatar: "https://img0.baidu.com/it/u=799978431,3054606412&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800", title: "资金管理总监", company: "", isVerified: true, level: 4),
            readCount: 22300,
            createdAt: Date().addingTimeInterval(-950400),
            tags: ["资金管理", "集团管控"],
            likeCount: 389,
            commentCount: 82
        ),
        QAItem(
            title: "如何构建和完善现代企业内部控制体系？",
            content: "建立有效的内控体系需要：1. 控制环境优化；2. 风险评估机制；3. 控制活动设计；4. 信息沟通体系；5. 监督评价机制。应当从实际出发循序渐进。",
            user: QAUser(name: "吴十五", avatar: "https://img1.baidu.com/it/u=929858767,418010585&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800", title: "内控总监", company: "", isVerified: true, level: 4),
            readCount: 20100,
            createdAt: Date().addingTimeInterval(-1036800),
            tags: ["内部控制", "风险管理"],
            likeCount: 356,
            commentCount: 78
        ),
        QAItem(
            title: "企业如何推进成本管理精细化和降本增效工作？",
            content: "成本精细化管理要点：1. 全流程成本管控；2. 标准成本体系；3. 成本动因分析；4. 考核指标设计；5. 持续改进机制。需要建立长效机制。",
            user: QAUser(name: "郑十六", avatar: "https://img2.baidu.com/it/u=809889461,350389927&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500", title: "运营总监", company: "", isVerified: true, level: 4),
            readCount: 25400,
            createdAt: Date().addingTimeInterval(-1123200),
            tags: ["成本管理", "精细化运营"],
            likeCount: 423,
            commentCount: 91
        ),
        QAItem(
            title: "如何设计科学合理的企业绩效考核与激励体系？",
            content: "科学的绩效考核体系包含：1. 指标体系设计；2. 考核方式确定；3. 结果应用机制；4. 申诉处理流程；5. 持续改进机制。要注重公平性和激励性。",
            user: QAUser(name: "陈十七", avatar: "https://img2.baidu.com/it/u=2264207564,2939741236&fm=253&fmt=auto&app=120&f=JPEG?w=506&h=500", title: "人力资源总监", company: "", isVerified: true, level: 5),
            readCount: 27800,
            createdAt: Date().addingTimeInterval(-1209600),
            tags: ["绩效考核", "人力资源"],
            likeCount: 467,
            commentCount: 98
        )
    ]
}
