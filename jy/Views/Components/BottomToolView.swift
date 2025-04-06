import SwiftUI

struct BottomToolView: View {
    @Environment(\.theme) var theme
    @Binding var showBottomTool: Bool
    @Binding var commentText: String
    @Binding var heighState: (Bool, Int)
    @Binding var showShareMenu: Bool
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if showBottomTool {
                StyledAdaptiveTextView(placeholder: "想说点什么",
                                   text: $commentText,
                                   heighState: $heighState,
                                   isFocused: $isFocused)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    )
                )
            }
            if !isFocused {
                HStack(spacing: 20) {
                    // 分享按钮
                    bottomButton(image: "square.and.arrow.up", title: "分享", action: {
                        showShareMenu = true
                    })
                    
                    // 点赞按钮
                    bottomButton(image: "hand.thumbsup", title: "463", action: {
                        
                    })
                    
                    // 评论按钮
                    bottomButton(image: "bubble.right", title: "345", action: {
                        
                    })
                    
                    // 收藏按钮
                    bottomButton(image: "star", title: "234", action: {
                        
                    })
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(.bar)
        .transition(.move(edge: .bottom))
    }
    
    private func bottomButton(image: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                icon(image)
                label(title)
            }
            .frame(maxWidth: .infinity)
            .padding(8)
        }
    }
    
    private func icon(_ image: String) -> some View {
        Image(image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 16, height: 16)
            .opacity(0.5)
    }
    
    private func label(_ title: String) -> some View {
        Text(title)
            .themeFont(theme.fonts.small)
            .foregroundColor(theme.subText2)
    }
} 
