//
//  PawPalApp.swift
//  PawPal
//
//  Created by Moe Karaki on 7/18/25.
//
import SwiftUI
import Firebase

@main
struct PawPalApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea() // fills the entire screen, notch to home bar
                NavigationStack {
                    WelcomeView()
                    VCInspector()
                }
            }
        }
    }
}

struct VCInspector: View {
    var body: some View {
        Color.clear.onAppear {
            for scene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
                for w in scene.windows {
                    let r = w.rootViewController
                    print("WINDOW corner:", w.layer.cornerRadius, "clips:", w.clipsToBounds)
                    print("ROOT:", type(of: r ?? UIViewController()),
                          "modal:", r?.modalPresentationStyle.rawValue ?? -9,
                          "view.corner:", r?.view.layer.cornerRadius ?? -1,
                          "clips:", r?.view.clipsToBounds ?? false)
                    if let p = r?.presentedViewController {
                        print("PRESENTED:", type(of: p), "modal:", p.modalPresentationStyle.rawValue,
                              "view.corner:", p.view.layer.cornerRadius)
                    }
                }
            }
        }
    }
}
