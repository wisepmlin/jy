import SwiftUI

struct SquareData {
    static let contacts: [Contact] = [
        Contact(
            avatar: "https://img1.baidu.com/it/u=3671448591,3629744211&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800",
            name: "张明",
            professionalInfo: ProfessionalInfo(
                title: "高级财务总监",
                company: "阿里巴巴集团", 
                industry: "互联网",
                experience: 12,
                education: "清华大学 MBA"
            ),
            location: Location(latitude: 30.2590, longitude: 120.1277, description: "杭州市西湖区"),
            tags: [
                UserTag(name: "财务专家", color: .blue),
                UserTag(name: "互联网", color: .orange)
            ],
            isFollowing: true,
            socialStats: SocialStats(
                messageCount: 35,
                lastInteractionDate: Date().addingTimeInterval(-86400 * 2),
                commonInterests: ["企业财务", "投资理财", "数字化转型"],
                mutualConnections: 12
            ),
            verifiedStatus: true,
            introduction: "15年财务管理经验，专注企业财务战略规划与数字化转型",
            socialMediaLinks: ["linkedin": "zhangming", "weibo": "zhangming_pro"],
            recentMoments: nil,
            commonTopics: ["企业财务管理", "数字化转型", "投资策略"],
            recommendationReason: "您关注的财务管理领域的资深专家",
            contactInfo: ["email": "zhangming@example.com"],
            isKeyContact: true,
            groups: ["财务圈", "高管人脉"],
            notes: "年度财务峰会上认识"
        ),
        
        Contact(
            avatar: "https://img1.baidu.com/it/u=2931798528,1819954566&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800",
            name: "李婷",
            professionalInfo: ProfessionalInfo(
                title: "人力资源总监",
                company: "腾讯",
                industry: "互联网",
                experience: 8,
                education: "北京大学 人力资源管理"
            ),
            location: Location(latitude: 22.5431, longitude: 113.9425, description: "深圳市南山区"),
            tags: [
                UserTag(name: "HR", color: .purple),
                UserTag(name: "招聘", color: .green)
            ],
            isFollowing: false,
            socialStats: SocialStats(
                messageCount: 15,
                lastInteractionDate: Date().addingTimeInterval(-86400 * 5),
                commonInterests: ["人才管理", "企业文化"],
                mutualConnections: 8
            ),
            verifiedStatus: true,
            introduction: "致力于打造优秀的企业文化和人才梯队",
            socialMediaLinks: ["linkedin": "liting_hr"],
            recentMoments: nil,
            commonTopics: ["人才招聘", "企业文化建设"],
            recommendationReason: "人力资源领域的资深专家",
            contactInfo: ["wechat": "liting_hr"],
            isKeyContact: false,
            groups: ["HR圈"],
            notes: "招聘会上认识"
        ),
        
        Contact(
            avatar: "https://img1.baidu.com/it/u=1835355359,370387075&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800",
            name: "王强",
            professionalInfo: ProfessionalInfo(
                title: "投资总监",
                company: "红杉资本",
                industry: "投资",
                experience: 10,
                education: "斯坦福大学 金融学"
            ),
            location: Location(latitude: 39.9042, longitude: 116.4074, description: "北京市朝阳区"),
            tags: [
                UserTag(name: "投资人", color: .red),
                UserTag(name: "创投", color: .blue)
            ],
            isFollowing: true,
            socialStats: SocialStats(
                messageCount: 45,
                lastInteractionDate: Date().addingTimeInterval(-86400),
                commonInterests: ["创投", "科技创新", "企业发展"],
                mutualConnections: 20
            ),
            verifiedStatus: true,
            introduction: "专注早期科技创业项目投资",
            socialMediaLinks: ["linkedin": "wangqiang_vc"],
            recentMoments: nil,
            commonTopics: ["创业投资", "科技创新"],
            recommendationReason: "投资领域的重要决策者",
            contactInfo: ["email": "wangqiang@example.com"],
            isKeyContact: true,
            groups: ["投资圈", "高管人脉"],
            notes: "投资峰会上认识"
        ),
        
        Contact(
            avatar: "https://img2.baidu.com/it/u=1727380429,1939574752&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=500",
            name: "陈静",
            professionalInfo: ProfessionalInfo(
                title: "市场营销总监",
                company: "京东",
                industry: "电商",
                experience: 7,
                education: "复旦大学 市场营销"
            ),
            location: Location(latitude: 39.7270, longitude: 116.3383, description: "北京市大兴区"),
            tags: [
                UserTag(name: "营销", color: .orange),
                UserTag(name: "电商", color: .red)
            ],
            isFollowing: false,
            socialStats: SocialStats(
                messageCount: 8,
                lastInteractionDate: Date().addingTimeInterval(-86400 * 10),
                commonInterests: ["数字营销", "品牌建设"],
                mutualConnections: 5
            ),
            verifiedStatus: false,
            introduction: "数字营销专家，品牌建设实战派",
            socialMediaLinks: ["weibo": "chenjing_mkt"],
            recentMoments: nil,
            commonTopics: ["数字营销", "品牌营销"],
            recommendationReason: "营销领域的新锐力量",
            contactInfo: ["wechat": "chenjing_mkt"],
            isKeyContact: false,
            groups: ["营销圈"],
            notes: nil
        ),
        
        Contact(
            avatar: "https://img0.baidu.com/it/u=1755414607,248132342&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=500",
            name: "刘伟",
            professionalInfo: ProfessionalInfo(
                title: "技术总监",
                company: "字节跳动",
                industry: "互联网",
                experience: 9,
                education: "浙江大学 计算机科学"
            ),
            location: Location(latitude: 39.9288, longitude: 116.3890, description: "北京市海淀区"),
            tags: [
                UserTag(name: "技术", color: .blue),
                UserTag(name: "AI", color: .purple)
            ],
            isFollowing: true,
            socialStats: SocialStats(
                messageCount: 28,
                lastInteractionDate: Date().addingTimeInterval(-86400 * 3),
                commonInterests: ["人工智能", "技术创新"],
                mutualConnections: 15
            ),
            verifiedStatus: true,
            introduction: "专注AI技术研发和团队管理",
            socialMediaLinks: ["github": "liuwei_tech"],
            recentMoments: nil,
            commonTopics: ["人工智能", "技术管理"],
            recommendationReason: "技术领域的领军人物",
            contactInfo: ["email": "liuwei@example.com"],
            isKeyContact: true,
            groups: ["技术圈", "高管人脉"],
            notes: "技术大会上认识"
        ),
        
        Contact(
            avatar: "https://img0.baidu.com/it/u=840194396,748778066&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800",
            name: "赵雪",
            professionalInfo: ProfessionalInfo(
                title: "品牌总监",
                company: "网易",
                industry: "互联网",
                experience: 6,
                education: "中国传媒大学 广告学"
            ),
            location: Location(latitude: 30.2084, longitude: 120.2122, description: "杭州市滨江区"),
            tags: [
                UserTag(name: "品牌", color: .green),
                UserTag(name: "文创", color: .orange)
            ],
            isFollowing: false,
            socialStats: SocialStats(
                messageCount: 12,
                lastInteractionDate: Date().addingTimeInterval(-86400 * 7),
                commonInterests: ["品牌策划", "创意设计"],
                mutualConnections: 6
            ),
            verifiedStatus: true,
            introduction: "致力于打造有温度的品牌",
            socialMediaLinks: ["weibo": "zhaoxue_brand"],
            recentMoments: nil,
            commonTopics: ["品牌建设", "创意营销"],
            recommendationReason: "品牌营销领域的新锐专家",
            contactInfo: ["wechat": "zhaoxue_brand"],
            isKeyContact: false,
            groups: ["品牌圈"],
            notes: nil
        ),
        
        Contact(
            avatar: "https://img2.baidu.com/it/u=3481871954,2077014850&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800",
            name: "孙峰",
            professionalInfo: ProfessionalInfo(
                title: "战略发展总监",
                company: "华为",
                industry: "科技",
                experience: 11,
                education: "上海交通大学 工商管理"
            ),
            location: Location(latitude: 22.7196, longitude: 114.2490, description: "深圳市龙岗区"),
            tags: [
                UserTag(name: "战略", color: .blue),
                UserTag(name: "科技", color: .purple)
            ],
            isFollowing: true,
            socialStats: SocialStats(
                messageCount: 32,
                lastInteractionDate: Date().addingTimeInterval(-86400 * 4),
                commonInterests: ["企业战略", "科技创新"],
                mutualConnections: 18
            ),
            verifiedStatus: true,
            introduction: "专注企业战略规划与创新发展",
            socialMediaLinks: ["linkedin": "sunfeng_strategy"],
            recentMoments: nil,
            commonTopics: ["企业战略", "创新管理"],
            recommendationReason: "战略管理领域的资深专家",
            contactInfo: ["email": "sunfeng@example.com"],
            isKeyContact: true,
            groups: ["战略圈", "高管人脉"],
            notes: "战略论坛上认识"
        ),
        
        Contact(
            avatar: "https://img0.baidu.com/it/u=1586790937,3677863124&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500",
            name: "周莉",
            professionalInfo: ProfessionalInfo(
                title: "法务总监",
                company: "美团",
                industry: "互联网",
                experience: 8,
                education: "中国政法大学 法学"
            ),
            location: Location(latitude: 39.9042, longitude: 116.4074, description: "北京市朝阳区"),
            tags: [
                UserTag(name: "法务", color: .blue),
                UserTag(name: "合规", color: .green)
            ],
            isFollowing: false,
            socialStats: SocialStats(
                messageCount: 5,
                lastInteractionDate: Date().addingTimeInterval(-86400 * 15),
                commonInterests: ["企业法务", "合规管理"],
                mutualConnections: 4
            ),
            verifiedStatus: true,
            introduction: "专注互联网企业法务合规",
            socialMediaLinks: ["linkedin": "zhouli_legal"],
            recentMoments: nil,
            commonTopics: ["法务管理", "企业合规"],
            recommendationReason: "法务领域的专业人士",
            contactInfo: ["email": "zhouli@example.com"],
            isKeyContact: false,
            groups: ["法务圈"],
            notes: nil
        ),
        
        Contact(
            avatar: "https://img0.baidu.com/it/u=1779316273,2294054515&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800",
            name: "吴强",
            professionalInfo: ProfessionalInfo(
                title: "产品总监",
                company: "小米",
                industry: "科技",
                experience: 7,
                education: "武汉大学 软件工程"
            ),
            location: Location(latitude: 39.9288, longitude: 116.3890, description: "北京市海淀区"),
            tags: [
                UserTag(name: "产品", color: .purple),
                UserTag(name: "创新", color: .orange)
            ],
            isFollowing: true,
            socialStats: SocialStats(
                messageCount: 25,
                lastInteractionDate: Date().addingTimeInterval(-86400 * 6),
                commonInterests: ["产品创新", "用户体验"],
                mutualConnections: 10
            ),
            verifiedStatus: true,
            introduction: "专注用户体验与产品创新",
            socialMediaLinks: ["weibo": "wuqiang_product"],
            recentMoments: nil,
            commonTopics: ["用户体验", "产品设计"],
            recommendationReason: "产品领域的新锐力量",
            contactInfo: ["wechat": "wuqiang_product"],
            isKeyContact: true,
            groups: ["产品圈", "高管人脉"],
            notes: "产品论坛上认识"
        )
    ]

