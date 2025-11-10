//
//  PropertyAddView.swift
//  RealEstateApp Realm
//
//  Created by Rion on 23.10.25.
//
import SwiftUI
import _PhotosUI_SwiftUI

enum PropertyTyppe: String, CaseIterable, Identifiable {
    case house = "House"
    case apartment = "Apartment"
    case garage = "Garage"
    case land = "Land"
    case office = "Office"

    var id: String { self.rawValue }
}



struct AddPropertyView: View {
    @ObservedObject var viewModel: PropertyViewModel
    @Environment(\.dismiss) var dismiss

    // MARK: - Property Fields
    @State private var title = ""
    @State private var location = ""
    @State private var price = ""
    @State private var description = ""
    
    @State private var selectedType: PropertyType = .house
    @State private var listingType: ListingType = .rent     // ✅ New: Rent or Sale
    @State private var size: String = ""                    // ✅ New: m²
    @State private var selectedAmenities: Set<String> = []  // ✅ New: amenities

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImageData: [Data] = []

    let amenitiesOptions = [
        "WiFi",
        "Balcony",
        "Parking",
        "Pool",
        "Garage",
        "Garden",
        "Elevator",
        "Fireplace",
        "A/C",
        "Heating",
        "Furnished",
        "Wheelchair Accessible",
        "Pet Friendly",
        "Terrace",
        "Security System",
        "Gym",
        "Sauna",
        "Storage Room",
        "Sea View",
        "Mountain View"
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 15) {
                    // MARK: - Basic TextFields
                    TextField("Title", text: $title)
                        .textFieldStyle(.roundedBorder)

                    TextField("Location", text: $location)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()

                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()

                    TextField("Size (m²)", text: $size)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()

                    TextField("Description", text: $description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 80)
                        .autocorrectionDisabled()

                    // MARK: - Property Type Picker
                    Picker("Select Property Type", selection: $selectedType) {
                        ForEach(PropertyType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.vertical, 8)

                  
                    Picker("Listing Type", selection: $listingType) {
                        ForEach(ListingType.allCases) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 8)

                   
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amenities").font(.headline)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 10) {
                            ForEach(amenitiesOptions, id: \.self) { amenity in
                                Button(action: {
                                    if selectedAmenities.contains(amenity) {
                                        selectedAmenities.remove(amenity)
                                    } else {
                                        selectedAmenities.insert(amenity)
                                    }
                                }) {
                                    Text(amenity)
                                        .font(.caption)
                                        .padding(8)
                                        .frame(maxWidth: .infinity)
                                        .background(selectedAmenities.contains(amenity) ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedAmenities.contains(amenity) ? .white : .black)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding(.vertical)

            
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Images").font(.headline)

                        PhotosPicker(
                            selection: $selectedPhotos,
                            maxSelectionCount: 5,
                            matching: .images
                        ) {
                            Label("Select Photos", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                        .onChange(of: selectedPhotos) { newItems in
                            Task {
                                selectedImageData.removeAll()
                                for item in newItems {
                                    if let data = try? await item.loadTransferable(type: Data.self) {
                                        selectedImageData.append(data)
                                    }
                                }
                            }
                        }

                        if !selectedImageData.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(selectedImageData, id: \.self) { data in
                                        if let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 120, height: 120)
                                                .clipped()
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                    }
                    .padding(.horizontal)

                    
                    Button(action: addProperty) {
                        Text("Add Property")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Add Property")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Add Property Function
    private func addProperty() {
        guard !title.isEmpty, !location.isEmpty, !price.isEmpty, !size.isEmpty else { return }

        let cleanPrice = price.replacingOccurrences(of: ",", with: "")
        if let priceValue = Double(cleanPrice), let sizeValue = Int(size) {
            let base64Images = selectedImageData
                .map { $0.base64EncodedString() }
                .joined(separator: ",")

            viewModel.addProperty(
                title: title,
                location: location,
                price: priceValue,
                descriptionText: description,
                imageBase64: base64Images,
                propertyType: selectedType.rawValue,
                listingType: listingType.rawValue,
                size: sizeValue,
                amenities: Array(selectedAmenities)       
            )
            dismiss()
        }
    }
}

// MARK: - Supporting Enums
enum ListingType: String, CaseIterable, Identifiable {
    case rent, sale
    var id: String { rawValue }
}
