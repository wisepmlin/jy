import SwiftUI

struct VIPCardView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.theme) private var theme
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: -2) {
                    Text("V1.")
                        .italic()
                        .font(.system(size: 52, weight: .heavy))
                        .foregroundColor(theme.primaryText)
                    Text("成长值达到100")
                        .customFont(fontSize: 20)
                        .foregroundColor(theme.primaryText)
                }
                Spacer()
                Image("v1_icon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 100)
            }
            Spacer()
            HStack(alignment: .bottom) {
                VStack(alignment: .leading) {
                    Text("还需要20点成长值升级")
                        .themeFont(theme.fonts.caption)
                        .foregroundColor(theme.subText2)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(theme.subText2.opacity(0.35))
                        .frame(width: 160, height: 8)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(theme.jyxqPrimary)
                                .frame(width: 80, height: 8)
                        }
                    HStack {
                        Text("v1")
                        Spacer()
                        Text("v2")
                    }
                    .frame(width: 160)
                    .themeFont(theme.fonts.caption)
                    .foregroundColor(theme.subText)
                }
                Spacer()
                Button(action: {
                    
                }, label: {
                    Text("加速升级")
                        .themeFont(theme.fonts.body.bold())
                        .foregroundColor(theme.background)
                        .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .background {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(theme.jyxqPrimary)
                        }
                })
            }
        }
        .padding(EdgeInsets(top: 0, leading: 12, bottom: 12, trailing: 12))
        .background {
            VIPBg(cornerRadius: theme.defaultCornerRadius)
                .fill(theme.background)
                .overlay(alignment: .topTrailing) {
                    Image("v1_icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 100)
                        .blur(radius: 32)
                        .opacity(colorScheme == .dark ? 0.5 : 1)
                }
        }
        .overlay(alignment: .topLeading) {
            Text("当前等级")
                .themeFont(theme.fonts.small)
                .foregroundColor(theme.background)
                .padding(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .padding(.trailing, 12)
                .background {
                    VIPTagBg(topLeftRadius: theme.defaultCornerRadius, bottomLeftRadius: 0, bottomRightRadius: theme.defaultCornerRadius)
                        .fill(theme.jyxqPrimary)
                }
        }
    }
}

#Preview {
    VIPCardView()
}
