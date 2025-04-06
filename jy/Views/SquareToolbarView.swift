import SwiftUI

struct SquareToolbarLeadingView: View {
    @Environment(\.theme) private var theme
    @Binding var selectedTopTab: Int
    let topTabs: [TabItem]
    
    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                ForEach(Array(topTabs.enumerated()), id: \.1.id) { index, tab in
                    Button(action: {
                        withAnimation(.interactiveSpring()) {
                            selectedTopTab = index
                        }
                    }) {
                        Text(tab.title)
                            .font(selectedTopTab == index ? theme.fonts.title2 : theme.fonts.body)
                            .fontWeight(selectedTopTab == index ? .bold : .regular)
                            .foregroundColor(selectedTopTab == index ? theme.primaryText : theme.subText)
                            .frame(width: 40)
                            .overlay(alignment: .topTrailing) {
                                if tab.showBadge {
                                    if let count = tab.badgeCount, count > 0 {
                                        Text("\(min(count, 99))")
                                            .font(.system(size: 10))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 2)
                                            .background(Color.red)
                                            .clipShape(Capsule())
                                            .offset(x: 12, y: -8)
                                    } else {
                                        Circle()
                                            .fill(Color.red)
                                            .frame(width: 6, height: 6)
                                            .offset(x: 8, y: -4)
                                    }
                                }
                            }
                    }
                }
            }
        }
        .fixedSize()
    }
}

struct SquareToolbarTrailingView: View {
    @Environment(\.theme) private var theme
    @Binding var selectedTopTab: Int
    @State private var isEditView = false
    let topTabs: [TabItem]
    
    var body: some View {
        Button(action: {
            isEditView.toggle()
        }, label: {
            TopBarLeftItemButtonView(image: "add_icon")
        })
        .fullScreenCover(isPresented: $isEditView, onDismiss: nil) {
            DemoContentView(isEditView: $isEditView)
             .interactiveDismissDisabled()
        }
        .sensoryFeedback(.impact(weight: .heavy), trigger: isEditView)
    }
}
