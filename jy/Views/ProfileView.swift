import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject private var stackDepth: StackDepthManager
    @Environment(\.theme) private var theme
    @StateObject private var viewModel = AuthViewModel()
    @State private var isEditMode = false
    @State private var newName = ""
    @State private var newEmail = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var navigationPath: [ProfileViewNavigationType] = []
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                // 会员等级卡片
                VIPCardView()
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                
                // 用户信息卡片
                UserProfileCardView(avatarImage: $avatarImage)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))

                // 功能列表
                HStack {
                    Button(action: {
                        
                    }, label: {
                        FunctionTwoRow(icon: "doc.text", title: "文章")
                    })
                    Button(action: {
                        
                    }, label: {
                        FunctionTwoRow(icon: "bubble.left.and.bubble.right", title: "咨询")
                    })
                    Button(action: {
                        
                    }, label: {
                        FunctionTwoRow(icon: "square.and.pencil", title: "动态")
                    })
                    Button(action: {
                        
                    }, label: {
                        FunctionTwoRow(icon: "star.fill", title: "收藏")
                    })
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                .padding(.vertical, 12)
                .background(theme.background)
                .cornerRadius(theme.defaultCornerRadius)
                
                // 其他功能列表
                VStack {
                    Button(action: {
                        
                    }, label: {
                        FunctionRow(icon: "book", title: "我的栏目")
                    })
                    .padding(.horizontal, 12)
                    Divider().opacity(0.7).padding(.leading, 12)
                    Button(action: {
                        
                    }, label: {
                        FunctionRow(icon: "list.bullet.rectangle", title: "我的订单")
                    })
                    .padding(.horizontal, 12)
                    Divider().opacity(0.7).padding(.leading, 12)
                    Button(action: {
                        
                    }, label: {
                        FunctionRow(icon: "creditcard", title: "我的钱包", value: "¥ 333,988.00")
                    })
                    .padding(.horizontal, 12)
                    Divider().opacity(0.7).padding(.leading, 12)
                    Button(action: {
                        
                    }, label: {
                        FunctionRow(icon: "clock", title: "阅读历史")
                    })
                    .padding(.horizontal, 12)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                .padding(.vertical, 8)
                .background(theme.background)
                .cornerRadius(theme.defaultCornerRadius)
                
                // 商城和帮助
                VStack {
                    Button(action: {
                        
                    }, label: {
                        FunctionRow(icon: "gift", title: "积分商城")
                    })
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(theme.background)
                .cornerRadius(theme.defaultCornerRadius)
                
                VStack {
                    Button(action: {
                        
                    }, label: {
                        FunctionRow(icon: "questionmark.circle", title: "帮助中心")
                    })
                    .padding(.horizontal, 12)
                    Divider().opacity(0.7).padding(.leading, 12)
                    Button(action: {
                        
                    }, label: {
                        FunctionRow(icon: "exclamationmark.bubble", title: "意见反馈", value: "欢迎吐槽")
                    })
                    .padding(.horizontal, 12)
                    Divider().opacity(0.7).padding(.leading, 12)
                    Button(action: {
                        
                    }, label: {
                        FunctionRow(icon: "person.2", title: "加入社群")
                    })
                    .padding(.horizontal, 12)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                .padding(.vertical, 8)
                .background(theme.background)
                .cornerRadius(8)
            }
            .contentMargins(.top, 8 ,for: .scrollContent)
            .contentMargins(.bottom, 128 ,for: .scrollContent)
            .listRowSpacing(8)
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.inline)
            .background(theme.gray6Background)
            .navigationBarBackground()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 20) {
                        //签到
                        Button(action: {}, label: {
                            Image(systemName: "calendar.badge.clock")
                                .themeFont(theme.fonts.body)
                                .foregroundColor(theme.jyxqPrimary)
                        })
                        
                        //通知
                        Button(action: {
                            navigationPath.append(ProfileViewNavigationType.notification)
                        }, label: {
                            Image(systemName: "bell")
                                .themeFont(theme.fonts.body)
                                .foregroundColor(theme.jyxqPrimary)
                        })
                        
                        //设置
                        Button(action: {}, label: {
                            Image(systemName: "gearshape")
                                .themeFont(theme.fonts.body)
                                .foregroundColor(theme.jyxqPrimary)
                        })
                    }
                }
            }
            .navigationDestination(for: ProfileViewNavigationType.self) { type in
                switch type {
                case .notification:
                    NotificationView()
                case .settings:
                    SettingsView()
                case .editProfile:
                    EditProfileView()
                }
            }
            .refreshable {

            }
        }
        .onAppear {
            viewModel.fetchUserProfile()
            resetEditState()
        }
    }
    
    private func resetEditState() {
        newName = viewModel.currentUser?.name ?? ""
        newEmail = viewModel.currentUser?.email ?? ""
    }
}


// 统计数据视图组件
struct StatView: View {
    let value: String
    let title: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// 功能列表行组件
struct FunctionRow: View {
    @Environment(\.theme) private var theme
    let icon: String
    let title: String
    var value: String? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .themeFont(theme.fonts.title3)
                .foregroundColor(theme.subText2)
                .frame(width: 20, height: 20, alignment: .center)
            Text(title)
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.primaryText)
            Spacer()
            if let value = value {
                Text(value)
                    .foregroundColor(.gray)
            }
            Image(systemName: "chevron.right")
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.subText3)
        }
        .padding(.vertical, 12)
    }
}

// 功能列表行组件
struct FunctionTwoRow: View {
    @Environment(\.theme) private var theme
    let icon: String
    let title: String
    var value: String? = nil
    
    var body: some View {
        VStack(spacing: theme.defaultCornerRadius) {
            Image(icon)
                .resizable()
                .frame(width: 44, height: 44, alignment: .center)
            Text(title)
                .themeFont(theme.fonts.body)
                .foregroundColor(theme.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    ProfileView()
}
