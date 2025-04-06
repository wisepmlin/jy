import SwiftUI
import PhotosUI

struct EditProfileView: View {
    @Environment(\.theme) private var theme
    @StateObject private var viewModel = AuthViewModel()
    @State private var newName = ""
    @State private var newEmail = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section {
                // 头像选择器
                HStack {
                    Text("头像")
                        .foregroundColor(theme.primaryText)
                    Spacer()
                    let avatarUrl = viewModel.currentUser?.avatar
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let avatarImage {
                            avatarImage
                                .resizable()
                                .scaledToFill()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        } else if let avatarUrl,
                                  let _ = URL(string: avatarUrl) {
                            ProgressView()
                                .frame(width: 60, height: 60)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(theme.subText2)
                        }
                    }
                }
                
                // 用户名编辑
                TextField("用户名", text: $newName)
                    .textContentType(.username)
                
                // 邮箱编辑
                TextField("邮箱", text: $newEmail)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
            
            Section {
                Button(action: {
                    // 保存修改
                    viewModel.updateProfile(name: newName, email: newEmail, avatar: "")
                    dismiss()
                }) {
                    Text("保存修改")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(theme.background)
                }
                .listRowBackground(theme.jyxqPrimary)
            }
        }
        .navigationTitle("编辑资料")
        .navigationBarTitleDisplayMode(.inline)
        .background(theme.gray6Background)
        .onAppear {
            newName = viewModel.currentUser?.name ?? ""
            newEmail = viewModel.currentUser?.email ?? ""
        }
    }
}

#Preview {
    NavigationView {
        EditProfileView()
    }
}
