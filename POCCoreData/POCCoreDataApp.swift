//
//  POCCoreDataApp.swift
//  POCCoreData
//
//  Created by Saket Raje on 25/04/2024.
//

import SwiftUI

@main
struct POCCoreDataApp: App {
//    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            POCCrashable()
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
