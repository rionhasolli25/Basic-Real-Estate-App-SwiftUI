//
//  PropertyComparision.swift
//  Real Estate
//
//  Created by Rion on 10.11.25.
//
import SwiftUI

struct PropertyComparisonView: View {
    let properties: [Property]

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                ForEach(properties) { property in
                    VStack(alignment: .leading, spacing: 10) {
                        if let image = UIImage(data: Data(base64Encoded: property.imageBase64) ?? Data()) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 140)
                                .clipped()
                                .cornerRadius(12)
                        }
                        Text(property.title)
                            .font(.headline)
                        Text("💶 \(Int(property.price))")
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