     static let moments: [MomentItem] = [
        MomentItem(
            userAvatar: "https://img2.baidu.com/it/u=1203123383,3246665522&fm=253&fmt=auto&app=120&f=JPEG?w=500&h=537",
            userName: "李总监",
            content: "分享一个税收筹划小技巧：企业研发支出可以享受加计扣除政策，建议财务部门做好相关支出的归集和凭证管理，有效降低企业税负。",
            images: ["https://pica.zhimg.com/v2-0ff8cd19ee45f8e9e90ae65b8edee9c0_r.jpg"],
            publishTime: Date(),
            likeCount: 128,
            commentCount: 32,
            isCollected: false,
            collectCount: 45,
            location: nil,
            linkedQA: nil,
            linkedArticle: nil,
            recommendedTools: [],
            recommendedAgents: []
        ),
        MomentItem(
            userAvatar: "https://img1.baidu.com/it/u=2332634356,1775349620&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800",
            userName: "王财务",
            content: "内控体系优化经验：建立健全资金审批制度，实行分级授权管理，明确各级审批权限，有效防范资金风险。附上我们最新修订的资金管理制度供参考。",
            images: [],
            publishTime: Date().addingTimeInterval(-7200),
            likeCount: 189,
            commentCount: 45,
            isCollected: true,
            collectCount: 210,
            location: Location(latitude: 26.0629, longitude: 119.3066, description: "福州市鼓楼区"),
            linkedQA: LinkedQA(title: "如何建立有效的资金管理制度？", answerCount: 12, viewCount: 876),
            linkedArticle: LinkedArticle(title: "企业内控体系建设实务", author: "内控专家", coverImage: "https://picsum.photos/400/201"),
            recommendedTools: [
                RecommendedTool(name: "内控评估工具", icon: "checkmark.shield", description: "内控风险评估")
            ],
            recommendedAgents: []
        ),
        MomentItem(
            userAvatar: "https://img1.baidu.com/it/u=3685978070,3042964551&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=802",
            userName: "张会计",
            content: "发票管理新规解读：电子发票管理系统将全面升级，建议企业及时更新发票管理流程，做好新旧系统衔接。分享几个实操要点...",
            images: ["https://img0.baidu.com/it/u=3232983192,830370159&fm=253&fmt=auto&app=138&f=JPEG?w=1175&h=500"],
            publishTime: Date().addingTimeInterval(-10800),
            likeCount: 156,
            commentCount: 34,
            isCollected: false,
            collectCount: 100,
            location: Location(latitude: 26.0812, longitude: 119.2978, description: "福州市仓山区"),
            linkedQA: LinkedQA(title: "电子发票系统升级注意事项", answerCount: 6, viewCount: 432),
            linkedArticle: LinkedArticle(title: "电子发票管理新规详解", author: "税务专家", coverImage: "https://picsum.photos/400/208"),
            recommendedTools: [
                RecommendedTool(name: "发票管理系统", icon: "doc.text", description: "智能发票管理"),
                RecommendedTool(name: "票据识别工具", icon: "doc.viewfinder", description: "智能票据识别")
            ],
            recommendedAgents: [
                RecommendedAgent(name: "发票顾问", avatar: "ai_invoice_logo", description: "专业发票咨询服务")
            ]
        ),
        MomentItem(
            userAvatar: "https://img2.baidu.com/it/u=334971341,273718017&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500",
            userName: "陈经理",
            content: "成本管理心得：通过预算管理和成本分析，我们发现了几个重要的成本控制点。建议关注原材料采购、生产效率和库存周转三个环节。",
            images: ["https://q4.itc.cn/images01/20240812/cf253156c4f04effb22e50ab46e34e01.jpeg", "https://img0.baidu.com/it/u=3743108943,1857083612&fm=253&fmt=auto&app=138&f=JPEG?w=608&h=338", "https://img1.baidu.com/it/u=2455732849,827913801&fm=253&fmt=auto&app=138&f=JPEG?w=608&h=342"],
            publishTime: Date().addingTimeInterval(-14400),
            likeCount: 267,
            commentCount: 58,
            isCollected: true,
            collectCount: 320,
            location: Location(latitude: 26.0534, longitude: 119.3245, description: "福州市晋安区"),
            linkedQA: LinkedQA(title: "如何优化企业成本结构？", answerCount: 15, viewCount: 923),
            linkedArticle: LinkedArticle(title: "企业成本控制实战指南", author: "成本管理专家", coverImage: "https://picsum.photos/400/202"),
            recommendedTools: [
                RecommendedTool(name: "成本分析工具", icon: "chart.bar", description: "成本结构分析"),
                RecommendedTool(name: "预算管理工具", icon: "chart.pie", description: "预算编制分析")
            ],
            recommendedAgents: [
                RecommendedAgent(name: "成本顾问", avatar: "ai_cost_logo", description: "专业成本管理咨询")
            ]
        ),
        MomentItem(
            userAvatar: "https://img0.baidu.com/it/u=1648866920,4230799925&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=500",
            userName: "赵顾问",
            content: "财务共享服务中心建设经验：系统选型很关键，需要考虑业务流程、数据集成、用户体验等多个维度。分享一份评估模板。",
            images: ["https://img1.baidu.com/it/u=2455732849,827913801&fm=253&fmt=auto&app=138&f=JPEG?w=608&h=342"],
            publishTime: Date().addingTimeInterval(-18000),
            likeCount: 198,
            commentCount: 42,
            isCollected: false,
            collectCount: 150,
            location: Location(latitude: 26.0891, longitude: 119.3127, description: "福州市马尾区"),
            linkedQA: LinkedQA(title: "财务共享中心如何选择系统？", answerCount: 9, viewCount: 645),
            linkedArticle: LinkedArticle(title: "财务共享转型实践", author: "数字化专家", coverImage: "https://picsum.photos/400/203"),
            recommendedTools: [
                RecommendedTool(name: "流程管理工具", icon: "arrow.triangle.branch", description: "业务流程优化"),
                RecommendedTool(name: "数据集成平台", icon: "network", description: "系统数据整合")
            ],
            recommendedAgents: [
                RecommendedAgent(name: "系统顾问", avatar: "ai_system_logo", description: "专业系统选型咨询")
            ]
        ),
        MomentItem(
            userAvatar: "https://img2.baidu.com/it/u=2409512787,3631121385&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800",
            userName: "孙总",
            content: "资金预算管理案例：通过建立滚动预算机制，有效提升了资金使用效率。重点是要做好各业务环节的资金需求预测。",
            images: ["https://img1.baidu.com/it/u=17421489,138727517&fm=253&fmt=auto&app=138&f=JPEG?w=607&h=276", "https://img1.baidu.com/it/u=1642815629,3160142492&fm=253&fmt=auto&app=138&f=PNG?w=442&h=248"],
            publishTime: Date().addingTimeInterval(-21600),
            likeCount: 178,
            commentCount: 39,
            isCollected: true,
            collectCount: 280,
            location: Location(latitude: 26.0723, longitude: 119.3062, description: "福州市台江区"),
            linkedQA: LinkedQA(title: "如何做好资金预算管理？", answerCount: 7, viewCount: 534),
            linkedArticle: LinkedArticle(title: "企业资金预算管理实务", author: "财务专家", coverImage: "https://picsum.photos/400/209"),
            recommendedTools: [
                RecommendedTool(name: "预算管理系统", icon: "calendar", description: "资金预算管理"),
                RecommendedTool(name: "资金流分析工具", icon: "chart.xyaxis.line", description: "现金流分析")
            ],
            recommendedAgents: [
                RecommendedAgent(name: "预算顾问", avatar: "ai_budget_logo", description: "专业预算管理咨询")
            ]
        ),
        MomentItem(
            userAvatar: "https://img2.baidu.com/it/u=1117485034,1068335202&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800",
            userName: "周经理",
            content: "应收账款管理经验：建立客户信用评级体系，设置差异化信用政策，定期进行账龄分析，提高回款效率。",
            images: ["https://bkimg.cdn.bcebos.com/pic/b7fd5266d0160924ab18de36a84b22fae6cd7b899ec0"],
            publishTime: Date().addingTimeInterval(-25200),
            likeCount: 145,
            commentCount: 28,
            isCollected: false,
            collectCount: 120,
            location: Location(latitude: 26.0812, longitude: 119.2978, description: "福州市仓山区"),
            linkedQA: LinkedQA(title: "应收账款管理的关键点", answerCount: 11, viewCount: 789),
            linkedArticle: LinkedArticle(title: "应收账款管理实务", author: "信用管理专家", coverImage: "https://picsum.photos/400/204"),
            recommendedTools: [
                RecommendedTool(name: "应收管理工具", icon: "creditcard", description: "应收账款管理"),
                RecommendedTool(name: "信用评级系统", icon: "star.circle", description: "客户信用评估")
            ],
            recommendedAgents: [
                RecommendedAgent(name: "信用顾问", avatar: "ai_credit_logo", description: "专业信用管理咨询")
            ]
        ),
        MomentItem(
            userAvatar: "https://img1.baidu.com/it/u=2697317139,2059627738&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800",
            userName: "吴专家",
            content: "企业所得税汇算清缴要点：重点关注研发费用加计扣除、资产减值准备、政府补助等事项的处理。附上操作指引。",
            images: ["https://img2.baidu.com/it/u=263278181,3275689888&fm=253&fmt=auto&app=138&f=JPEG?w=608&h=304", "https://img2.baidu.com/it/u=3590174678,1866492003&fm=253&fmt=auto&app=138&f=JPEG?w=500&h=752"],
            publishTime: Date().addingTimeInterval(-28800),
            likeCount: 234,
            commentCount: 52,
            isCollected: true,
            collectCount: 350,
            location: Location(latitude: 26.0745, longitude: 119.2965, description: "福州市台江区"),
            linkedQA: LinkedQA(title: "企业所得税汇算清缴注意事项", answerCount: 14, viewCount: 867),
            linkedArticle: LinkedArticle(title: "所得税汇算清缴指南", author: "税务专家", coverImage: "https://picsum.photos/400/205"),
            recommendedTools: [
                RecommendedTool(name: "税务计算器", icon: "function", description: "税务计算工具"),
                RecommendedTool(name: "税收政策库", icon: "doc.text.magnifyingglass", description: "税收政策查询")
            ],
            recommendedAgents: [
                RecommendedAgent(name: "税务专家", avatar: "ai_tax_expert_logo", description: "专业税务咨询服务")
            ]
        ),
        MomentItem(
            userAvatar: "avatar_placeholder",
            userName: "郑总监",
            content: "分享一个财务管理信息化建设的案例：通过引入智能财务机器人，实现了票据识别、凭证制作、数据录入等环节的自动化，大幅提升了工作效率。",
            images: ["https://img2.baidu.com/it/u=1564834813,4016933390&fm=253&fmt=auto&app=138&f=JPEG?w=607&h=296"],
            publishTime: Date().addingTimeInterval(-32400),
            likeCount: 289,
            commentCount: 63,
            isCollected: false,
            collectCount: 100,
            location: Location(latitude: 26.0629, longitude: 119.3066, description: "福州市鼓楼区"),
            linkedQA: LinkedQA(title: "财务机器人如何选型？", answerCount: 10, viewCount: 756),
            linkedArticle: LinkedArticle(title: "财务数字化转型实践", author: "信息化专家", coverImage: "https://picsum.photos/400/206"),
            recommendedTools: [
                RecommendedTool(name: "智能财务机器人", icon: "cpu", description: "自动化财务处理"),
                RecommendedTool(name: "数据分析平台", icon: "chart.bar.xaxis", description: "智能数据分析")
            ],
            recommendedAgents: [
                RecommendedAgent(name: "AI顾问", avatar: "ai_robot_logo", description: "智能化解决方案专家")
            ]
        ),
        MomentItem(
            userAvatar: "https://img0.baidu.com/it/u=3375861103,286432284&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800",
            userName: "刘顾问",
            content: "内部审计经验分享：建立数据分析模型，通过异常交易筛查、舞弊风险预警等手段，提升审计效率和质量。附上审计程序模板。",
            images: ["https://img2.baidu.com/it/u=1885303705,4202849037&fm=253&fmt=auto&app=138&f=JPEG?w=608&h=322", "https://img1.baidu.com/it/u=569511267,4030824491&fm=253&fmt=auto&app=138&f=JPEG?w=606&h=342"],
            publishTime: Date().addingTimeInterval(-36000),
            likeCount: 167,
            commentCount: 38,
            isCollected: true,
            collectCount: 250,
            location: Location(latitude: 26.0891, longitude: 119.3127, description: "福州市马尾区"),
            linkedQA: LinkedQA(title: "如何提升内审效率？", answerCount: 13, viewCount: 678),
            linkedArticle: LinkedArticle(title: "内部审计创新方法", author: "审计专家", coverImage: "https://picsum.photos/400/207"),
            recommendedTools: [
                RecommendedTool(name: "审计分析工具", icon: "magnifyingglass", description: "审计数据分析"),
                RecommendedTool(name: "风险评估工具", icon: "exclamationmark.triangle", description: "风险预警分析")
            ],
            recommendedAgents: [
                RecommendedAgent(name: "审计顾问", avatar: "ai_audit_logo", description: "专业审计咨询服务")
            ]
        )
    ]
}
