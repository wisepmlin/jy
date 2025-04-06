//
//  ToolItemView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/12.
//
import SwiftUI

struct ToolItemView: View {
    @Environment(\.theme) private var theme
    let tool: Tool
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }) {
            VStack(spacing: 12) {
                Image(systemName: tool.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(theme.jyxqPrimary)
                    .frame(width: 48, height: 48)
                    .background(theme.jyxqPrimary.opacity(0.1))
                    .cornerRadius(12)
                
                VStack(spacing: 4) {
                    HStack {
                        Text(tool.name)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.primaryText)
                        if tool.isPopular {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text(tool.description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(theme.background)
            .cornerRadius(theme.defaultCornerRadius)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .buttonStyle(.plain)
    }
}
