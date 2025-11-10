//
//  PropertyItemView.swift
//  RealEstateApp Realm
//
//  Created by Rion on 23.10.25.
//

import SwiftUI

struct PropertyDetailView: View {
    
    var property: Property
    @EnvironmentObject var auth: AuthViewModel
    @ObservedObject var viewModel: PropertyViewModel
    @State private var showingLoginAlert = false
    var updatedProperty: Property? {
        viewModel.properties.first(where: { $0.id == property.id })
    }
    let rows = [
            GridItem(.fixed(50)),
            GridItem(.fixed(50))
        ]
    
    let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    
    private var decodedImages: [UIImage] {
        let imageStrings = property.imageBase64.split(separator: ",").map(String.init)
        return imageStrings.compactMap { imgStr in
            let cleanStr: String
            if let range = imgStr.range(of: "base64,") {
                cleanStr = String(imgStr[range.upperBound...])
            } else {
                cleanStr = imgStr
            }
            
            if let data = Data(base64Encoded: cleanStr),
               let image = UIImage(data: data) {
                return image
            } else {
                print("❌ Failed to decode one of the Base64 images")
                return nil
            }
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if !decodedImages.isEmpty {
                    TabView {
                        ForEach(decodedImages, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: 250)
                                .clipped()
                                .shadow(radius: 4)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(height: 250)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 250)
                        .cornerRadius(12)
                        .overlay(
                            Text("No Image")
                                .foregroundColor(.gray)
                        )
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text(property.propertyType)
                        .font(.caption)
                        .bold()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(8)
                    
                    Text(property.title)
                        .font(.title)
                        .bold()
                    
                    Text(property.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("€\(priceFormatter.string(from: NSNumber(value: property.price)) ?? "0")")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Text(property.descriptionText)
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
                .padding(.horizontal)
                VStack(spacing: 12) {
                    InfoCard(title: "Type", value: property.propertyType, icon: "house.fill")
                    InfoCard(title: "Size", value: "\(property.size) m²", icon: "ruler")
                    
                    // MARK: - Amenities Grid
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amenities")
                            .font(.subheadline)
                            .lineLimit(1)
                            .bold()
                            .padding(.horizontal)
                        
                        // Define two columns
                        let columns: [GridItem] = [
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)
                        ]
                        
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(Array(property.amenities), id: \.self) { amenity in
                                Text(amenity)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.15))
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("Property Details")
                .navigationBarTitleDisplayMode(.inline)
                
            }
        }
    }
}

struct InfoCard: View {
    var title: String
    var value: String
    var icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
            Text(value.isEmpty ? "—" : value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 90)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
}
