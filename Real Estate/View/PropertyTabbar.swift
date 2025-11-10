////
////  PropertyTabbar.swift
////  RealEstateApp Realm
////
////  Created by Rion on 23.10.25.
////
//
import Foundation
import SwiftUI

struct FavoritesView: View {
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
                ScrollView {
                    let listToShow = viewModel.favoriteProperties
                    
                    if listToShow.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "heart.slash.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.6))
                            Text("No favorites yet")
                                .foregroundColor(.gray)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 400)
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(listToShow) { property in
                                NavigationLink(destination: PropertyDetailView(property: property, viewModel: viewModel)) {
                                    PropertyCardSimpleView(property: property,viewModel: viewModel)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .navigationTitle("Favorites")
                .onAppear {
                    viewModel.loadProperties()
                }
            }
        }
    }
}
struct RentView: View {
    @ObservedObject var viewModel: PropertyViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.3),
                        Color.cyan.opacity(0.4),
                        Color.green.opacity(0.5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    // ✅ Filter properties to show only rentals
                    let listToShow = viewModel.properties.filter {
                        $0.listingType.lowercased() == "rent"
                    }
                    
                    // ✅ Optional: display first listing type (debug / visual)
                    if let firstProperty = listToShow.first {
                        Text("First listing type: \(firstProperty.listingType)")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top)
                    }
                    
                    // ✅ Empty state
                    if listToShow.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "house.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.6))
                            Text("No rental properties available")
                                .foregroundColor(.gray)
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, minHeight: 400)
                    }
                    // ✅ Property list
                    else {
                        LazyVStack(spacing: 16) {
                            ForEach(listToShow) { property in
                                NavigationLink(destination: PropertyDetailView(property: property, viewModel: viewModel)) {
                                    PropertyCardSimpleView(property: property, viewModel: viewModel)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
                .navigationTitle("Rentals")
                .onAppear {
                    // ✅ Load properties and print for debugging
                    viewModel.loadProperties()
                    
                    if let firstProperty = viewModel.properties.first {
                        print("First property listing type: \(firstProperty.listingType)")
                    }
                }
            }
        }
    }
}


// MARK: - Main Tab View
struct MainTabView: View {
    @StateObject private var viewModel = PropertyViewModel()
    @EnvironmentObject var auth: AuthViewModel
    @State private var showAddProperty = false
    @State private var showFilter = false

    var body: some View {
        TabView {
            // Always visible tabs
            PropertyListView()
                .environmentObject(viewModel)
                .tabItem {
                    Label("All", systemImage: "house.fill")
                }

            PropertyTypeSelectionView(viewModel: viewModel)
                .tabItem {
                    Label("Property Type", systemImage: "building")
                }

            PropertyGridView(viewModel: viewModel)
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
            if !auth.isGuest{
                ChatListView(currentUserID: "user123")
                    .tabItem {
                        Label("Chats", systemImage: "message.fill")
                    }
            } else {
                    Text("Sign in to chat with")
                        .tabItem {
                            Label("Chats", systemImage: "message.fill")
                        }
                }

            // Show Profile tab only if user is NOT a guest
            if !auth.isGuest {
                MoreView()
                    .tabItem {
                        Label("More", systemImage: "ellipsis")
                    }
            } else {
                // Show Guest version of MoreView
                GuestMoreView(auth: auth)
                    .tabItem {
                        Label("More", systemImage: "ellipsis")
                    }
                

            }
        }
    }
}

// MARK: - Regular More View (for signed-in users)
struct MoreView: View {
    @StateObject private var viewModel = PropertyViewModel()
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Mortgage Calculator") {
                    MortgageCalculatorView()
                }
                NavigationLink("Profile") {
                    ProfileView()
                }
                NavigationLink("Rent") {
                    RentView(viewModel: PropertyViewModel())
                }
                NavigationLink("Favourites") {
                    FavoritesView(viewModel: PropertyViewModel())
                }
                NavigationLink("Select"){
                    PropertySelectGridView(viewModel: PropertyViewModel())
                }
            }
            .navigationTitle("More")
        }
    }
}

// MARK: - Guest More View (for guest users)
struct GuestMoreView: View {
    @ObservedObject var auth: AuthViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("You're browsing as a guest.")
                .font(.headline)
                .padding(.top, 50)
            
            Text("Sign in or create an account to save favourites, post properties, and more!")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            Button(action: {
                auth.signOutGuest()
            }) {
                Text("Sign In / Sign Up")
                    .fontWeight(.semibold)
                    .frame(width: 220)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            Spacer()
        }
    }
}

struct SearchBarView: View {
    @Binding var searchText: String
    var onFilterTap: () -> Void
    
    var body: some View {
        HStack {
            // TextField for search input
            TextField("City, zip code or address", text: $searchText)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(30)
                .overlay(
                    HStack {
                        Spacer()
                        Button(action: onFilterTap) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(.gray)
                                .padding(.trailing, 15)
                        }
                    }
                )
            
            // Search button (green circle with magnifying glass)
            Button(action: {
                print("Search tapped for: \(searchText)")
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.green)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal)
    }
}


enum PropetyFilter : String, CaseIterable, Identifiable{
    case all = "All"
    case highPrice = "High Price"
    case lowPrice = "Low Price"
    case house = "House"
    case apartment = "Apartment"
    case rent = "Rent"
    case sale = "Sale"
  
