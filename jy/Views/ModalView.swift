import SwiftUI

// MARK: - Views
struct ModalView: View {
    // MARK: - Environment
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.theme) private var theme
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    @State private var selectedTab = 1
    @State private var previousTab = 1
    @State private var showTabIndicator = true
    @State private var isClosing = false
    
    // MARK: - Animation
    @Namespace private var animation
    @GestureState private var dragOffset: CGFloat = 0
    
    // MARK: - Constants
    private let tabs = TabItem.aiViewType
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            PageViewController(pages: tabs.map { tab in
                mainContent(tab: tab)
                    .ignoresSafeArea(.all, edges: .bottom)
            }, currentPage: $selectedTab )
            .toolbar {
                leadingToolbarItems
                centerToolbarItems
                trailingToolbarItems
            }
            .background {
                Image("aiview_bg")
                    .resizable()
                    .ignoresSafeArea(.all)
                    .aspectRatio(contentMode: .fill)
                    .opacity(colorScheme == .dark ? 0.3 : 0.5)
            }
            .background(theme.gray6Background)
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.all, edges: .bottom)
            .onAppear {
                setupHaptics()
            }
        } 
    }
    
    // MARK: - Main Content
    private func mainContent(tab: TabItem) -> some View {
        ZStack {
            switch tab.id {
            case "history":
                HistoryView()
            case "jy":
                AIView()
            case "ai":
                SubscriptionView()
            default:
                ToolsView()
            }
        }
    }
    
    // MARK: - Toolbar Items
    private var leadingToolbarItems: ToolbarItem<(), some View> {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: dismissAction) {
                Image(systemName: "xmark")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .font(.system(size: 16, weight: .medium))
            }
            .scaleEffect(isClosing ? 0.8 : 1)
        }
    }
    
    private var centerToolbarItems: ToolbarItem<(), some View> {
        ToolbarItem(placement: .principal) {
            navigationTabs
        }
    }
    
    private var trailingToolbarItems: ToolbarItem<(), some View> {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button(action: {}) {
                    Label("设置", systemImage: "gear")
                }
                Button(action: {}) {
                    Label("反馈", systemImage: "exclamationmark.bubble")
                }
                Button(role: .destructive, action: {}) {
                    Label("清除历史", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .font(.system(size: 16, weight: .medium))
            }
        }
    }
    
    // MARK: - Navigation Tabs
    private var navigationTabs: some View {
        HStack(spacing: 12) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                tabButton(for: index, title: tab.title)
            }
        }
        .animation(.easeOut(duration: 0.35), value: selectedTab)
    }
    
    private func tabButton(for index: Int, title: String) -> some View {
        Button(action: {
            selectedTab = index
            hapticFeedback()
        }) {
            VStack(spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: selectedTab == index ? .bold : .regular))
                    .foregroundColor(selectedTab == index ? (colorScheme == .dark ? .white : .black) : .gray)
                
                tabIndicator(for: index)
            }
            .contentShape(Rectangle())
        }
    }
    
    private func tabIndicator(for index: Int) -> some View {
        Group {
            if showTabIndicator && selectedTab == index {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(theme.jyxqPrimary)
                    .frame(height: 3)
                    .padding(.horizontal)
                    .matchedGeometryEffect(id: "tab_indicator", in: animation)
            } else {
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(Color.clear)
                    .frame(height: 3)
                    .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Actions
    private func dismissAction() {
        withAnimation(.easeIn(duration: 0.35)) {
            isClosing = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                dismiss()
            }
        }
    }
    
    // MARK: - Haptics
    private func setupHaptics() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Preview
#Preview {
    ModalView()
}

