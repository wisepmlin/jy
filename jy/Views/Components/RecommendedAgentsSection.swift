import SwiftUI

struct RecommendedAgentsSection: View {
    @Environment(\.theme) var theme
    let agents: [RecommendedAgent]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("推荐智能体")
                .font(theme.fonts.body)
                .foregroundColor(theme.primaryText)
                .padding(.horizontal, 16)
            
            ForEach(agents) { agent in
                RecommendedAgentView(agent: agent)
            }
        }
        .standardListRowStyle()
    }
} 
