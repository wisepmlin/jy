import SwiftUI
import Combine

class FlashNewsViewModel: ObservableObject {
    @Published var flashNews: [FlashNewsItem] = []
    @Published var selectedCategory: TabItem?
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $selectedCategory
            .removeDuplicates()
            .debounce(for: .milliseconds(50), scheduler: DispatchQueue.main)
            .sink { [weak self] category in
                Task {
                    if let category {
                        await self?.fetchNews(category: category)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchNews(category: TabItem) async {
        await MainActor.run {
            isLoading = true
            
            switch category.id {
            case "all":
                self.flashNews = Self.mockData
            case "management":
                self.flashNews = Self.mockData.filter { $0.tag == "管理" }
            case "finance":
                self.flashNews = Self.mockData.filter { $0.tag == "财务" }
            case "tax":
                self.flashNews = Self.mockData.filter { $0.tag == "税务" }
            case "control":
                self.flashNews = Self.mockData.filter { $0.tag == "内控" }
            case "risk":
                self.flashNews = Self.mockData.filter { $0.tag == "风险" }
            default:
                self.flashNews = []
            }
            
            self.isLoading = false
        }
    }
    
    func refreshNews() async {
        if let selectedCategory {
            await fetchNews(category: selectedCategory)
        }
    }
    
    // 模拟数据
    static let mockData = [FlashNewsItem(id: 1, title: "企业管理体系优化方案", time: "09:30", tag: "管理", content: "针对现代企业管理体系进行全面优化，包括组织架构重组、管理流程再造、绩效考核体系完善等多个方面的具体实施方案。", isMe: true),
        FlashNewsItem(
            id: 2,
            title: "财务管理数字化转型",
            time: "10:15", 
            tag: "财务",
            content: "探讨企业财务管理数字化转型策略，运用大数据、人工智能等技术提升财务管理效率和决策能力。",
            isMe: false
        ),
        FlashNewsItem(
            id: 3,
            title: "企业税务筹划新策略",
            time: "11:00",
            tag: "税务",
            content: "结合最新税收政策，制定合理的企业税务筹划方案，优化税负结构，提高企业税收管理水平。",
            isMe: true
        ),
        FlashNewsItem(
            id: 4,
            title: "内部控制体系建设指南",
            time: "14:30",
            tag: "内控",
            content: "详细解读企业内部控制体系建设要点，包括风险识别、控制活动设计、监督评价等关键环节。",
            isMe: false
        ),
        FlashNewsItem(
            id: 5,
            title: "企业风险管理创新",
            time: "15:45",
            tag: "风险",
            content: "探讨企业全面风险管理创新方法，建立健全风险预警机制，提升企业风险防控能力。",
            isMe: true
        ),
        FlashNewsItem(
            id: 6,
            title: "人力资源管理优化",
            time: "16:00",
            tag: "管理",
            content: "探讨现代企业人力资源管理创新方法，包括人才招聘、培训发展、绩效管理等方面的优化策略。",
            isMe: false
        ),
        FlashNewsItem(
            id: 7,
            title: "财务报表分析技巧",
            time: "16:30",
            tag: "财务",
            content: "深入解析财务报表分析方法，提供实用的财务指标分析技巧，助力企业经营决策。",
            isMe: true
        ),
        FlashNewsItem(
            id: 8,
            title: "增值税筹划方案",
            time: "17:00",
            tag: "税务",
            content: "针对企业增值税管理难点，提供合理的税务筹划方案，优化企业税负结构。",
            isMe: false
        ),
        FlashNewsItem(
            id: 9,
            title: "内控制度完善建议",
            time: "17:30",
            tag: "内控",
            content: "基于企业实际运营情况，提出内部控制制度完善建议，强化企业管理效能。",
            isMe: true
        ),
        FlashNewsItem(
            id: 10,
            title: "市场风险防范策略",
            time: "08:30",
            tag: "风险",
            content: "分析市场风险成因，提供有效的风险防范措施，提升企业抗风险能力。",
            isMe: false
        ),
        FlashNewsItem(
            id: 11,
            title: "项目管理效能提升",
            time: "09:00",
            tag: "管理",
            content: "探讨项目管理优化方法，提高项目执行效率，确保项目目标实现。",
            isMe: true
        ),
        FlashNewsItem(
            id: 12,
            title: "成本控制新方法",
            time: "09:45",
            tag: "财务",
            content: "介绍企业成本控制创新方法，优化成本结构，提升企业盈利能力。",
            isMe: false
        ),
        FlashNewsItem(
            id: 13,
            title: "企业战略规划制定",
            time: "10:30",
            tag: "管理",
            content: "探讨企业战略规划的制定方法，包括环境分析、目标设定、战略选择等关键步骤。",
            isMe: true
        ),
        FlashNewsItem(
            id: 14,
            title: "预算管理体系优化",
            time: "11:15",
            tag: "财务",
            content: "分析企业预算管理体系优化方案，提高预算编制科学性和执行效率。",
            isMe: false
        ),
        FlashNewsItem(
            id: 15,
            title: "风险投资评估方法",
            time: "13:45",
            tag: "风险",
            content: "介绍风险投资项目评估方法，建立科学的风险评估体系，提高投资决策准确性。",
            isMe: true
        ),
        FlashNewsItem(
            id: 16,
            title: "供应链优化新思路",
            time: "14:30",
            tag: "管理",
            content: "探讨供应链优化新思路，提升供应链管理效率，降低成本。",
            isMe: false
        ),
        FlashNewsItem(
            id: 17,
            title: "企业人力资源管理策略",
            time: "15:00",
            tag: "管理",
            content: "分析企业人力资源管理策略，优化员工招聘、培训、激励等方面的管理流程。",
            isMe: true
        ),
        FlashNewsItem(
            id: 18,
            title: "财务报表解读方法",
            time: "15:45",
            tag: "财务",
            content: "深入解析财务报表解读方法，提供财务指标解读技巧，助力企业财务分析。",
            isMe: false
        ),
        FlashNewsItem(
            id: 19,
            title: "企业税务筹划新策略",
            time: "16:30",
            tag: "税务",
            content: "探讨企业税务筹划新策略，优化税负结构，提高企业税务管理水平。",
            isMe: true
        ),
        FlashNewsItem(
            id: 20,
            title: "内控制度提升建议",
            time: "17:00",
            tag: "内控",
            content: "基于企业实际运营情况，提出内控制度提升建议，强化企业管理效能。",
            isMe: false
        ),
        FlashNewsItem(
            id: 21,
            title: "市场风险防范策略",
            time: "17:30",
            tag: "风险",
            content: "分析市场风险成因，提供有效的风险防范措施，提升企业抗风险能力。",
            isMe: true
        ),
        FlashNewsItem(
            id: 22,
            title: "项目管理效能提升",
            time: "18:00",
            tag: "管理",
            content: "探讨项目管理优化方法，提高项目执行效率，确保项目目标实现。",
            isMe: false
        ),
        FlashNewsItem(
            id: 23,
            title: "成本控制新方法",
            time: "18:45",
            tag: "财务",
            content: "介绍企业成本控制创新方法，优化成本结构，提升企业盈利能力。",
            isMe: true
        ),
        FlashNewsItem(
            id: 24,
            title: "企业战略规划制定",
            time: "19:30",
            tag: "管理",
            content: "探讨企业战略规划的制定方法，包括环境分析、目标设定、战略选择等关键步骤。",
            isMe: false
        ),
        FlashNewsItem(
            id: 25,
            title: "预算管理体系优化",
            time: "20:15",
            tag: "财务",
            content: "分析企业预算管理体系优化方案，提高预算编制科学性和执行效率。",
            isMe: true
        ),
        FlashNewsItem(
            id: 26,
            title: "风险投资评估方法",
            time: "21:00",
            tag: "风险",
            content: "介绍风险投资项目评估方法，建立科学的风险评估体系，提高投资决策准确性。",
            isMe: false
        ),
        FlashNewsItem(
            id: 27,
            title: "供应链优化新思路",
            time: "21:30",
            tag: "管理",
            content: "探讨供应链优化新思路，提升供应链管理效率，降低成本。",
            isMe: true
        ),
        FlashNewsItem(
            id: 28,
            title: "企业人力资源管理策略",
            time: "22:00",
            tag: "管理",
            content: "分析企业人力资源管理策略，优化员工招聘、培训、激励等方面的管理流程。",
            isMe: false
        ),
        FlashNewsItem(
            id: 29,
            title: "财务报表解读方法",
            time: "22:45",
            tag: "财务",
            content: "深入解析财务报表解读方法，提供财务指标解读技巧，助力企业财务分析。",
            isMe: true
        ),
        FlashNewsItem(
            id: 30,
            title: "企业税务筹划新策略",
            time: "23:30",
            tag: "税务",
            content: "探讨企业税务筹划新策略，优化税负结构，提高企业税务管理水平。",
            isMe: false
        )
    ]
}
