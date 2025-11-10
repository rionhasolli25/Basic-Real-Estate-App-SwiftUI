//
//  RecoverPasswordView.swift
//  EventPlannerApp
//
//  Created by Rion on 22.10.25.
//

import SwiftUI

struct RegisterView: View {
    @ObservedObject var auth: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        ZStack {
            AuthBackground()
            
            VStack(spacing: 30) {
                Text("Create Account")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.top, 60)
                
                GlassCard {
                    VStack(spacing: 20) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(.roundedBorder)
                        
                        SecureField("Confirm Password", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                        
                        Button(action: {
                            guard password == confirmPassword else {
                                auth.errorMessage = "Passwords do not match"
                                return
                            }
                            auth.register(username: username,email: email, password: password)
                        }) {
                            Text("Register")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        if !auth.errorMessage.isEmpty {
                            Text(auth.errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
                
                Button("Back to Login") {
                    dismiss()
                }
                .foregroundColor(.white)
                .fontWeight(.medium)
                .padding(.bottom, 30)
            }
        }
    }
}

struct RecoverPasswordView: View {
    
    @ObservedObject var auth: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var newPassword = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Reset Password")
                    .font(.title)
                    .bold()
                
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                SecureField("New Password", text: $newPassword)
                    .textFieldStyle(.roundedBorder)
                
                Button("Reset Password") {
                    if auth.resetPassword(email: email, newPassword: newPassword) {
                        dismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                if !auth.errorMessage.isEmpty {
                    Text(auth.errorMessage)
                        .foregroundColor(.red)
                }
            }
            .padding()
        }
    }
}


#Preview {
    RegisterView(auth: AuthViewModel())
}
