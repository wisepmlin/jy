//
//  InteractionButton.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

struct InteractionButton: View {
    let icon: String
    let selectedIcon: String
    let count: Int
    var isSelected: Bool = false
    let action: () -> Void
    @Environment(\.theme) private var theme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: isSelected ? selectedIcon : icon)
                    .themeFont(theme.fonts.body)
                Text("\(count)")
                    .themeFont(theme.fonts.body)
            }
            .foregroundColor(isSelected ? theme.jyxqPrimary : theme.subText2)
            .padding(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
            .frame(height: 38)
            .background {
                RoundedRectangle(cornerRadius: 19)
                    .fill(theme.background)
            }
        }
    }
}
