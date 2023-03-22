//
//  Apple_watch_browserApp.swift
//  watchApp WatchKit Extension
//
//  Created by ashutosh on 29/01/22.
//

import SwiftUI

@main
struct Apple_watch_browserApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
