//
//  RecommendContentView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/15.
//
import SwiftUI

struct RecommendContentView: View {
    @Environment(\.theme) private var theme
    @StateObject private var viewModel = TabContentViewModel()
    @Binding var navigationPath: [NavigationType]
    @State private var isEdit: Bool = false
    
    var body: some View {
        List {
            RecommendListView(navigationPath: $navigationPath,
                              viewModel: viewModel)
            
            if !viewModel.hasMoreData {
                noMoreDataView
            }
            
            if viewModel.isLoading && !viewModel.topicGroups.isEmpty {
                loadingView
            }
        }
        .JYXQListStyle()
        .refreshable {
            
        }
        .task {
            if viewModel.topicGroups.isEmpty {
                await viewModel.refreshData()
            }
        }
        .safeAreaInset(edge: .top, spacing: 0, content: {
            CompleteInfoBubble(isEdit: $isEdit)
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
        })
    }
    
    private var noMoreDataView: some View {
        Text("没有更多最新数据了")
            .font(.footnote)
            .foregroundColor(.gray)
            .standardListRowStyle()
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(32)
            .padding(.bottom, 64)
    }
    
    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
}
