//
//  ContentView.swift
//  Real Estate
//
//  Created by Rion on 31.10.25.
//

import SwiftUI


struct RootView: View {
    @StateObject var auth = AuthViewModel()
    
    var body: some View {
        Group {
            if auth.currentUser == nil && !auth.isGuest {
                OnboardingView(auth: auth)
            } else {
                MainTabView()
                    .environmentObject(auth)
            }
        }
    }
}
#Preview {
    RootView()
}
