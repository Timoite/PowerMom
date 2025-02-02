//
//  PowerMomApp.swift
//  PowerMom
//
//  Created by iite alpha on 02/02/2025.
//

// PowerMom.swift
import SwiftUI

@main
struct PowerMomApp: App {
    @StateObject private var batteryManager = BatteryManager()

    var body: some Scene {
        MenuBarExtra {
            ContentView(batteryManager: batteryManager)
        } label: {
            Image(systemName: batteryManager.batteryIcon)
        }
    }
}

