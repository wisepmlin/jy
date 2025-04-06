//
//  InteractionSectionView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

// MARK: - Interaction Section
struct InteractionSectionView: View {
    let likeCount: Int
    let commentCount: Int
    let collectCount: Int
    @State var isCollected: Bool = false
    let onLike: () -> Void
    let onComment: () -> Void
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack(alignment: .center, spacing: theme.articleDetail.interactionSpacing) {
            InteractionButton(
                icon: "hand.thumbsup",
                selectedIcon: "",
                count: likeCount,
                action: onLike
            )
            
            InteractionButton(
                icon: "bubble.right",
                selectedIcon: "",
                count: commentCount,
                action: onComment
            )
            
            InteractionButton(
                icon: "star",
                selectedIcon: "star.fill",
                count: collectCount,
                isSelected: isCollected,
                action: {
                    withAnimation {
                        isCollected.toggle()
                    }
                }
            )
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(theme.articleDetail.contentPadding)
    }
}
