//
//  BenefitRow.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/12.
//
import SwiftUI

struct BenefitRow: View {
    let icon: String
    let text: String
    @Environment(\.theme) private var theme
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(theme.jyxqPrimary)
                .font(.system(size: 16))
                .frame(width: 32, height: 32)
                .background(theme.jyxqPrimary.opacity(0.1))
                .cornerRadius(8)
            
            Text(text)
                .font(.system(size: 16))
            
            Spacer()
            
            Image(systemName: "checkmark")
                .foregroundColor(.green)
        }
    }
}
