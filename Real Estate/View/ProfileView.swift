//
//  ProfileView.swift
//  RealEstateApp
//
//  Created by Rion on 28.10.25.
//

import SwiftUI
import PhotosUI
import Photos

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var profileImageData: Data?
    @State private var name: String = ""
      @State private var surname: String = ""
    @State private var email: String = ""
        @State private var phone: String = ""
        @State private var bio: String = ""
    
    var body: some View {
        NavigationView {
            ScrollView{
                ZStack{
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.4),Color.green.opacity(0.5)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    VStack(spacing: 30) {
                        // MARK: - Profile Image
                        if let data = profileImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                                .shadow(radius: 5)
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                        }
                        
                        // MARK: - User Info
                        VStack(spacing: 8) {
                            Text(auth.currentUser?.name ?? "Guest User")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text(auth.currentUser?.email ?? "No Email")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // MARK: - Photo Picker
                        PhotoPickerButton {
                            profileImageData = $0
                        }
                        
                        Group{
                            CustomProfileTextField(title: "Name", text: $name)
                            CustomProfileTextField(title: "Surname", text: $surname)
                            CustomProfileTextField(title: "Email", text: $email)
                            CustomProfileTextField(title: "Phone", text: $phone, keyboardType: UIKeyboardType.phonePad)
                            
                        }
                        
                        Spacer()
                        
                        // MARK: - Log Out
                        Button(action: {
                            auth.logout()
                        }) {
                            Text("Log Out")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                    .ignoresSafeArea(.all)
                    .padding(.bottom,30)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Close") { dismiss() }
                        }
                    }
                }
            }
        }
    }
}

struct PhotoPickerButton: View {
    var onImagePicked: (Data?) -> Void
    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            HStack {
                Image(systemName: "camera.fill")
                Text("Change Profile Picture")
            }
            .foregroundColor(.blue)
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    onImagePicked(data)
                }
            }
        }
    }
}

struct CustomProfileTextField : View {
    var title : String
    @Binding var text : String
    var keyboardType: UIKeyboardType = .default
      
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                TextField(title, text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.25))
                    .cornerRadius(8)
                    .keyboardType(keyboardType)
                    .font(.body)
            }
        }
    }
}

#Preview {
    ProfileView()
}
