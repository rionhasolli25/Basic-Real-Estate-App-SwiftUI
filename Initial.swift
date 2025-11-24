//
//  Initial.swift
//  Real Estate
//
//  Created by Rion on 24.11.25.
//

import RealmSwift
import Photos
import SwiftUI

func seedInitialProperties() {
    
    let realm = try! Realm()
    
    let sample1 = Property()
    sample1.title = "Modern Apartment in Dardania"
    sample1.price = 12000
  
    sample1.location = "Prishtina"
    sample1.propertyType = "Apartment"
    sample1.descriptionText = "A beautiful city apartment with great amenities." // adjust field name

//    if let image = UIImage(named: "apartment1"), // name of your image in Assets.xcassets
//       let data = image.jpegData(compressionQuality: 0.8) {
//        sample1.imageData = data
//    }
    let sample2 = Property()
    sample2.title = "Garage for Sale in Breg Diellit"
    sample2.price = 60000
    sample2.location = "prishtina"
    sample2.propertyType = "Villa"
    sample2.descriptionText = "Spacious villa with ocean view and private pool."


    let sampleProperties = [sample1, sample2]

    do {
        let realm = try Realm()
        try realm.write {
            realm.add(sampleProperties)
        }
        print("✅ Seeded initial properties")
    } catch {
        print("❌ Failed to seed properties: \(error)")
    }

}
