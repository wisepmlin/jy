//
//  CustomBUtton.swift
//  jy
//
//  Created by 林晓彬 on 2025/1/29.
//
import SwiftUI

// MARK: - Helper Views
struct FlashNewsToolbarButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    @Environment(\.theme) private var theme
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(theme.primaryText)
                .contentShape(Rectangle())
        }
        .buttonStyle(FlashNewsToolbarButtonStyle())
    }
}

private struct FlashNewsToolbarButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    
    func makeBody(configuration: Self.Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        return configuration.label
            .scaleEffect(isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
            .background(
                Circle()
                    .fill(isPressed ?
                          theme.subText.opacity(0.2) :
                            Color.clear)
                    .frame(width: 32, height: 32)
            )
    }
}
