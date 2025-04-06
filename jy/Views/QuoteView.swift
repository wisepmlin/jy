//
//  QuoteView.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

struct QuoteView: View {
    let text: String
    let author: String?
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing) {
            HStack(spacing: theme.spacing) {
                Rectangle()
                    .fill(theme.jyxqPrimary)
                    .frame(width: 4)
                
                Text(text)
                    .themeFont(theme.fonts.body)
                    .foregroundColor(theme.subText2)
                    .italic()
                    .lineSpacing(8)
            }
            
            if let author {
                Text("— \(author)")
                    .themeFont(theme.fonts.caption)
                    .foregroundColor(theme.jyxqPrimary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, theme.spacing)
            }
        }
        .padding(theme.spacing * 1.5)
        .background(theme.subText.opacity(0.1))
        .cornerRadius(theme.defaultCornerRadius)
    }
}
