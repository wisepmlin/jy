import SwiftUI
import SwiftUIX

// 动态内容视图
struct DynamicContentView: View {
    @Environment(\.theme) private var theme
    @Binding var selectedBottomTab: TabItem?
    let bottomToabs: [TabItem]
    let moments: [MomentItem]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollableTabBar(selectedTab: $selectedBottomTab,
                           tabs: bottomToabs)
            
            PageViewController(pages: bottomToabs.map { tab in
                MomentsList(moments: moments)
            }, currentPage: Binding(
                get: { bottomToabs.firstIndex(where: { $0 == selectedBottomTab }) ?? 0 },
                set: { selectedBottomTab = bottomToabs[$0] }
            ))
            .ignoresSafeArea(.all, edges: .bottom)
        }
    }
}

struct MomentsList: View {
    let moments: [MomentItem]
    var body: some View {
        List {
            ForEach(enumerating: moments) { index, moment in
                MomentCard(moment: moment)
            }
        }
        .JYXQListStyle()
        .contentMargins(.bottom, 128, for: .scrollContent)
        .refreshable {
            // 刷新逻辑
        }
    }
}

// 人脉视图
struct ContactsContentView: View {
    @Environment(\.theme) private var theme
    @Binding var selectedContactsBottomTab: TabItem?
    let contactsBottomToabs: [TabItem]
    let contacts: [Contact]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollableTabBar(selectedTab: $selectedContactsBottomTab,
                           tabs: contactsBottomToabs)
            
            contactsBottomTabView
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    // 人脉底部标签视图
    private var contactsBottomTabView: some View {
        PageViewController(pages: contactsBottomToabs.map { tab in
            ContactListView(mockContacts: contacts)
        }, currentPage: Binding(
            get: { contactsBottomToabs.firstIndex(where: { $0 == selectedContactsBottomTab }) ?? 0 },
            set: { selectedContactsBottomTab = contactsBottomToabs[$0] }
        ))
    }
} 
