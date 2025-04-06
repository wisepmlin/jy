//
//  TabContentView.swift
//  jy
//
//  Created by 林晓彬 on 2025/1/30.
//
import SwiftUI

/// TabContentView 是主要的内容视图，负责展示新闻和文章列表
/// 包含以下主要功能：
/// - 新闻轮播图展示
/// - 热门内容展示
/// - 话题列表展示
/// - 支持下拉刷新和加载更多
struct TabContentView: View {
    @ScrollOffsetProxy(.bottom, id: "Foo") private var scrollOffsetProxy
    // MARK: - Properties
    /// 主题环境变量
    @Environment(\.theme) private var theme
    /// 视图模型，管理数据和业务逻辑
    @StateObject private var viewModel = TabContentViewModel()
    /// 导航路径，控制页面跳转
    @Binding var navigationPath: [NavigationType]
    @State private var isRefreshing = false
    // MARK: - Body
    var body: some View {
        List {
            // 顶部新闻轮播组件
            NewsCarouselView(navigationPath: $navigationPath)
            // 话题分类展示
            TopicsView(navigationPath: $navigationPath)
            // 热门内容展示区域
            HotView(navigationPath: $navigationPath)
            // 话题列表展示
            TopicsListView(navigationPath: $navigationPath, viewModel: viewModel)
            // 底部加载状态展示
            FooterSection(viewModel: viewModel)
        }
        .JYXQListStyle()
        .refreshable {
            // 下拉刷新时记录用户行为
            Analytics.logEvent("pull_to_refresh", parameters: [
                "page": "tab_content",
                "timestamp": Date().timeIntervalSince1970
            ])
        }
        .task {
            // 首次加载数据
            if viewModel.topicGroups.isEmpty {
                // 记录页面浏览行为
                Analytics.logEvent("page_view", parameters: [
                    "page": "tab_content",
                    "timestamp": Date().timeIntervalSince1970
                ])
                await viewModel.refreshData()
            }
        }
        .scrollOffsetID("Foo")
    }
}

/// 底部加载状态展示组件
private struct FooterSection: View {
    /// 主题环境变量
    @Environment(\.theme) private var theme
    /// 视图模型引用
    @ObservedObject var viewModel: TabContentViewModel
    
    var body: some View {
        Group {
            // 没有更多数据时显示提示
            if !viewModel.hasMoreData {
                Text("没有更多最新数据了")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(32)
                    .padding(.bottom, 64)
            }
            
            // 加载中状态显示
            if viewModel.isLoading && !viewModel.topicGroups.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
}

// MARK: - Article Views
struct ArticleView: View {
    @Environment(\.theme) private var theme
    @Binding var navigationPath: [NavigationType]
    let topics: [TopicItem]
    let isLastGroup: Bool
    let onAppearLast: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(enumerating: topics) { index, topic in
                TopicRow(topic: topic)
                    .onTapGesture {
                        navigationPath.append(NavigationType.hotTopic(topic: "热门话题"))
                    }
                    .task {
                        if isLastGroup && index == topics.count - 1 {
                            onAppearLast(true)
                        }
                    }
                if index != topics.count - 1 {
                    Divider().opacity(0.7).padding(.leading, 12)
                }
            }
        }
        .background(theme.background)
        .standardListRowStyle()
        .cornerRadius(theme.defaultCornerRadius)
        .id(topics)
    }
}

struct RecommendArticleView: View {
    @Environment(\.theme) private var theme
    @Binding var navigationPath: [NavigationType]
    let topics: [TopicItem]
    let isLastGroup: Bool
    let onAppearLast: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(topics.enumerated()), id: \.element.id) { index, topic in
                if index == 2 {
                    RecommendRow(topic: topic)
                        .onTapGesture {
                            navigationPath.append(NavigationType.hotTopic(topic: "热门话题"))
                        }
                        .onAppear {
                            if isLastGroup && index == topics.count - 1 {
                                onAppearLast(true)
                            }
                        }
                } else {
                    TopicRow(topic: topic)
                        .onTapGesture {
                            navigationPath.append(NavigationType.hotTopic(topic: "热门话题"))
                        }
                        .onAppear {
                            if isLastGroup && index == topics.count - 1 {
                                onAppearLast(true)
                            }
                        }
                    Divider()
                        .opacity(0.75)
                        .padding(.leading, 12)
                }
            }
        }
        .background(theme.background)
        .standardListRowStyle()
        .cornerRadius(theme.defaultCornerRadius)
    }
}

// 完善个人信息气泡提示栏
struct CompleteInfoBubble: View {
    @Environment(\.theme) private var theme
    @Binding var isEdit: Bool
    var body: some View {
        HStack {
            KFImage(URL(string: "https://img0.baidu.com/it/u=1077282731,2234353719&fm=253&fmt=auto&app=120&f=JPEG?w=800&h=800"))
                .resizable()
                .placeholder {
                    ProgressView() // 加载中显示进度条
                }
                .fade(duration: 0.35) // 加载完成后的动画
                .scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 26))
            VStack(alignment: .leading, spacing: 0) {
                Text("HI, WISE")
                    .themeFont(theme.fonts.small)
                    .foregroundColor(theme.primaryText)
                Text("完善信息，获得精准推荐")
                    .themeFont(theme.fonts.caption)
                    .foregroundColor(theme.subText2)
            }
            Spacer()
            Button(action: {
                isEdit.toggle()
            }, label: {
                Text("立即完善")
                    .themeFont(theme.fonts.small)
                    .foregroundColor(theme.background)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(height: 32)
                    .background(theme.jyxqPrimary)
                    .cornerRadius(20)
                    .padding(6)
            })
        }
        .padding(4)
        .frame(height: 52)
        .background {
            RoundedRectangle(cornerRadius: 26)
                .fill(Material.bar)
        }
    }
}
