//
//  CommunityPostRow.swift
//  PawPal
//
//  Created by Moe Karaki on 7/18/25.
//

import SwiftUI

struct CommunityPostRow: View {
    let post: CommunityPost

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(post.title)
                .font(.headline)

            Text(post.description)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Label("\(post.comments)", systemImage: "text.bubble")
                Label("\(post.reactions)", systemImage: "hand.thumbsup")

                Spacer()
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding(.vertical, 8)
    }
}
