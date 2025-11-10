//
//  Real_EstateApp.swift
//  Real Estate
//
//  Created by Rion on 31.10.25.
//

import SwiftUI
import RealmSwift

@main
struct Real_EstateApp: SwiftUI.App {
    init(){
//        try? FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
        configureRealmMigration()
    }
    var body: some Scene {
        WindowGroup {
            RootView()
                .task { // Lazy Realm opening on background
                                    do {
                                        _ = try Realm() // Opens after migration
                                        print("✅ Realm ready")
                                    } catch {
                                        print("❌ Realm failed: \(error)")
                                    }
                                }
        }
    }
        }

private func configureRealmMigration() {
    let config = Realm.Configuration(
        schemaVersion: 6,
        migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 6 {
                migration.enumerateObjects(ofType: Property.className()) { _, newObject in
                    newObject?["listingType"] = newObject?["listingType"] ?? "Rent"
                    newObject?["size"] = newObject?["size"] ?? 0
                    if newObject?["amenities"] == nil {
                        newObject?["amenities"] = RealmSwift.List<String>()
                    }
                }
            }
        }
    )
    Realm.Configuration.defaultConfiguration = config
}
