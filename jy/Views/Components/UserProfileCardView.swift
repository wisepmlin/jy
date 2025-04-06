import SwiftUI

struct UserProfileCardView: View {
    @Environment(\.theme) private var theme
    @StateObject private var viewModel = AuthViewModel()
    @Binding var avatarImage: Image?
    @State private var imageLoadingTask: Task<Void, Never>?
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                Group {
                    if let avatarImage {
                        avatarImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 52, height: 52)
                            .clipShape(Circle())
                    } else if let avatarUrl = viewModel.currentUser?.avatar,
                              let _ = URL(string: avatarUrl) {
                        ProgressView()
                            .frame(width: 52, height: 52)
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 52, height: 52)
                            .foregroundColor(theme.subText2)
                    }
                }
                .animation(.easeInOut, value: avatarImage)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.currentUser?.name ?? "未设置")
                        .font(.system(size: 20, weight: .bold))
                    Text(viewModel.currentUser?.email ?? "未设置")
                        .font(.system(size: 14))
                        .foregroundColor(theme.subText2)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .themeFont(theme.fonts.body)
                    .foregroundColor(theme.subText3)
            }
            .padding(.horizontal, 12)
            
            Divider().opacity(0.7)
            
            // 统计数据
            HStack(spacing: 0) {
                StatView(value: "340", title: "粉丝")
                StatView(value: "173", title: "关注")
                StatView(value: "234", title: "赞")
                StatView(value: "432", title: "经验值")
            }
        }
        .padding(.vertical, 12)
        .background(theme.background)
        .cornerRadius(theme.defaultCornerRadius)
        .onDisappear {
            imageLoadingTask?.cancel()
        }
    }
}

#Preview {
    UserProfileCardView(avatarImage: .constant(nil))
}
