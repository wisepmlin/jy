//
//  VIPBadgeView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

struct VIPBadgeView: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        Text("VIP")
            .themeFont(theme.fonts.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(theme.jyxqPrimary)
            .cornerRadius(4)
    }
}
