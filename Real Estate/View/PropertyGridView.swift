//
//  PropertyGridView.swift
//  Real Estate
//
//  Created by Rion on 10.11.25.
//

import SwiftUI


struct PropertySelectGridView: View {
    @ObservedObject var viewModel: PropertyViewModel
    @State private var isComparing = false
    @State private var selectedProperties: [Property] = []
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Header
                HStack {
                    Text("Select Properties")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button(isComparing ? "Cancel" : "Compare") {
                        withAnimation {
                            isComparing.toggle()
                            selectedProperties.removeAll()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(isComparing ? .red : .blue)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Property Grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(viewModel.properties) { property in
                            SelectablePropertyCardView(
                                property: property,
                                isSelected: selectedProperties.contains(where: { $0.id == property.id }),
                                isComparing: isComparing
                            ) {
                                toggleSelection(property)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                
                
                if isComparing && selectedProperties.count >= 2 {
                    NavigationLink(destination: PropertyComparisonView(properties: selectedProperties)) {
                        Text("Compare \(selectedProperties.count) Properties")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 2)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom))
                }
            }
            .navigationTitle("Compare Properties")
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // MARK: - Selection Logic
    private func toggleSelection(_ property: Property) {
        if let index = selectedProperties.firstIndex(where: { $0.id == property.id }) {
            selectedProperties.remove(at: index)
        } else if selectedProperties.count < 3 {
            selectedProperties.append(property)
        }
    }
}

struct PropertyyComparisonView: View {
    let properties: [Property]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(properties) { property in
                    VStack(alignment: .leading, spacing: 15) {
                        if let imageData = Data(base64Encoded: property.imageBase64),
                           let image = UIImage(data: imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 140)
                                .clipped()
                                .cornerRadius(12)
                        }

                        Text(property.title)
                            .font(.headline)

                        Text("💶 \(Int(property.price)) €")
                        Text("📍 \(property.location)")
                        Text("📐 \(property.size, specifier: "%.0f") m²")

                        VStack(alignment: .leading) {
                            Text("🧰 Amenities:")
                                .font(.subheadline)
                                .bold()
                            ForEach(property.amenities, id: \.self) { amenity in
                                Text("• \(amenity)")
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 3)
                }
            }
            .padding()
        }
        .navigationTitle("Compare Properties")
    }
}


struct SelectablePropertyCardView: View {
    var property: Property
    var isSelected: Bool
    var isComparing: Bool
    var toggleSelection: () -> Void

    // MARK: - Decode Base64 image safely
    private var decodedImage: UIImage? {
        var base64String = property.imageBase64.trimmingCharacters(in: .whitespacesAndNewlines)
        if let range = base64String.range(of: "base64,") {
            base64String = String(base64String[range.upperBound...])
        }
        guard let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Property Image (Top)
            if let uiImage = decodedImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(16, corners: [.topLeft, .topRight])
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 150)
                    .overlay(
                        Image(systemName: "house.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    )
                    .cornerRadius(16, corners: [.topLeft, .topRight])
            }

            // MARK: - Info Section (Below Image)
            VStack(alignment: .leading, spacing: 6) {
                Text(property.title)
                    .font(.headline)
                    .frame(maxWidth:.infinity)
                    .lineLimit(2)
                Text(property.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                Text("€\(property.price, specifier: "%.0f")")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            // MARK: - Selection Button (Bottom)
            if isComparing {
                Button(action: toggleSelection) {
                    HStack {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .blue : .gray)
                        Text(isSelected ? "Selected" : "Select")
                            .font(.subheadline)
                            .foregroundColor(isSelected ? .blue : .gray)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
    }
}