    var id: String { rawValue }
}

struct PropertyGridView: View {
    @ObservedObject var viewModel: PropertyViewModel
    @State private var selectedFilter: PropetyFilter = .all
    @State private var searchText: String = ""
    @State private var selectedPropertyType: PropertyType? = nil
    @State private var sortByPriceHighToLow: Bool = false
    @State private var showFilterSheet = false

    private let columns = [
        GridItem(.flexible(minimum: 150, maximum: 180), spacing: 15),
        GridItem(.flexible(minimum: 150, maximum: 180), spacing: 15)
        
    ]
    
    var filteredProperties: [Property] {
        switch selectedFilter {
        case .all:
            return viewModel.properties
        case .highPrice:
            return viewModel.properties.sorted(by: { $0.price > $1.price })
        case .lowPrice:
            return viewModel.properties.sorted(by: {$0.price < $1.price })
        case .house:
            return viewModel.properties.filter { $0.propertyType.lowercased() == "house" }
        case .apartment:
            return viewModel.properties.filter { $0.propertyType.lowercased() == "apartment" }
        case .rent:
            return viewModel.properties.filter { $0.listingType == "rent" }
        case .sale:
            return viewModel.properties.filter { $0.listingType == "sale" }
            
        }
    }
    
    private var filteredsearchProperties: [Property] {
          var props = viewModel.properties
          if !searchText.isEmpty {
              props = props.filter { property in
                  property.title.localizedCaseInsensitiveContains(searchText) ||
                  property.location.localizedCaseInsensitiveContains(searchText)
              }
          }
        
          if let type = selectedPropertyType {
              props = props.filter { $0.propertyType == type.rawValue }
          }
          
          if sortByPriceHighToLow {
              props.sort { $0.price > $1.price }
          }
          
          return props
      }
    var body: some View {
        NavigationView{
            ZStack {
                
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.4),Color.green.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack{
          
                // ✅ Custom Search Bar with Filter Button
                        SearchBarView(searchText: $searchText) {
                                showFilterSheet.toggle() // opens sheet
                    }
                .padding(.top)

                           
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(PropetyFilter.allCases) { filter in
                            Button(action: {
                                selectedFilter = filter
                            }) {
                                Text(filter.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        selectedFilter == filter
                                        ? Color.blue.opacity(0.9)
                                        : Color.gray.opacity(0.15)
                                    )
                                    .foregroundColor(selectedFilter == filter ? .white : .black)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal,30)
                    .padding(.vertical, 8)
                }
                
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredProperties) { property in
                            NavigationLink(destination: PropertyDetailView(property: property, viewModel: viewModel)) {
                                PropertyGridCard(property: property, viewModel: viewModel)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("🏠 Properties")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showFilterSheet) {
                            FilterSheetView(selectedFilter: $selectedFilter)
                        }
        }
    }
}
    struct FilterSheetView: View {
        @Binding var selectedFilter: PropetyFilter
        @Environment(\.dismiss) var dismiss
        
        var body: some View {
            NavigationView {
                List {
                    ForEach(PropetyFilter.allCases) { filter in
                        HStack {
                            Text(filter.rawValue)
                            Spacer()
                            if selectedFilter == filter {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedFilter = filter
                            dismiss()
                        }
                    }
                }
                .navigationTitle("Filter Properties")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct PropertyGridCard: View {
    var property: Property
    @ObservedObject var viewModel: PropertyViewModel
    @State private var uiImage: UIImage?

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topLeading) {
                
          
                if let uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(height: 110)
                        .clipped()
                        .cornerRadius(10)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 110)
                        .cornerRadius(10)
                        .onAppear {
                            if let firstBase64 = property.imageBase64.split(separator: ",").first,
                               let data = Data(base64Encoded: String(firstBase64)),
                               let decodedImage = UIImage(data: data) {
                                uiImage = decodedImage
                            }
                        }
                }
                HStack(spacing:15){
                    Text(property.propertyType)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        
                        .background(Color.blue.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                        .padding(6)
                    
                    Text(property.listingType)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.green.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                        .padding(6)
                }
            }

            VStack(spacing: 4) {
                Text(property.title)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text(property.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                Text("€\(Int(property.price).formatted(.number))")
                    .font(.headline)
                    .foregroundColor(.blue)
            }

            Button(action: {
                viewModel.toggleFavorite(for: property)
            }) {
                Image(systemName: property.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(.red)
                    .font(.system(size: 18))
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        )
    }
}

struct PropertyCardSimpleView: View {
    
    let property: Property
    var viewModel: PropertyViewModel
    @State private var uiImage: UIImage?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(12)
                    .onAppear {
                        if let firstBase64 = property.imageBase64.split(separator: ",").first,
                           let data = Data(base64Encoded: String(firstBase64)),
                           let decodedImage = UIImage(data: data) {
                            uiImage = decodedImage
                        }
                    }
            }
            VStack(alignment: .leading, spacing: 6){
              
                Text(property.title)
                    .font(.headline)
                    .lineLimit(1)
                
                
                Text(property.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
             
                Text("€\(Int(property.price))")
                    .font(.subheadline)
                    .bold()
            }
        }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
            }
         
    }


