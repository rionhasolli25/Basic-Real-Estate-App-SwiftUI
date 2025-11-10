//
//  PropertyView.swift
//  EventPlannerApp
//
//  Created by Rion on 22.10.25.
//

import SwiftUI
import SwiftUI
import _PhotosUI_SwiftUI

import SwiftUI

// MARK: - Property List View
struct PropertyListView: View {
    @StateObject private var viewModel = PropertyViewModel()
    @State private var showAddProperty = false
    @State private var showFilter = false
    @State private var showFavoritesOnly = false
    @State private var showProfile = false

    var body: some View {
        NavigationView {
            ZStack{
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.4),Color.green.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                VStack{
                    // MARK: - Buttons Section
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Filter Button
                            CustomActionButton(icon: "line.3.horizontal.decrease.circle.fill",
                                               title: "Filter Properties",
                                               color: .blue) {
                                showFilter.toggle()
                            }
                            
                            // Add Property Button
                            CustomActionButton(icon: "plus.circle.fill",
                                               title: "Add Property",
                                               color: .green) {
                                showAddProperty.toggle()
                            }
                            
                            // Favorites Toggle
                            CustomActionButton(icon: showFavoritesOnly ? "heart.fill" : "heart",
                                               title: showFavoritesOnly ? "Favorites On" : "Show Favorites",
                                               color: .red) {
                                showFavoritesOnly.toggle()
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    // MARK: - Property List
                    ScrollView {
                        let listToShow = showFavoritesOnly ? viewModel.favoruiteProperties : viewModel.filteredProperties
                        
                        if listToShow.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "house.slash.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No properties found")
                                    .foregroundColor(.gray)
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity, minHeight: 400)
                        } else {
                            LazyVStack(spacing: 16) {
                                ForEach(listToShow) { property in
                                    NavigationLink(destination: PropertyDetailView(property: property, viewModel: viewModel)) {
                                        PropertyCardView(property: property, viewModel: viewModel)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                        }
                    }
                }
                .navigationTitle("🏡 Properties")
                .sheet(isPresented: $showAddProperty) {
                    AddPropertyView(viewModel: viewModel)
                }
                .sheet(isPresented: $showFilter) {
                    FilterView(viewModel: viewModel)
                }
                .sheet(isPresented: $showProfile) {
                    ProfileView()
                }
            }
        }
    }
}

// MARK: - Custom Button
struct CustomActionButton: View {
    var icon: String
    var title: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.headline)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(12)
            .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
        }
    }
}
import SwiftUI

// MARK: - Filter View
struct FilterView: View {
    @ObservedObject var viewModel: PropertyViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var tempMinPrice: Double = 0
    @State private var tempMaxPrice: Double = 1_000_000

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // MARK: - Price Range
                VStack(alignment: .leading, spacing: 12) {
                    Text("Price Range")
                        .font(.headline)
                    
                    Text("€\(Int(tempMinPrice)) - €\(Int(tempMaxPrice))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    RangeSlider(minValue: $tempMinPrice, maxValue: $tempMaxPrice, range: 0...1_000_000)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // MARK: - Property Type
                VStack(alignment: .leading, spacing: 12) {
                    Text("Property Type")
                        .font(.headline)
                    
                    Picker("Type", selection: $viewModel.selectedType) {
                        Text("Any").tag("")
                        ForEach(viewModel.propertyTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // MARK: - Location
                VStack(alignment: .leading, spacing: 12) {
                    Text("Location")
                        .font(.headline)
                    
                    Picker("Location", selection: $viewModel.selectedLocation) {
                        Text("Any").tag("")
                        ForEach(viewModel.locations, id: \.self) { loc in
                            Text(loc).tag(loc)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Filter Properties")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button("Clear Filters") {
                        viewModel.clearFilters()
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        viewModel.minPrice = tempMinPrice
                        viewModel.maxPrice = tempMaxPrice
                        viewModel.applyFilters()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            tempMinPrice = viewModel.minPrice
            tempMaxPrice = viewModel.maxPrice
        }
    }
}

// MARK: - Range Slider
struct RangeSlider: View {
    @Binding var minValue: Double
    @Binding var maxValue: Double
    let range: ClosedRange<Double>

    var body: some View {
        VStack(spacing: 12) {
            // Min Slider
            VStack {
                Slider(value: $minValue, in: range.lowerBound...(maxValue - 100), step: 100)
                Text("Min: €\(Int(minValue))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // Max Slider
            VStack {
                Slider(value: $maxValue, in: (minValue + 100)...range.upperBound, step: 100)
                Text("Max: €\(Int(maxValue))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    PropertyListView()
}
