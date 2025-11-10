//
//  Property.swift
//  EventPlannerApp
//
//  Created by Rion on 22.10.25.
//

import RealmSwift
import UIKit

class AppUser: Object, Identifiable {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var username: String = ""
    @Persisted var role: String = "user" // "user", "agent", or "admin"
}
class Property: Object, Identifiable {
     @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
      @Persisted var title: String = ""
      @Persisted var location: String = ""
      @Persisted var price: Double = 0.0
      @Persisted var descriptionText: String = ""
      @Persisted var imageBase64: String = ""
      @Persisted var isFavorite: Bool = false
      @Persisted var propertyType: String = ""
      @Persisted var listingType: String = "Rent"
     

     @Persisted var size: Int = 0
     @Persisted var amenities = List<String>()  // Realm list for amenities

      var id: ObjectId { _id }
}

class User: Object, ObjectKeyIdentifiable {
      @Persisted(primaryKey: true) var id: ObjectId = ObjectId.generate()
       @Persisted var name: String = ""  
       @Persisted var username: String = ""
       @Persisted var email: String = ""
       @Persisted var password: String = ""
}

class Message: Object, Identifiable {
    @Persisted(primaryKey: true) var _id: ObjectId = ObjectId.generate()
    @Persisted var senderID: String = ""
    @Persisted var receiverID: String = ""
    @Persisted var text: String = ""
    @Persisted var timestamp: Date = Date()
    
    var id: ObjectId { _id }
}

struct ComparedProperty: Identifiable {
    let id = UUID()
    let property: Property
}
