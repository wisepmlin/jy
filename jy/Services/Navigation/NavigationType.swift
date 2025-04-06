import SwiftUI

enum NavigationType: Hashable {
    case news(title: String)
    case hotTopic(topic: String)
    case article(id: String)
    case qa(id: String)
    case profile(userId: String)
    case home
    case search
}
