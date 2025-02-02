//
//  ContentView.swift
//  PowerMom
//
//  Created by iite alpha on 02/02/2025.
//

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @ObservedObject var batteryManager: BatteryManager

    var body: some View {
        VStack(spacing: 8) {
            BatteryHeader(percentage: batteryManager.percentage)
            PowerSourceView(source: batteryManager.powerSource)
            Divider()
            SettingsSection()
        }.padding(10)
    }
}


struct BatteryHeader: View {
    let percentage: Int

    var body: some View {
        VStack {
            Text("Battery")
                .font(.headline)
            Text("\(percentage)%")
                .monospacedDigit()
        }
    }
}

struct PowerSourceView: View {
    let source: String
    
    var body: some View {
        HStack {
            Image(systemName: source == "Battery" ? "bolt.batteryblock" : "powerplug")
        }
    }
}

struct SettingsSection: View {
    var body: some View {
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }.keyboardShortcut("q")
    }
}




