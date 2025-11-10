//
//  LoginView.swift
//  EventPlannerApp
//
//  Created by Rion on 22.10.25.
//

import SwiftUI

import SwiftUI

struct AuthBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.blue.opacity(0.7),
                Color.purple.opacity(0.6)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct GlassCard<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(25)
            .shadow(radius: 15)
            .padding(.horizontal, 25)
    }
}
struct LoginView: View {
    @ObservedObject var auth: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showRecover = false
    @Namespace private var animation
    
    var body: some View {
        ZStack {
            AuthBackground()
            
            VStack(spacing: 30) {
                Text("Event Planner")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 10)
                    .padding(.top, 60)
                
                GlassCard {
                    VStack(spacing: 20) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                        
                        Button(action: {
                            _ = auth.login(email: email, password: password)
                        }) {
                            Text("Log In")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        if !auth.errorMessage.isEmpty {
                            Text(auth.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        Button("Forgot Password?") {
                            showRecover = true
                        }
                        .font(.footnote)
                        .foregroundColor(.blue.opacity(0.8))
                        .sheet(isPresented: $showRecover) {
                            RecoverPasswordView(auth: auth)
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    Text("Don’t have an account?")
                        .foregroundColor(.white)
                    Button("Sign Up") {
                        showRegister = true
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.yellow)
                    .sheet(isPresented: $showRegister) {
                        RegisterView(auth: auth)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}


#Preview {
    LoginView(auth: AuthViewModel())
}
