import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let apiService = APIService.shared
    
    // 登录方法
    func login(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await apiService.login(email: email, password: password)
                currentUser = response.user
                isAuthenticated = true
            } catch {
                errorMessage = "登录失败：\(error.localizedDescription)"
            }
            isLoading = false
        }
    }
    
    // 登出方法
    func logout() {
        apiService.logout()
        isAuthenticated = false
        currentUser = nil
    }
    
    // 获取用户信息
    func fetchUserProfile() {
        guard let userId = currentUser?.id else { return }
        
        Task {
            do {
                currentUser = try await apiService.getUserProfile(userId: userId)
            } catch {
                errorMessage = "获取用户信息失败：\(error.localizedDescription)"
            }
        }
    }
    
    // 更新用户信息
    func updateProfile(name: String?, email: String?, avatar: String?) {
        let parameters = UpdateUserParameters(
            name: name,
            email: email,
            avatar: avatar
        )
        
        Task {
            do {
                currentUser = try await apiService.updateProfile(user: parameters)
            } catch {
                errorMessage = "更新用户信息失败：\(error.localizedDescription)"
            }
        }
    }
} 