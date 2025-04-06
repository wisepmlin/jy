//
//  SearchView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/7.
//
import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var stackDepth: StackDepthManager
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var isMore = false
    @FocusState private var isFocused: Bool
    // 搜索历史
    var searchHistory: [SearchHistoryItem] = [
        SearchHistoryItem(keyword: "企业战略", timestamp: Date()),
        SearchHistoryItem(keyword: "财务管理分为几类", timestamp: Date()),
        SearchHistoryItem(keyword: "人力资源方法", timestamp: Date()),
        SearchHistoryItem(keyword: "税务筹划有哪些", timestamp: Date()),
        SearchHistoryItem(keyword: "风险控制", timestamp: Date()),
        SearchHistoryItem(keyword: "企业文化", timestamp: Date()),
        SearchHistoryItem(keyword: "绩效考核", timestamp: Date()),
        SearchHistoryItem(keyword: "供应链管理", timestamp: Date()),
        SearchHistoryItem(keyword: "市场营销步骤", timestamp: Date()),
        SearchHistoryItem(keyword: "质量管理", timestamp: Date()),
        SearchHistoryItem(keyword: "成本控制", timestamp: Date()),
        SearchHistoryItem(keyword: "组织架构如何设计", timestamp: Date())
    ]
    
    // 热搜词
    let hotSearches: [HotSearchItem] = [
        HotSearchItem(keyword: "企业战略", subKeyword: "商业模式"),
        HotSearchItem(keyword: "财务管理", subKeyword: "成本控制"),
        HotSearchItem(keyword: "人力资源", subKeyword: "绩效考核"),
        HotSearchItem(keyword: "税务筹划", subKeyword: "风险管理"),
        HotSearchItem(keyword: "供应链", subKeyword: "库存管理"),
        HotSearchItem(keyword: "市场营销", subKeyword: "品牌建设")
    ]
    
    var body: some View {
        VStack(spacing: 4) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 32) {
                    // 搜索历史
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("最近搜索")
                                .themeFont(theme.fonts.small)
                                .foregroundColor(theme.subText2)
                            Spacer()
                            Button(action: {
                                isMore.toggle()
                            }) {
                                HStack {
                                    Text(isMore ? "收起" : "展开")
                                        .themeFont(theme.fonts.small)
                                        .foregroundColor(theme.subText2)
                                    Image(systemName: isMore ? "chevron.up" : "chevron.down")
                                        .themeFont(theme.fonts.caption)
                                        .foregroundColor(theme.subText2)
                                }
                            }
                            Divider().frame(height: 16)
                            Button(action: {}) {
                                Image(systemName: "trash")
                                    .themeFont(theme.fonts.small)
                                    .foregroundColor(theme.subText2)
                            }
                        }
                        Divider().padding(.bottom, 8).opacity(0.7)
                        // 在 FlowLayout 中需要修改遍历方式
                        let getSearchHistory = isMore ? searchHistory : Array(searchHistory.prefix(8))
                        FlowLayout(spacing: 6) {
                            ForEach(getSearchHistory) { item in
                                Button(action: {
                                    // 点击标签的操作
                                    searchText = item.keyword
                                }) {
                                    Text(item.keyword)
                                        .themeFont(theme.fonts.subBody.weight(.medium))
                                        .foregroundColor(theme.jyxqPrimary2)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 6)
                                        .background(theme.background.opacity(0.5))
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                    
                    
                    // 热搜词
                    VStack(alignment: .leading, spacing: 8) {
                        Text("热搜词-\(hotSearches.count)")
                            .themeFont(theme.fonts.small)
                            .foregroundColor(theme.subText2)
                        Divider().padding(.bottom, 8).opacity(0.7)
                        // 在 LazyVGrid 中需要修改遍历方式
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(hotSearches) { item in
                                Button(action: {
                                    // 点击标签的操作
                                    searchText = item.keyword
                                }) {
                                    HStack {
                                        Image(systemName: "clock")
                                            .themeFont(theme.fonts.small)
                                            .foregroundColor(theme.subText2)
                                        Text(item.keyword)
                                            .themeFont(theme.fonts.subBody.weight(.medium))
                                            .foregroundColor(theme.subText)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                    }
                    
                    
                    // 推荐搜索
                    VStack(alignment: .leading, spacing: 8) {
                        Text("推荐搜索-\(hotSearches.count)")
                            .themeFont(theme.fonts.small)
                            .foregroundColor(theme.subText2)
                        Divider().padding(.bottom, 8).opacity(0.7)
                        // 在 LazyVGrid 中需要修改遍历方式
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(hotSearches) { item in
                                Button(action: {
                                    // 点击标签的操作
                                    searchText = item.keyword
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark.seal")
                                            .themeFont(theme.fonts.small)
                                            .foregroundColor(theme.subText2)
                                        Text(item.keyword)
                                            .themeFont(theme.fonts.subBody.weight(.medium))
                                            .foregroundColor(theme.subText)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
            .dismissKeyboardOnScroll()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItemGroup(placement:  .cancellationAction) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .themeFont(theme.fonts.small)
                        .foregroundColor(theme.subText2)
                    
                    TextField("企业管理", text: $searchText)
                        .focused($isFocused)
                        .themeFont(theme.fonts.body)
                        .foregroundColor(theme.primaryText)
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .themeFont(theme.fonts.small)
                                .foregroundColor(theme.subText2)
                        })
                    }
                }
                .padding(10)
                .background(.bar)
                .frame(height: 36)
                .cornerRadius(20)
                .frame(width: UIScreen.main.bounds.width - 78)
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("取消") {
                    dismiss()
                }
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.primaryText)
            }
        }
        .background(theme.gray6Background)
        .trackLifecycle(onAppear: {
            isFocused = true
            withAnimation(.interactiveSpring()) {
                stackDepth.depth += 1
            }
        }, onDisappear: {
            withAnimation(.interactiveSpring()) {
                stackDepth.depth -= 1
            }
        })
    }
}
