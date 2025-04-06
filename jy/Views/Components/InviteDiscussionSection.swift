import SwiftUI

struct InviteDiscussionSection: View {
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 邀请讨论标题
            Text("邀请讨论")
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.subText2)
            
            // 邀请讨论内容
            Text("邀请您参与讨论，分享您的观点和见解。")
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.subText2)
                .lineSpacing(10)
            
            // 邀请讨论按钮
            Button(action: {
                // 邀请讨论操作
            }) {
                Text("邀请讨论")
                    .themeFont(theme.fonts.button)
                    .foregroundColor(Color.white)
                    .frame(maxWidth:.infinity)
                    .padding(.vertical, 12)
                    .background(theme.jyxqPrimary)
                    .cornerRadius(theme.defaultCornerRadius)
            }
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.background)
        }
    }
} 
