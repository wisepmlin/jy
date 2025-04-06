//
//  Friend.swift
//  jy
//
//  Created by 林晓彬 on 2025/2/16.
//
import SwiftUI

struct Friend: Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var avatar: String
}

struct ShareType: Identifiable, Equatable {
    var id: UUID = UUID()
    var type: String
    var title: String
    var image: String
}
