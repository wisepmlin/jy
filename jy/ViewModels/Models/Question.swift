import Foundation

struct Question: Identifiable, Equatable, Hashable {
    let id = UUID()
    let index: Int
    let title: String
    let answer: String?
    
    static func == (lhs: Question, rhs: Question) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
} 
