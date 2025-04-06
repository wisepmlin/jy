import SwiftUI

struct TopBarLeftItemButtonView: View {
    @Environment(\.theme) private var theme
    var image: String
    
    var body: some View {
        Image(image)
            .resizable()
            .frame(width: 14, height: 14)
            .opacity(0.75)
            .padding(8)
            .background(.bar)
            .compositingGroup()
            .cornerRadius(16)
    }
}
