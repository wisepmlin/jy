import SwiftUI

// MARK: - SquareView
struct SquareView: View {
    // MARK: - Properties
    @StateObject private var viewModel = SquareViewModel()
    @Environment(\.theme) private var theme
    
    // MARK: - State
    @State private var navigationPath: [NavigationType] = []
    @State private var isDrawerOpen: Bool = false
    @State private var selectedTopTab = 0
    @State private var selectedBottomTab: TabItem?
    @State private var selectedContactsBottomTab: TabItem?
    
    // MARK: - Namespaces
    @Namespace private var namespace
    
    // MARK: - Constants
    private let contacts = SquareData.contacts
    private let moments = SquareData.moments
    let topTabs = TabItem.squareAllTabs
    let bottomToabs = TabItem.squareBottomAllTabs
    let contactsBottomToabs = TabItem.contactsBottomToabs
    
    var body: some View {
        NavigationStack {
            PageViewController(pages: topTabs.map { tab in
                pageView(tab: tab)
            }, currentPage: $selectedTopTab)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    SquareToolbarLeadingView(selectedTopTab: $selectedTopTab,
                                             topTabs: topTabs)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    SquareToolbarTrailingView(selectedTopTab: $selectedTopTab,
                                              topTabs: topTabs)
                }
            }
            .background(selectedTopTab == 1 ? theme.background : theme.gray6Background)
            .navigationBarBackground()
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }

}

// MARK: - Helper Views
extension SquareView {
    private func pageView(tab: TabItem) -> some View {
        ZStack {
            switch tab.id {
            case "square":
                DynamicContentView(selectedBottomTab: $selectedBottomTab,
                                 bottomToabs: bottomToabs,
                                 moments: moments)
            default:
                ContactsContentView(selectedContactsBottomTab: $selectedContactsBottomTab,
                                  contactsBottomToabs: contactsBottomToabs,
                                  contacts: contacts)
            }
        }
    }
}

// MARK: - ViewModel
final class SquareViewModel: ObservableObject {
    @Published var isLoading = false
}

// MARK: - Preview
#Preview {
    NavigationView {
        SquareView()
    }
}

