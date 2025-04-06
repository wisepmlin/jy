//
//  FollowButton.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

struct FollowButton: View {
    @State var isFollowing: Bool = false
    @Environment(\.theme) private var theme
    
    var body: some View {
        Button(action: {
            withAnimation {
                isFollowing.toggle()
            }
        }) {
            Text(isFollowing ? "已关注" : "+关注")
                .themeFont(theme.fonts.minButton)
                .foregroundColor(isFollowing ? theme.subText2 : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isFollowing ? theme.subText.opacity(0.1) : theme.jyxqPrimary)
                .cornerRadius(16)
        }
    }
}
