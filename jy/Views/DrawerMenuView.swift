import SwiftUI

struct DrawerMenuView: View {
    @Environment(\.theme) private var theme
    let userImage = "avatar_placeholder"
    let userName = "林晓彬"
    @State private var selectedCompanyId: String? = "personal" // 默认选中个人账号中心
    @State private var navigationPath: [MenuNavigationType] = [] // 导航路径
    @State private var organization: String = Company.companies[0].name
    @State private var isMy: Bool = false
    @State private var isQr: Bool = false
    @Binding var isDrawerOpen: Bool
    let companies = Company.companies
    /// 轻度触感反馈生成器
    private let lightHaptic = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(alignment: .leading, spacing: 0) {
                // 用户信息区域
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        HStack(spacing: 12) {
                            KFImage(URL(string: "https://iknow-pic.cdn.bcebos.com/fcfaaf51f3deb48f8332e543e21f3a292cf578d7"))
                                .resizable()
                                .placeholder {
                                    ProgressView() // 加载中显示进度条
                                }
                                .fade(duration: 0.35) // 加载完成后的动画
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 64, height: 64)
                                .cornerRadius(theme.defaultCornerRadius)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Text(userName)
                                        .themeFont(theme.fonts.title2)
                                        .foregroundColor(theme.primaryText)
                                    Image(systemName: "chevron.right")
                                        .themeFont(theme.fonts.caption)
                                        .foregroundColor(theme.subText)
                                }
                                
                                Text(organization)
                                    .themeFont(theme.fonts.caption)
                                    .foregroundColor(theme.subText2)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            lightHaptic.impactOccurred() // 触发轻度触感
                            lightHaptic.prepare() // 为下一次触感做准备
                            isMy.toggle()
                        }
                        
                        Spacer()
                        
                        Qr()
                            .fill(theme.primaryText)
                            .frame(width: 32, height: 32)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                lightHaptic.impactOccurred() // 触发中度触感
                                lightHaptic.prepare() // 为下一次触感做准备
                                isQr.toggle()
                            }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 32)
                    .padding(.bottom, 16)
                }
                
                // 企业列表
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(companies) { company in
                            CompanyListItem(
                                company: company,
                                isSelected: selectedCompanyId == company.id
                            ) {
                                withAnimation(.smooth) {
                                    selectedCompanyId = company.id
                                    isDrawerOpen = false
                                    print("isDrawerOpen:\(isDrawerOpen)")
                                }
                                organization = company.name
                            }
                        }
                        
                        // 创建/加入企业按钮
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "plus.circle")
                                    .frame(width: 28, height: 28)
                                Text("创建/加入企业")
                            }
                            .foregroundColor(.gray)
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                HStack {
                    // 底部VIP功能按钮
                    Button(action: {
                        navigationPath.append(MenuNavigationType.vipFuntion)
                    }) {
                        HStack {
                            Image("vip_icon")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("高级功能")
                                .foregroundColor(theme.jyxqPrimary)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    Spacer()
                    // 底部设置功能按钮
                    Button(action: {}) {
                        Circle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 28, height: 28)
                            .overlay {
                                Image(systemName: "gearshape.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 18))
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(theme.gray6Background)
            .navigationDestination(for: MenuNavigationType.self) { type in
                VIPFuncitonView()
            }
            .fullScreenCover(isPresented: $isMy) {
                ISMyView(isMy: $isMy, organization: $organization, userName: userName)
            }
            .fullScreenCover(isPresented: $isQr) {
                ISMyQr(isQr: $isQr, organization: $organization, userName: userName)
            }
        }
    }
}

enum MenuNavigationType: Hashable {
    case vipFuntion
}

// 企业数据模型
struct Company: Identifiable {
    let id: String
    let name: String
    let icon: String
    var isVIP: Bool = false
    var hasNewMessage: Bool = false
    
    // 定义企业数据模型
    static let companies = [
        Company(id: "personal", name: "个人账号中心", icon: "building.fill", isVIP: true),
        Company(id: "company1", name: "进化管理科技咨询", icon: "building.2.fill", isVIP: true),
        Company(id: "company2", name: "腾讯控股有限公司", icon: "building.2.fill", hasNewMessage: true),
        Company(id: "company3", name: "阿里巴巴集团控股有限公司", icon: "building.2.fill"),
        Company(id: "company4", name: "华为技术有限公司", icon: "building.2.fill", isVIP: true),
        Company(id: "company5", name: "百度网络技术（北京）有限公司", icon: "building.2.fill"),
        Company(id: "company6", name: "京东集团控股有限公司", icon: "building.2.fill"),
        Company(id: "company7", name: "小米科技有限公司", icon: "building.2.fill"),
        Company(id: "company8", name: "网易科技（杭州）有限公司", icon: "building.2.fill", isVIP: true),
        Company(id: "company9", name: "腾讯控股有限公司", icon: "building.2.fill"),
        Company(id: "company10", name: "字节跳动科技有限公司", icon: "building.2.fill"),
        Company(id: "company11", name: "美团点评", icon: "building.2.fill"),
        Company(id: "company12", name: "滴滴出行", icon: "building.2.fill"),
        Company(id: "company13", name: "携程旅行", icon: "building.2.fill"),
        Company(id: "company14", name: "快手", icon: "building.2.fill"),
        Company(id: "company15", name: "飞猪旅行", icon: "building.2.fill")
    ]
}

// 修改企业列表项组件
struct CompanyListItem: View {
    
    @Environment(\.theme) private var theme
    let company: Company
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? theme.jyxqPrimary.opacity(0.1) : theme.subText3.opacity(0.3))
                    .frame(width: 28, height: 28)
                    .overlay {
                        Image(systemName: company.icon)
                            .themeFont(theme.fonts.small)
                            .foregroundColor(isSelected ? theme.jyxqPrimary : theme.subText2)
                    }
                
                Text(company.name)
                    .themeFont(theme.fonts.body)
                    .foregroundColor(theme.primaryText)
                
                Spacer()
                
                if company.isVIP {
                    Text("VIP")
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(theme.jyxqPrimary)
                        .cornerRadius(4)
                }
                
                if company.hasNewMessage {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(theme.jyxqPrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background {
                if isSelected {
                    LinearGradient(colors: [.clear, theme.jyxqPrimary.opacity(0.1)], startPoint: .trailing, endPoint: .leading)
                } else {
                    Color.clear
                }
            }
        }
    }
}
