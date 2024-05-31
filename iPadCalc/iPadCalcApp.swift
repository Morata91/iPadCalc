//
//  iPadCalcApp.swift
//  iPadCalc
//
//  Created by 村田航希 on 2024/05/13.
//

import SwiftUI
import SwiftData

@main
struct iPadCalcApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            TableHistory.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: TableHistory.self)
    }
    
    //アプリが起動した時（？）
    init() {
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
}
