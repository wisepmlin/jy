//
//  HistoryItemView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/12.
//
import SwiftUI

struct HistoryItemView: View {
    @Environment(\.theme) private var theme
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text("问题历史")
                        .font(.system(size: 16, weight: .medium))
                    Spacer()
                    Text("2024-01-27")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Text("如何优化企业财务管理流程？")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(theme.background)
            .cornerRadius(theme.defaultCornerRadius)
        }
        .buttonStyle(HistoryItemButtonStyle())
    }
}
