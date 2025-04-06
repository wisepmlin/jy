//
//  ToolsView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/12.
//
import SwiftUI

struct ToolsView: View {
    @Environment(\.theme) private var theme
    let tools: [Tool] = [
        Tool(iconName: "dollarsign.circle", name: "财务分析", description: "智能财务报表分析", category: "企业管理", isPopular: true),
        Tool(iconName: "chart.pie", name: "税务规划", description: "智能税务筹划建议", category: "企业管理", isPopular: true),
        Tool(iconName: "list.bullet.clipboard", name: "内控审计", description: "内部控制风险评估", category: "企业管理", isPopular: true),
        Tool(iconName: "chart.bar", name: "经营分析", description: "企业经营数据分析", category: "企业管理", isPopular: true),
        Tool(iconName: "doc.plaintext", name: "合规检查", description: "法律法规合规检查", category: "企业管理", isPopular: false),
        Tool(iconName: "arrow.left.arrow.right", name: "成本管理", description: "成本核算与优化", category: "企业管理", isPopular: false),
        Tool(iconName: "person.2", name: "人力资源", description: "人力资源管理分析", category: "企业管理", isPopular: false),
        Tool(iconName: "chart.line.uptrend.xyaxis", name: "预算管理", description: "智能预算编制分析", category: "企业管理", isPopular: false),
        Tool(iconName: "briefcase", name: "项目管理", description: "智能项目规划与跟踪", category: "企业管理", isPopular: true),
        Tool(iconName: "person.3", name: "团队协作", description: "高效团队沟通与协作", category: "企业管理", isPopular: true),
        Tool(iconName: "chart.line.uptrend.xyaxis", name: "市场分析", description: "市场趋势与竞争分析", category: "企业管理", isPopular: true),
        Tool(iconName: "doc.text.magnifyingglass", name: "合同管理", description: "智能合同审核与管理", category: "企业管理", isPopular: false),
        Tool(iconName: "calendar", name: "日程安排", description: "智能日程规划与提醒", category: "企业管理", isPopular: false),
        Tool(iconName: "network", name: "客户关系管理", description: "客户数据与关系管理", category: "企业管理", isPopular: false),
        Tool(iconName: "chart.pie", name: "财务报表", description: "智能财务报表生成与分析", category: "企业管理", isPopular: false),
        Tool(iconName: "gearshape", name: "运营优化", description: "企业运营流程优化", category: "企业管理", isPopular: false),
        Tool(iconName: "building.2", name: "企业架构", description: "企业架构设计与优化", category: "企业管理", isPopular: true),
        Tool(iconName: "lightbulb", name: "创新管理", description: "企业创新策略与实施", category: "企业管理", isPopular: true),
        Tool(iconName: "globe", name: "国际化战略", description: "企业国际化发展策略", category: "企业管理", isPopular: false),
        Tool(iconName: "hand.raised", name: "风险管理", description: "企业风险识别与控制", category: "企业管理", isPopular: true),
        Tool(iconName: "chart.xyaxis.line", name: "绩效管理", description: "员工绩效评估与提升", category: "企业管理", isPopular: false),
        Tool(iconName: "person.crop.circle.badge.checkmark", name: "人才发展", description: "人才培养与发展计划", category: "企业管理", isPopular: true),
        Tool(iconName: "rectangle.stack.person.crop", name: "知识管理", description: "企业知识共享与管理", category: "企业管理", isPopular: false),
        Tool(iconName: "arrow.2.squarepath", name: "变革管理", description: "企业变革实施与管理", category: "企业管理", isPopular: true),
        Tool(iconName: "waveform.path.ecg", name: "健康管理", description: "员工健康与福利管理", category: "企业管理", isPopular: false),
        Tool(iconName: "leaf", name: "可持续发展", description: "企业可持续发展策略", category: "企业管理", isPopular: true),
        Tool(iconName: "lock.shield", name: "信息安全", description: "企业信息安全管理", category: "企业管理", isPopular: false),
        Tool(iconName: "bolt", name: "能源管理", description: "企业能源使用优化", category: "企业管理", isPopular: false),
        Tool(iconName: "antenna.radiowaves.left.and.right", name: "通信管理", description: "企业通信系统优化", category: "企业管理", isPopular: false),
        Tool(iconName: "shippingbox", name: "供应链管理", description: "供应链优化与管理", category: "企业管理", isPopular: true),
        Tool(iconName: "creditcard", name: "支付管理", description: "企业支付流程优化", category: "企业管理", isPopular: false),
        Tool(iconName: "cart", name: "采购管理", description: "企业采购策略与管理", category: "企业管理", isPopular: false),
        Tool(iconName: "building.columns", name: "政府关系", description: "企业与政府关系管理", category: "企业管理", isPopular: false),
        Tool(iconName: "megaphone", name: "品牌管理", description: "企业品牌策略与管理", category: "企业管理", isPopular: true),
        Tool(iconName: "person.2.wave.2", name: "客户体验", description: "客户体验优化与管理", category: "企业管理", isPopular: true),
        Tool(iconName: "chart.bar.doc.horizontal", name: "数据分析", description: "企业数据分析与应用", category: "企业管理", isPopular: true),
        Tool(iconName: "network.badge.shield.half.filled", name: "网络安全", description: "企业网络安全管理", category: "企业管理", isPopular: false),
        Tool(iconName: "cloud", name: "云计算", description: "企业云计算资源管理", category: "企业管理", isPopular: false),
        Tool(iconName: "server.rack", name: "IT基础设施", description: "企业IT基础设施管理", category: "企业管理", isPopular: false),
        Tool(iconName: "pencil.and.outline", name: "文档管理", description: "企业文档创建与管理", category: "企业管理", isPopular: false),
        Tool(iconName: "person.crop.circle.fill.badge.plus", name: "招聘管理", description: "企业招聘流程优化", category: "企业管理", isPopular: false),
        Tool(iconName: "person.3.sequence.fill", name: "组织发展", description: "企业组织结构优化", category: "企业管理", isPopular: true),
        Tool(iconName: "chart.pie.fill", name: "财务预测", description: "企业财务预测与分析", category: "企业管理", isPopular: true),
        Tool(iconName: "chart.bar.fill", name: "销售管理", description: "企业销售策略与管理", category: "企业管理", isPopular: true),
        Tool(iconName: "person.2.fill", name: "员工关系", description: "企业员工关系管理", category: "企业管理", isPopular: false),
        Tool(iconName: "building.2.crop.circle", name: "设施管理", description: "企业设施维护与管理", category: "企业管理", isPopular: false)
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        List {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(tools) { tool in
                    ToolItemView(tool: tool)
                }
            }
            .padding(8)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
//        .dismissKeyboardOnScroll()
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .refreshable {
            
        }
    }
}
