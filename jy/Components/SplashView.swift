//
//  SplashView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/13.
//
import SwiftUI

struct SplashView: View {
    @Environment(\.theme) private var theme
    @State private var innerGap = true
    let streamBlue = Color(#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
    
    var body: some View {
        ZStack {
            ForEach(0..<8) {
                Circle()
                    .foregroundStyle(
                        .linearGradient(
                            colors: [.green, theme.jyxqPrimary],
                            startPoint: .bottom,
                            endPoint: .leading
                        )
                    )
                    .frame(width: 3, height: 3)
                    .offset(x: innerGap ? 24 : 0)
                    .rotationEffect(.degrees(Double($0) * 45))
                    .hueRotation(.degrees(300))
            }
            
            ForEach(0..<8) {
                Circle()
                    .foregroundStyle(
                        .linearGradient(
                            colors: [theme.jyxqPrimary, streamBlue],
                            startPoint: .bottom,
                            endPoint: .leading
                        )
                    )
                    .frame(width: 4, height: 4)
                    .offset(x: innerGap ? 26 : 0)
                    .rotationEffect(.degrees(Double($0) * 45))
                    .hueRotation(.degrees(60))
                
            }
            .rotationEffect(.degrees(12))
        }
    }
}

#Preview {
    SplashView()
}
