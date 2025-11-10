//
//  PropertyCardView.swift
//  RealEstateApp Realm
//
//  Created by Rion on 23.10.25.
//

import SwiftUI
import _PhotosUI_SwiftUI

import SwiftUI
import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct OnboardingView: View {
    @ObservedObject var auth: AuthViewModel
    @State private var isNavigatingToLogin = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background image
                Image("istockphoto-1696781145-612x612")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Floating white card
                    VStack(spacing: 24) {
                        Text("Find a Comfortable Place For You")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                        
                        Text("Browse listings or log in to save and post your own properties.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 25)
                        
                        // Login / Sign Up Button
                        NavigationLink(destination: LoginView(auth: auth),
                                       isActive: $isNavigatingToLogin) {
                            Button(action: {
                                isNavigatingToLogin = true
                            }) {
                                Text("Login / Sign Up")
                                    .fontWeight(.semibold)
                                    .frame(width: 260)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }
                        }
                        
                        // Continue as Guest Button
                        Button(action: {
                            auth.continueAsGuest()
                        }) {
                            Text("Continue as Guest")
                                .fontWeight(.semibold)
                                .frame(width: 260)
                                .padding()
                                .background(
                                    LinearGradient(colors: [.cyan, .pink.opacity(0.7)],
                                                   startPoint: .leading,
                                                   endPoint: .trailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                    }
                    .padding(.vertical, 40)
                    .frame(maxWidth: 360)
                    .background(
                        Color.white
                            .cornerRadius(30)
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                    )
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Rounded corner shape helper
struct RoundedCorner: Shape {
    var radius: CGFloat = 25.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


struct PropertyCardView: View {
    
    var property: Property
    @ObservedObject var viewModel: PropertyViewModel
    @EnvironmentObject var auth: AuthViewModel        // ✅ Access auth status
    @State private var uiImage: UIImage?
    @State private var showingLoginAlert = false      // ✅ Alert state
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
           
            // ✅ Property image
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .clipped()
                  
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    
                    .onAppear {
                        if let firstBase64 = property.imageBase64.split(separator: ",").first,
                           let data = Data(base64Encoded: String(firstBase64)),
                           let decodedImage = UIImage(data: data) {
                            uiImage = decodedImage
                        }
                    }
            }
            
            // ✅ Property type badge
            Text(property.propertyType)
                .font(.caption)
                .bold()
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.85))
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(8)
            
            // ✅ Property details
            VStack(alignment: .leading, spacing: 8) {
                Text(property.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .truncationMode(.tail)
                           .frame(maxWidth: .infinity, alignment: .leading)
                          
                
                Text(property.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("€\(Int(property.price).formatted(.number))")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                if let sizeAmenity = property.amenities.first(where: { $0.contains("m2") }) {
                    Text(sizeAmenity)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
//                Text(property.descriptionText)
//                    .font(.caption)
//                    .foregroundColor(.gray)
//                    .lineLimit(2)
            }
            .padding([.horizontal, .bottom],10)
            .frame(maxWidth: .infinity)
            
            
            HStack {
                Spacer()
                Button(action: {
                    if auth.isGuest {
                        showingLoginAlert = true
                    } else {
                        viewModel.toggleFavorite(for: property)
                        print("After toggle:", property.isFavorite)
                    }
                }) {
                    Image(systemName: property.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                .alert("Please log in to save favorites", isPresented: $showingLoginAlert) {
                    Button("Login") {
                        auth.logout()
                    }
                    Button("Cancel", role: .cancel) { }
                }
            }
            .padding([.horizontal, .bottom])
        }
        .frame(maxWidth: 350)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

#Preview{
    OnboardingView(auth: AuthViewModel())
}
