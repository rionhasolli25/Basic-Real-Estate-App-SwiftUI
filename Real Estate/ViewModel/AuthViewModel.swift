//
//  AuthViewModel.swift
//  RealEstateApp Realm
//
//  Created by Rion on 22.10.25.
//
import Foundation
import SwiftUI
import RealmSwift
import Foundation
import RealmSwift
import SwiftUI

class PropertyViewModel: ObservableObject {
    
    private var realm: Realm
    @Published var properties: [Property] = []
    @Published var allProperties : [Property] = []
    @Published var filteredProperties: [Property] = []
    @Published var minPrice: Double = 0
    @Published var maxPrice: Double = 10000
    @Published var selectedType: String = "All"
    @Published var selectedLocation: String = "All"
    private var notificationToken: NotificationToken?
    @Published var filtersApplied = false
       
    
    var propertyTypes = ["All", "Apartment", "House", "Villa", "Studio"]
    @Published var availableAmenities = ["WiFi", "Balcony", "Parking", "Pool", "Garden"]
    var locations: [String] {
        let all = Set(properties.map { $0.location })
        return ["All"] + all.sorted()
    }
    
    var favoriteProperties: [Property] {
        properties.filter { $0.isFavorite }
    }
   
 //   @Published var fillteredProperties: [Property] = []
    
    func applyFilterss() {
        filteredProperties = properties
    }
    var favoruiteProperties : [Property]{
        properties.filter{ $0.isFavorite}
    }
    init() {
        realm = try! Realm()
        fetchProperties()
        observeProperties()
    }
    func loadProperties() {
            properties = Array(realm.objects(Property.self))
        }
        
    func toggleFavorites(for property: Property) {
        if let index = properties.firstIndex(where: { $0.id == property.id }) {
            properties[index].isFavorite.toggle()
        }
    }
    var filtereDProperties: [Property] {
          guard filtersApplied else { return Array(allProperties) }
          
          return allProperties.filter { property in
              property.price >= minPrice &&
              property.price <= maxPrice &&
              (selectedType.isEmpty || property.propertyType == selectedType) &&
              (selectedLocation.isEmpty || property.location == selectedLocation)
          }
      }
      

    func toggleFavorite(for property: Property) {
           do {
               if let object = realm.object(ofType: Property.self, forPrimaryKey: property.id) {
                   try realm.write {
                       object.isFavorite.toggle()
                   }
                   fetchProperties()
                        
               }
           } catch {
               print("Error toggling favorite: \(error.localizedDescription)")
           }
       }
       
       // MARK: - Load Only Favorites
       func loadFavorites() {
           properties = Array(realm.objects(Property.self).filter("isFavorite == true"))
       }
    
    func applyFilters() {
        filteredProperties = properties.filter { property in
            let matchesType = selectedType == "All" || property.title.localizedCaseInsensitiveContains(selectedType)
            let matchesLocation = selectedLocation == "All" || property.location == selectedLocation
            let matchesPrice = property.price >= minPrice && property.price <= maxPrice
            return matchesType && matchesLocation && matchesPrice
        }
    }
    private func observeProperties() {
           let results = realm.objects(Property.self)
           notificationToken = results.observe { [weak self] changes in
               guard let self = self else { return }
               self.properties = Array(results)
               if self.filtersApplied {
                   self.applyFilters()
               } else {
                   self.filteredProperties = self.properties
               }
           }
       }

  
    func fetchProperties() {
        let results = realm.objects(Property.self)
        properties = Array(results)
    }
    func filterByType(_ type: PropertyType?) {
        if let type = type {
            filteredProperties = properties.filter { $0.propertyType == type.rawValue }
        } else {
            filteredProperties = properties 
        }
    }
    func resetFilters() {
        selectedType = "All"
        selectedLocation = "All"
        minPrice = 0
        maxPrice = 10000
        filteredProperties = properties
    }
    func clearFilters() {
            filtersApplied = false
            selectedType = ""
            selectedLocation = ""
            minPrice = 0
            maxPrice = 1_000_000
        }
    func updateAmenities(for property: Property, with newAmenities: [String]) {
        do {
            let realm = try Realm()
            try realm.write {
                property.amenities.removeAll()
                property.amenities.append(objectsIn: newAmenities)
            }
        } catch {
            print("❌ Failed to update amenities:", error)
        }
    }

    func addProperty(title: String, location: String, price: Double, descriptionText: String, imageBase64: String = "",propertyType:String, listingType: String,size:Int = 0,amenities: [String] = []) {
        let property = Property()
        property.title = title
        property.location = location
        property.price = price
        property.descriptionText = descriptionText
        property.imageBase64 = imageBase64
        property.propertyType = propertyType
        property.size = size
        property.listingType = listingType
        property.amenities.append(objectsIn: amenities)
        
        do {
            try realm.write {
                realm.add(property)
            }
            fetchProperties()
            print("✅ Property added: \(title)")
        } catch {
            print("❌ Failed to save property: \(error.localizedDescription)")
        }
    }
    deinit {
        notificationToken?.invalidate()
    }
}
class AuthViewModel: ObservableObject {
    private var realm: Realm
    
    @Published var currentUser: User?
    @Published var errorMessage = ""
    @Published var isLoggedIn: Bool = false
    @Published var isGuest : Bool = false
    
    private let userDefaultsKey = "loggedInUserID"
    
    init() {
        
        realm = try! Realm()
        if let hexString = UserDefaults.standard.string(forKey: userDefaultsKey),
           let objectId = try? ObjectId(string: hexString),
           let user = realm.object(ofType: User.self, forPrimaryKey: objectId) {
            currentUser = user
        }
    }
    
    // MARK: - Register
    func register(username: String, email: String, password: String) -> Bool {
        let existingUser = realm.objects(User.self).filter("email == %@", email).first
        if existingUser != nil {
            errorMessage = "Email already exists."
            return false
        }
        
        let newUser = User()
        newUser.username = username
        newUser.email = email
        newUser.password = password
        
        do {
            try realm.write {
                realm.add(newUser)
            }
            currentUser = newUser
          
            UserDefaults.standard.set(newUser.id.stringValue, forKey: userDefaultsKey)
            return true
        } catch {
            errorMessage = "Failed to register user: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Login
    func login(email: String, password: String) -> Bool {
        if let user = realm.objects(User.self)
            .filter("email == %@ AND password == %@", email, password)
            .first {
            currentUser = user
            isLoggedIn = true
            // Persist login
            UserDefaults.standard.set(user.id.stringValue, forKey: userDefaultsKey)
            return true
        } else {
            errorMessage = "Invalid credentials."
            return false
        }
    }
    
    // MARK: - Reset Password
    func resetPassword(email: String, newPassword: String) -> Bool {
        if let user = realm.objects(User.self).filter("email == %@", email).first {
            do {
                try realm.write {
                    user.password = newPassword
                }
                return true
            } catch {
                errorMessage = "Failed to reset password: \(error.localizedDescription)"
                return false
            }
        } else {
            errorMessage = "Email not found."
            return false
        }
    }
    
    // MARK: - Logout
    func logout() {
        currentUser = nil
        isGuest = false
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    func signOutGuest() {
        isGuest = false
        currentUser = nil
    }
    func continueAsGuest(){
        currentUser = nil
        isGuest = true
    }
}
