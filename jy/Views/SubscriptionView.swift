//
//  SubscriptionView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/12.
//
import SwiftUI

struct SubscriptionView: View {
    @Environment(\.theme) private var theme
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // 会员卡片
                VStack(spacing: 16) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 40))
                        .foregroundColor(theme.jyxqPrimary)
                    
                    Text("AI高级会员")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("解锁所有AI高级功能")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    
                    PricingButton()
                }
                .padding(12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [theme.background, theme.gray6Background]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(theme.defaultCornerRadius)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                
                // 会员权益列表
                VStack(alignment: .leading, spacing: 16) {
                    Text("会员权益")
                        .font(.system(size: 20, weight: .bold))
                    
                    ForEach(platformBenefits, id: \.self) { benefit in
                        BenefitRow(icon: benefitIcon(for: benefit), text: benefit)
                    }
                }
                .padding(12)
                .background(theme.background)
                .cornerRadius(theme.defaultCornerRadius)
            }
            .padding(8)
        }
//        .dismissKeyboardOnScroll()
        .refreshable {
            
        }
    }
    
    private let platformBenefits = [
        "无限AI对话", "高级模型支持", "优先响应", "专属客服",
        "每日推荐问题", "个性化内容推送", "历史记录访问", "多设备同步",
        "数据分析报告", "社区活动优先参与", "专属内容创作工具", "广告移除",
        "问题优先审核", "定制化通知", "高级搜索功能", "内容收藏夹",
        "问题跟踪", "社交媒体分享", "专属徽章", "会员专属折扣"
    ]
    
    private func benefitIcon(for benefit: String) -> String {
        switch benefit {
        case "无限AI对话": return "bubble.left.and.bubble.right.fill"
        case "高级模型支持": return "cpu.fill"
        case "优先响应": return "bolt.fill"
        case "专属客服": return "person.fill.checkmark"
        case "每日推荐问题": return "star.fill"
        case "个性化内容推送": return "bell.fill"
        case "历史记录访问": return "clock.fill"
        case "多设备同步": return "arrow.2.circlepath"
        case "数据分析报告": return "chart.bar.fill"
        case "社区活动优先参与": return "calendar"
        case "专属内容创作工具": return "pencil.and.outline"
        case "广告移除": return "nosign"
        case "问题优先审核": return "checkmark.seal.fill"
        case "定制化通知": return "envelope.fill"
        case "高级搜索功能": return "magnifyingglass"
        case "内容收藏夹": return "bookmark.fill"
        case "问题跟踪": return "flag.fill"
        case "社交媒体分享": return "square.and.arrow.up"
        case "专属徽章": return "rosette"
        case "会员专属折扣": return "tag.fill"
        default: return "checkmark.circle.fill"
        }
    }
}
