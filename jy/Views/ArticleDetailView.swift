//
//  ArticleDetailView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

struct ArticleDetailView: View {
    let article: String
    @Environment(\.theme) private var theme
    @EnvironmentObject private var stackDepth: StackDepthManager
    var body: some View {
        HotTopicDetailView(title: article)
            .environmentObject(stackDepth)
    }
}
