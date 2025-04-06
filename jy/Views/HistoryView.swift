//
//  HistoryView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/12.
//
import SwiftUI

struct HistoryView: View {
    @State private var searchText = ""
    @Environment(\.theme) private var theme
    var body: some View {
        List {
            Section {
                ForEach(0..<200) { _ in
                    HistoryItemView()
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                }
            } header: {
                VStack(spacing: 0) {
                    // 搜索栏
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .themeFont(theme.fonts.small)
                            .foregroundColor(theme.subText2)
                        TextField("搜索历史记录", text: $searchText)
                            .themeFont(theme.fonts.small)
                            .textFieldStyle(PlainTextFieldStyle())
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(8)
                    .background(theme.background)
                    .cornerRadius(8)
                    .padding(.vertical, 8)
                    
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            }
        }
        .scrollContentBackground(.hidden)
//        .dismissKeyboardOnScroll()
        .listRowSpacing(1)
        .listSectionSpacing(0)
        .listStyle(.plain)
        .refreshable {
            
        }
    }
}
