//
//  PropertyTypeView.swift
//  RealEstateApp
//
//  Created by Rion on 28.10.25.
//
import SwiftUI
import Foundation
import RealmSwift

enum PropertyType: String, CaseIterable, Identifiable {
    
    case house = "House"
    case apartment = "Apartment"
    case garage = "Garage"
    case office = "Office"
    case villa = "Villa"
    case studio = "Studio"

    var id: String { self.rawValue }

    var icon: String {
        switch self {
        case .house: return "house.fill"
        case .apartment: return "building.2.fill"
        case .garage: return "car.fill"
        case .office: return "briefcase.fill"
        case .villa: return "house.and.flag.fill"
        case .studio: return "bed.double.fill"
        }
    }
}

struct PropertyTypeSelectionView: View {
    @ObservedObject var viewModel: PropertyViewModel
    
    var body: some View {
        NavigationView {
            ZStack{
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.4),Color.green.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                VStack(alignment: .center, spacing: 12) {
                    Text("Select Property Type")
                        .font(.headline)
                        .padding(.leading, 4)
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(PropertyType.allCases) { type in
                                NavigationLink(destination: PropertyTypeListView(type: type, viewModel: viewModel)) {
                                    HStack(spacing: 12) {
                                        Image(systemName: type.icon)
                                            .font(.system(size: 22))
                                            .foregroundColor(.white)
                                            .frame(width: 40, height: 40)
                                            .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                                        Text(type.rawValue)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(radius: 2)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
        
            }
        }
    }
}

struct PropertyTypeListView: View {
    let type: PropertyType
    @ObservedObject var viewModel: PropertyViewModel

    var propertiesForType: [Property] {
        viewModel.properties.filter { $0.propertyType == type.rawValue }
    }

    var body: some View {
        ScrollView {
            if propertiesForType.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "house.slash.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.6))
                    Text("No \(type.rawValue) found")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, minHeight: 400)
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(propertiesForType) { property in
                        NavigationLink(destination: PropertyDetailView(property: property, viewModel: viewModel)) {
                            PropertyCardView(property: property, viewModel: viewModel)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(type.rawValue)
    }
}

