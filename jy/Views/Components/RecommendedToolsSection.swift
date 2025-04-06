import SwiftUI

struct RecommendedToolsSection: View {
    @Environment(\.theme) var theme
    let tools: [RecommendedTool] // 假设Tool是recommendedTools的类型
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("推荐工具")
                .font(theme.fonts.body)
                .foregroundColor(theme.primaryText)
                .padding(.horizontal, 16)
            
            ForEach(tools) { tool in
                RecommendedToolView(tool: tool)
            }
        }
        .cornerRadius(theme.defaultCornerRadius)
    }
} 
