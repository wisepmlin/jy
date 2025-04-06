//
//  Tool.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/12.
//
import SwiftUI

struct Tool: Identifiable, Equatable, Hashable {
    let id = UUID()
    let iconName: String
    let name: String
    let description: String
    let category: String
    let isPopular: Bool
    
    static func == (lhs: Tool, rhs: Tool) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
