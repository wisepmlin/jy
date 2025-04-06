//
//  NewsDetailView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

struct NewsDetailView: View {
    let title: String
    @Environment(\.theme) private var theme
    @EnvironmentObject private var stackDepth: StackDepthManager
    
    var body: some View {
        HotTopicDetailView(title: title)
            .environmentObject(stackDepth)
    }
}
