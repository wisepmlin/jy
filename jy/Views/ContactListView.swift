import SwiftUI

struct ContactListView: View {
    @Environment(\.theme) private var theme
    @State private var searchText = ""
    @State private var selectedGroup: String? = nil
    var mockContacts: [Contact]
    // 从模拟数据获取所有分组
    var allGroups = TabItem.contactListViewAllTags
    
    var body: some View {
        VStack(spacing: 0) {
            // 分组标签滚动视图
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(allGroups, id: \.self) { item in
                        GroupTag(name: item.title,
                                 isSelected: item.title == selectedGroup,
                                 action: {
                            withAnimation {
                                selectedGroup = (selectedGroup == item.title) ? nil : item.title
                            }
                        })
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // 联系人列表
            List(mockContacts) { contact in
                ContactCard(contact: contact)
                    .listRowBackground(Color.clear)
                    .listRowSeparatorTint(theme.subText3.opacity(0.85))
                    .listRowInsets(EdgeInsets(top: 16, leading: 8, bottom: 16, trailing: 8))
            }
            .listStyle(.plain)
            .contentMargins(.bottom, 64, for: .scrollContent)
            .refreshable {
                
            }
        }
    }
}

// 分组标签组件
struct GroupTag: View {
    @Environment(\.theme) private var theme
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : theme.primaryText)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? theme.jyxqPrimary : theme.subText2.opacity(0.1))
                .cornerRadius(16)
        }
    }
}

// 联系人卡片组件
struct ContactCard: View {
    @Environment(\.theme) private var theme
    let contact: Contact
    
    var body: some View {
        // 基本信息行
        HStack(spacing: 12) {
            // 头像
            KFImage(URL(string: contact.avatar))
                .resizable()
                .placeholder {
                    Color.gray.opacity(0.2)
                }
                .aspectRatio(contentMode: .fill)
                .frame(width: 48, height: 48)
                .clipShape(Circle())
            
            // 名字和职位信息
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(contact.name)
                        .themeFont(theme.fonts.body)
                        .foregroundColor(theme.primaryText)
                    
                    if contact.verifiedStatus {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(theme.jyxqPrimary)
                            .font(.system(size: 12))
                    }
                    
                    if contact.isKeyContact {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                    }
                    
                    // 标签流式布局
                    FlowLayout(spacing: 6) {
                        ForEach(contact.tags) { tag in
                            Text(tag.name)
                                .themeFont(theme.fonts.caption)
                                .foregroundColor(tag.color)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(tag.color.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                }
                
                Text("\(contact.professionalInfo.title) · \(contact.professionalInfo.company)")
                    .themeFont(theme.fonts.small)
                    .foregroundColor(theme.subText2)
                
//                HStack {
                    
                    // 社交统计信息
//                        HStack(spacing: 16) {
//                            Label("\(contact.socialStats.messageCount)", systemImage: "message")
//                            Label("\(contact.socialStats.mutualConnections)个共同好友", systemImage: "person.2")
//                        }
//                        .font(.system(size: 12))
//                        .foregroundColor(.gray)
//                }
            }
            
            Spacer()
            
            // 关注按钮
            Button(action: {}) {
                Text(contact.isFollowing ? "已关注" : "关注")
                    .themeFont(theme.fonts.caption)
                    .foregroundColor(contact.isFollowing ? theme.subText2 : .white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(contact.isFollowing ? theme.subText2.opacity(0.2) : theme.jyxqPrimary)
                    .cornerRadius(16)
            }
        }
    }
}

#Preview {
    ContactListView(mockContacts: [])
}
