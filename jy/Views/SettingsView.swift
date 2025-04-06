import SwiftUI

struct SettingsView: View {
    @Environment(\.theme) private var theme
    @State private var isDarkMode = false
    @State private var isNotificationsEnabled = true
    @State private var selectedLanguage = "简体中文"
    
    var body: some View {
        List {
            Section(header: Text("通用设置").foregroundColor(theme.subText2)) {
                Toggle("深色模式", isOn: $isDarkMode)
                    .tint(theme.jyxqPrimary)
                Toggle("通知提醒", isOn: $isNotificationsEnabled)
                    .tint(theme.jyxqPrimary)
                
                Picker("语言", selection: $selectedLanguage) {
                    Text("简体中文").tag("简体中文")
                    Text("English").tag("English")
                }
            }
            
            Section(header: Text("隐私与安全").foregroundColor(theme.subText2)) {
                NavigationLink("隐私设置") {
                    Text("隐私设置页面")
                }
                NavigationLink("账号安全") {
                    Text("账号安全页面")
                }
            }
            
            Section(header: Text("其他").foregroundColor(theme.subText2)) {
                NavigationLink("关于我们") {
                    Text("关于我们页面")
                }
                NavigationLink("用户协议") {
                    Text("用户协议页面")
                }
                NavigationLink("隐私政策") {
                    Text("隐私政策页面")
                }
            }
            
            Button(action: {
                // 退出登录逻辑
            }) {
                Text("退出登录")
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity)
            }
            .listRowBackground(theme.background)
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .background(theme.gray6Background)
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
}