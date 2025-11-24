//
//  PropertyImageCarousel.swift
//  Real Estate
//
//  Created by Rion on 13.11.25.
//

import SwiftUI
import Foundation


struct PropertyImageCarousel: View {
    let imageURLs: [String]
    @State private var selectedImage: String?

    var body: some View {
        TabView {
            ForEach(imageURLs, id: \.self) { url in
                AsyncImage(url: URL(string: url)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .onTapGesture {
                            selectedImage = url
                        }
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 300)
                .clipped()
            }
        }
        .tabViewStyle(.page)
        .sheet(isPresented: .constant(selectedImage != nil)) { 
            if let image = selectedImage{
                FullScreenImageView(imageURL: image)
            }
        }
    
        }
    }
