import SwiftUI

struct RecommendedToolView: View {
    let tool: RecommendedTool
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tool.icon)
                .font(.system(size: 20))
                .foregroundColor(theme.jyxqPrimary)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tool.name)
                    .font(theme.fonts.body)
                    .foregroundColor(theme.primaryText)
                
                Text(tool.description)
                    .font(theme.fonts.caption)
                    .foregroundColor(theme.subText2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(theme.subText2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.background)
        .cornerRadius(8)
    }
}

struct RecommendedAgentView: View {
    let agent: RecommendedAgent
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(agent.avatar)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(agent.name)
                    .font(theme.fonts.body)
                    .foregroundColor(theme.primaryText)
                
                Text(agent.description)
                    .font(theme.fonts.caption)
                    .foregroundColor(theme.subText2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(theme.subText2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(theme.background)
        .cornerRadius(8)
    }
}
