//
//  VIPFuncitonView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/18.
//
import SwiftUI
import SwiftUIX

struct VIPFunction: Identifiable, Equatable, Hashable {
    let id = UUID()
    let title: String
    var icon: String
    let descriptions: [String]
    let instructions: [String]
    let isPremium: Bool
    
    static func == (lhs: VIPFunction, rhs: VIPFunction) -> Bool {
        // 实现比较逻辑，例如：
        return lhs.id == rhs.id
    }
}

struct VIPFunctionItemView: View {
    let item: VIPFunction
    @Environment(\.theme) private var theme
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: item.icon)
                        .themeFont(theme.fonts.small)
                        .foregroundColor(theme.primaryText)
                        .frame(width: 28, height: 28)
                        .background(theme.jyxqPrimary)
                        .cornerRadius(theme.minCornerRadius)
                    Text(item.title)
                        .themeFont(theme.fonts.title2)
                        .foregroundColor(theme.primaryText)
                    Spacer()
                    Text("了解更多")
                        .themeFont(theme.fonts.small)
                        .foregroundColor(theme.subText)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(theme.gray6Background)
                        .cornerRadius(theme.minCornerRadius)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(item.descriptions, id: \.self) { description in
                        Text(description)
                            .themeFont(theme.fonts.small)
                            .foregroundColor(theme.primaryText)
                    }
                }
                Spacer()
                HStack(spacing: 4) {
                    ForEach(item.instructions, id: \.self) { instruction in
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .themeFont(theme.fonts.caption)
                                .foregroundColor(theme.subText)
                            Text(instruction)
                                .themeFont(theme.fonts.caption)
                                .foregroundColor(theme.subText)
                        }
                    }
                    Spacer()
                    if item.isPremium {
                        VIPBadgeView()
                    }
                }
            }
        }
        .padding(16)
        .contentShape(Rectangle())
        .background(theme.background.cornerRadius(theme.defaultCornerRadius))
        .standardListRowStyle()
        .buttonStyle(.plain)
    }
}

struct VIPFuncitonView: View {
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    let functions: [VIPFunction] = [
        VIPFunction(
            title: "企业智能顾问",
            icon: "brain.head.profile",
            descriptions: ["智能分析企业经营状况", "提供战略决策建议", "定制化解决方案"],
            instructions: ["输入企业信息", "选择咨询领域", "获取专业建议"],
            isPremium: true
        ),
        VIPFunction(
            title: "行业资讯速递",
            icon: "newspaper.fill",
            descriptions: ["实时推送行业动态", "深度市场分析报告", "竞争对手动态追踪"],
            instructions: ["设置关注领域", "查看最新资讯", "下载完整报告"],
            isPremium: true
        ),
        VIPFunction(
            title: "企业管理工具箱",
            icon: "briefcase.fill",
            descriptions: ["全面的企业管理工具集", "员工绩效考核系统", "财务分析与预测"],
            instructions: ["选择管理工具", "配置企业参数", "开始使用"],
            isPremium: true
        ),
        VIPFunction(
            title: "团队协作平台",
            icon: "person.3.fill",
            descriptions: ["跨部门项目管理", "实时沟通与协作", "任务进度追踪"],
            instructions: ["创建团队", "分配任务", "监控进度"],
            isPremium: true
        ),
        VIPFunction(
            title: "数据分析中心",
            icon: "chart.pie.fill",
            descriptions: ["企业经营数据分析", "市场趋势预测", "竞争力评估报告"],
            instructions: ["导入数据", "选择分析模型", "生成报告"],
            isPremium: true
        ),
        VIPFunction(
            title: "人才发展系统",
            icon: "person.text.rectangle",
            descriptions: ["员工培训课程库", "职业发展规划", "技能评估体系"],
            instructions: ["设置培训计划", "分配学习任务", "追踪学习进度"],
            isPremium: true
        ),
        VIPFunction(
            title: "企业风险预警",
            icon: "exclamationmark.shield.fill",
            descriptions: ["实时风险监测", "合规性审查", "预警信息推送"],
            instructions: ["配置监测项目", "查看风险报告", "采取应对措施"],
            isPremium: true
        ),
        VIPFunction(
            title: "智能文档中心",
            icon: "doc.text.magnifyingglass",
            descriptions: ["智能合同生成", "文档审批流程", "归档管理系统"],
            instructions: ["选择文档类型", "填写关键信息", "自动生成文档"],
            isPremium: true
        ),
        VIPFunction(
            title: "客户关系管理",
            icon: "person.3.fill",
            descriptions: ["客户信息管理", "销售机会预测", "客户互动记录"],
            instructions: ["添加客户", "设置销售目标", "记录互动信息"],
            isPremium: true
        ),
        VIPFunction(
            title: "项目管理工具",
            icon: "list.dash",
            descriptions: ["项目计划制定", "任务分配与跟踪", "项目进度报告"],
            instructions: ["创建新项目", "分配任务", "查看项目进度"],
            isPremium: true
        ),
        VIPFunction(
            title: "财务管理工具",
            icon: "dollarsign.circle.fill",
            descriptions: ["财务报表生成", "预算管理与控制", "资金调拨流程"],
            instructions: ["设置财务参数", "生成报表", "进行资金调拨"],
            isPremium: true
        ),
        VIPFunction(
            title: "人力资源管理",
            icon: "person.2.fill",
            descriptions: ["员工信息管理", "招聘与培训管理", "员工绩效评估"],
            instructions: ["添加员工", "设置招聘计划", "评估员工绩效"],
            isPremium: true
        ),
        VIPFunction(
            title: "市场分析工具",
            icon: "chart.bar.fill",
            descriptions: ["市场趋势分析", "竞争对手分析", "市场定位报告"],
            instructions: ["选择分析指标", "生成报告", "市场定位策略"],
            isPremium: true
        ),
        VIPFunction(
            title: "数据可视化",
            icon: "chart.bar.fill",
            descriptions: ["直观展示企业数据", "交互式图表与报告", "数据洞察"],
            instructions: ["选择数据类型", "生成可视化图表", "获取数据洞察"],
            isPremium: true
        ),
        VIPFunction(
            title: "智能客服系统",
            icon: "headphones",
            descriptions: ["24小时在线客服", "智能问题解答", "客户反馈收集"],
            instructions: ["与客服互动", "上传反馈信息", "获取解答"],
            isPremium: true
        ),
        VIPFunction(
            title: "智能问答系统",
            icon: "questionmark.circle.fill",
            descriptions: ["智能回答用户问题", "知识库管理", "自定义问题解答"],
            instructions: ["提问", "获取智能回答", "自定义问题解答"],
            isPremium: true
        )
    ]
    
    var body: some View {
        List(functions) { item in
            VIPFunctionItemView(item: item)
        }
        .JYXQListStyle()
        .background(theme.gray6Background)
        .navigationTitle("高级功能")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("取消") {
                    dismiss()
                }
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.primaryText)
            }
        }
    }
}

