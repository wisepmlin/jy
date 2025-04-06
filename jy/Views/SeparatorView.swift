//
//  SeparatorView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

struct SeparatorView: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack(spacing: 16) {
            Line()
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .foregroundColor(theme.subText2)
            Line()
        }
        .padding(.vertical, 24)
    }
    
    struct Line: View {
        @Environment(\.theme) private var theme
        
        var body: some View {
            Rectangle()
                .fill(theme.subText.opacity(0.2))
                .frame(height: 1)
        }
    }
}
