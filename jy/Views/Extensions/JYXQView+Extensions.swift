//
//  View+Extensions.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/14.
//
import SwiftUI

// MARK: - View Modifiers
public extension View {
    func standardListRowStyle() -> some View {
        self
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
    }
    
    func standardListRowStyle_2() -> some View {
        self
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
    }
    
    func JYXQListStyle() -> some View {
        self
            .listStyle(.plain)
            .listRowSpacing(8)
            .contentMargins(.top, 8, for: .scrollContent)
    }
    
    func customFont(fontSize: CGFloat) -> some View {
        self
            .font(.custom("zcoolwenyiti", size: fontSize))
    }

    func updateStackDepth(depth: Binding<Int>) -> some View {
        self.onAppear {
            withAnimation(.smooth) {
                depth.wrappedValue = 1
            }
            print("HotTopicDetailView - 当前导航栈深度: \(depth.wrappedValue)")
        }
    }

    func updateStackDepthOnDisappear(depth: Binding<Int>) -> some View {
        self.onDisappear {
            withAnimation(.smooth) {
                depth.wrappedValue = 0
            }
            print("HotTopicDetailView - 当前导航栈深度: \(depth.wrappedValue)")
        }
    }
}
