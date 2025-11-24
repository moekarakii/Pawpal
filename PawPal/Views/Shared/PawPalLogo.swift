//
//  PawPalLogo.swift
//  PawPal
//
//  Created by GitHub Copilot on 11/23/25.
//

import SwiftUI

struct PawPalLogo: View {
    let size: CGFloat
    let showText: Bool
    
    init(size: CGFloat = 120, showText: Bool = true) {
        self.size = size
        self.showText = showText
    }
    
    var body: some View {
        VStack(spacing: showText ? 12 : 0) {
            ZStack {
                // Background circle with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                // Paw prints
                VStack(spacing: -8) {
                    HStack(spacing: 8) {
                        PawPrint(size: size * 0.15)
                        PawPrint(size: size * 0.18)
                    }
                    .offset(y: -size * 0.1)
                    
                    HStack(spacing: 12) {
                        PawPrint(size: size * 0.16)
                        PawPrint(size: size * 0.17)
                    }
                    .offset(y: size * 0.05)
                }
            }
            
            if showText {
                VStack(spacing: 4) {
                    Text("PawPal")
                        .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Reuniting Hearts & Paws")
                        .font(.system(size: size * 0.12, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

struct PawPrint: View {
    let size: CGFloat
    
    var body: some View {
        VStack(spacing: size * 0.1) {
            // Toe pads
            HStack(spacing: size * 0.15) {
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.3, height: size * 0.4)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.35, height: size * 0.45)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: size * 0.3, height: size * 0.4)
            }
            
            // Main pad
            Ellipse()
                .fill(Color.white)
                .frame(width: size * 0.6, height: size * 0.5)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 30) {
        PawPalLogo(size: 120, showText: true)
        PawPalLogo(size: 80, showText: false)
        PawPalLogo(size: 60, showText: true)
    }
    .padding()
}