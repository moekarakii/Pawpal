//
//  CommunityPost.swift
//  PawPal
//
//  Created by Moe Karaki on 7/18/25.
//
import Foundation

struct CommunityPost: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let comments: Int
    let reactions: Int
}
