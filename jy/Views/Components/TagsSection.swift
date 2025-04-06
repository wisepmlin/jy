import SwiftUI

struct TagsSection: View {
    @Environment(\.theme) var theme
    let tags: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing) {
            // 标签标题
            Text("相关标签")
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.subText2)
            
            // 标签列表 - 使用 FlowLayout
            FlowLayout(spacing: 6) {
                ForEach(tags, id: \.self) { tag in
                    Button(action: {
                        // 点击标签的操作
                    }) {
                        HStack(spacing: 4) {
                            Text("#")
                                .themeFont(theme.fonts.caption)
                                .foregroundColor(theme.jyxqPrimary.opacity(0.6))
                            
                            Text(tag)
                                .themeFont(theme.fonts.caption.bold())
                                .foregroundColor(theme.jyxqPrimary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(theme.jyxqPrimary.opacity(0.05))
                        .cornerRadius(16)
                    }
                }
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: theme.defaultCornerRadius)
                .fill(theme.background)
        }
    }
} 
