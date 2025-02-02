//
//  BatteryManager.swift
//  PowerMom
//
//  Created by iite alpha on 02/02/2025.
//

// BatteryManager.swift
import Foundation
import IOKit.ps
import Combine

class BatteryManager: ObservableObject {
    @Published var percentage: Int = 0
    @Published var powerSource: String = "Unknown"
    @Published var batteryIcon: String = "battery.0"

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupPowerMonitoring()
        startUpdateTimer()
    }

    private func setupPowerMonitoring() {
        NotificationCenter.default.publisher(for: NSNotification.Name.NSProcessInfoPowerStateDidChange)
            .sink { [weak self] _ in
                self?.updatePowerInfo()
            }
            .store(in: &cancellables)

        updatePowerInfo()
    }

    private func startUpdateTimer() {
        Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updatePowerInfo()
            }
            .store(in: &cancellables)
    }
    
    private func getBatteryIcon(percentage: Int, isCharging: Bool) -> String {
        let batteryLevel: String

        switch percentage {
        case 0...10:
            batteryLevel = "battery.0"
        case 11...25:
            batteryLevel = "battery.25"
        case 26...50:
            batteryLevel = "battery.50"
        case 51...75:
            batteryLevel = "battery.75"
        default:
            batteryLevel = "battery.100"
        }

        return isCharging ? batteryLevel + ".bolt" : batteryLevel
    }

    func updatePowerInfo() {
        let powerInfo = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let powerSources = IOPSCopyPowerSourcesList(powerInfo).takeRetainedValue() as Array

        guard let powerSource = powerSources.first else { return }

        let powerDescription = IOPSGetPowerSourceDescription(powerInfo, powerSource).takeUnretainedValue() as! [String: Any]

        // Get percentage and update icon
        if let capacity = powerDescription[kIOPSCurrentCapacityKey] as? Int,
           let maxCapacity = powerDescription[kIOPSMaxCapacityKey] as? Int {
            DispatchQueue.main.async {
                self.percentage = Int((Double(capacity) / Double(maxCapacity)) * 100)
                let isCharging = self.powerSource == "Charger"
                self.batteryIcon = self.getBatteryIcon(percentage: self.percentage, isCharging: isCharging)
            }
        }

        // Get power source
        if let source = powerDescription[kIOPSPowerSourceStateKey] as? String {
            DispatchQueue.main.async {
                self.powerSource = source == "AC Power" ? "Charger" : "Battery"
                // Update icon again when power source changes
                let isCharging = source == "AC Power"
                self.batteryIcon = self.getBatteryIcon(percentage: self.percentage, isCharging: isCharging)
            }
        }
    }
}
