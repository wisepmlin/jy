//
//  AIView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/12.
//
import SwiftUI

struct AIView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.theme) private var theme
    @State private var isMarqueeAnimating = true
    @FocusState private var isFocused: Bool
    @State private var inputText = ""
    @State private var bottomPadding: CGFloat = 0
    @State private var isQa =  true
    let managementQuestions: [Question] = [
        Question(index: 0, title: "💰如何建立内控制度？", answer: nil),
        Question(index: 1, title: "🏢企业税务筹划策略", answer: nil),
        Question(index: 2, title: "优化现金流管理", answer: nil),
        Question(index: 3, title: "📊财务报表重要指标", answer: nil),
        Question(index: 4, title: "💰如何做好成本控制？", answer: nil),
        Question(index: 5, title: "📋税收优惠政策解读", answer: nil),
        Question(index: 6, title: "企业财务风险防范", answer: nil),
        Question(index: 7, title: "📝预算管理有效方法", answer: nil),
        Question(index: 8, title: "📑规范财务管理制度", answer: nil),
        Question(index: 9, title: "💵资金管理核心要素", answer: nil),
        Question(index: 10, title: "税务风险管理要点", answer: nil),
        Question(index: 11, title: "🔍内部审计重点领域", answer: nil),
        Question(index: 12, title: "📈如何优化融资结构？", answer: nil),
        Question(index: 13, title: "🏢财务共享中心建设", answer: nil),
        Question(index: 14, title: "💎企业资产管理方法", answer: nil),
        Question(index: 15, title: "📋税务稽查应对策略", answer: nil),
        Question(index: 16, title: "💻提升财务信息化", answer: nil),
        Question(index: 17, title: "🔄财务转型关键步骤", answer: nil),
        Question(index: 18, title: "💰费用控制体系建设", answer: nil),
        Question(index: 19, title: "📜税务合规管理要点", answer: nil),
        Question(index: 20, title: "📊投资决策分析方法", answer: nil),
        Question(index: 21, title: "🎯财务战略规划要点", answer: nil),
        Question(index: 22, title: "📉优化企业税负结构", answer: nil),
        Question(index: 23, title: "💵资金预算编制方法", answer: nil),
        Question(index: 24, title: "🔐加强财务内控管理", answer: nil),
        Question(index: 25, title: "📋税收筹划方案设计", answer: nil),
        Question(index: 26, title: "🔍并购财务尽职调查", answer: nil),
        Question(index: 27, title: "财务风险预警机制", answer: nil),
        Question(index: 28, title: "📈提高资金使用效率", answer: nil),
        Question(index: 29, title: "📑税务管理体系建设", answer: nil),
        Question(index: 30, title: "📊企业财务分析方法", answer: nil),
        Question(index: 31, title: "🔍内控制度评估方法", answer: nil),
        Question(index: 32, title: "📈优化企业财务流程", answer: nil),
        Question(index: 33, title: "⚠️税务筹划风险控制", answer: nil),
        Question(index: 34, title: "📉资产减值测试方法", answer: nil),
        Question(index: 35, title: "🏢企业财务管控模式", answer: nil),
        Question(index: 36, title: "💹提升资金管理水平", answer: nil),
        Question(index: 37, title: "📚税收政策解读技巧", answer: nil),
        Question(index: 38, title: "📊企业财务预测方法", answer: nil),
        Question(index: 39, title: "🔧内控缺陷整改法", answer: nil),
        Question(index: 40, title: "📋优化财务组织架构", answer: nil),
        Question(index: 41, title: "税务风险评估法", answer: nil),
        Question(index: 42, title: "💰企业成本核算方法", answer: nil),
        Question(index: 43, title: "📑财务报告质量控制", answer: nil),
        Question(index: 44, title: "📋健全企业财务制度", answer: nil),
        Question(index: 45, title: "📜税收优惠申请流程", answer: nil),
        Question(index: 46, title: "📊财务预算执行要点", answer: nil),
        Question(index: 47, title: "🔍内控评价标准解读", answer: nil),
        Question(index: 48, title: "📈提升财务管理效率", answer: nil),
        Question(index: 49, title: "📋税务筹划案例分析", answer: nil)
    ]
    @State private var height: CGFloat = 24
    @State private var heighState: (Bool, Int) = (false, 1)
    var body: some View {
        ScrollView {
            ZStack {
                if isQa {
                    aiQAList
                        .transition {
                            .asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .move(edge: .top).combined(with: .opacity)
                            )
                        }
                } else {
                    Color.clear
                }
            }
            .animation(.smooth, value: isQa)
        }
//        .dismissKeyboardOnScroll()
        .safeAreaInset(edge: .bottom) {
            HStack(alignment:  heighState.0 ? .bottom : .center, spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(isFocused ? theme.jyxqPrimary : .gray)
                }
                .frame(height: height, alignment:  heighState.0 ? .bottom : .center)
                
                StyledAdaptiveTextView(placeholder: "请输入你的问题",
                                       text: $inputText,
                                       heighState: $heighState,
                                       isFocused: $isFocused)
                
                Button(action: {}) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(isFocused ? theme.jyxqPrimary : .gray)
                }
                .frame(height: height, alignment:  heighState.0 ? .bottom : .center)
                
                Button(action: {}) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(isFocused ? theme.jyxqPrimary : .gray)
                }
                .frame(height: height, alignment:  heighState.0 ? .bottom : .center)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background {
                if isFocused {
                    Rectangle()
                        .fill(.bar)
                }
            }
            .animation(.easeInOut, value: isFocused)
        }
        .refreshable {
            
        }
        .onAppear {
            // 监听键盘显示/隐藏
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                    bottomPadding = keyboardSize.height
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                bottomPadding = 0
            }
        }
        .onChange(of: isFocused) {
            oldValue, newValue in
            withAnimation(.smooth) {
                isQa = !newValue
            }
        }
    }
    
    var aiQAList: some View {
        // AI助手界面
        VStack(spacing: 16) {
            // Logo和标题
            VStack(spacing: 8) {
                Image("ai_eagle_logo")
                    .resizable()
                    .frame(width: 60, height: 60)
                
                Text("金鹰 AI")
                    .font(.system(size: 20, weight: .bold))
                
                Text("你的专属AI参谋")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 64)
            InfiniteLoopScrollingView(
                width: 100,
                spacing: 8,
                items: managementQuestions,
                autoScroll: true
            ) { item in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        inputText = item.title
                        isFocused = true
                    }
                }, label: {
                    Text(item.title)
                        .themeFont(theme.fonts.body)
                        .foregroundColor(theme.primaryText)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(
                            Color(
                                hue: 0.6 + (Double(item.index) * 0.05).truncatingRemainder(dividingBy: 0.3),
                                saturation: 0.15 + (Double(item.index) * 0.01).truncatingRemainder(dividingBy: 0.1),
                                brightness: 0.95 + (Double(item.index) * 0.01).truncatingRemainder(dividingBy: 0.05)
                            ).opacity(colorScheme == .dark ? 0.2 : 0.5)
                        )
                        .cornerRadius(6)
                })
            }
        }
        .frame(width: UIScreen.main.bounds.width)
    }
}
