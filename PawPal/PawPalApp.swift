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

    @StateObject private var locationManager = LocationManager()
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()

                // 1. Firebase is still checking for an existing session
                if authVM.isLoading {
                    LoadingView()
                }

                // 2. Not logged in = show Welcome
                else if authVM.user == nil {
                    NavigationStack {
                        WelcomeView()
                    }
                    .environmentObject(locationManager)
                }

                // 3. Logged in = show MainTabView
                else {
                    MainTabView()
                        .environmentObject(locationManager)
                }
            }
            .task {
                locationManager.requestLocationPermission()
            }
            // injecting authVM to whole application (Needed for other views to see/use the AuthViewModel)
            .environmentObject(authVM)
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
