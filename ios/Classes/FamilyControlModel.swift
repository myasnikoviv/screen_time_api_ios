//
//  FamilyControlModel.swift
//  screen_time_api_ios
//
//  Created by Kei Fujikawa on 2023/10/11.
//

import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings

class FamilyControlModel: ObservableObject {
    static let shared = FamilyControlModel()

    private init() {
        selectionToDiscourage = savedSelection() ?? FamilyActivitySelection()
    }

    private let store = ManagedSettingsStore()
    private let userDefaultsKey = "ScreenTimeSelection"
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    private let deviceActivityCenter = DeviceActivityCenter()

    var selectionToDiscourage = FamilyActivitySelection() {
        willSet {
            print ("got here \(newValue)")

            let applications = newValue.applicationTokens
            let categories = newValue.categoryTokens

            print ("applications \(applications)")
            print ("categories \(categories)")

            store.shield.applications = applications.isEmpty ? nil : applications

            store.shield.applicationCategories = ShieldSettings
                .ActivityCategoryPolicy
                .specific(
                    categories
                )
            store.shield.webDomainCategories = ShieldSettings
                .ActivityCategoryPolicy
                .specific(
                    categories
                )
            self.saveSelection(selection: newValue)
        }
    }

    func authorize() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }

    func encourageAll(){
        store.shield.applications = []
        store.shield.applicationCategories = ShieldSettings
            .ActivityCategoryPolicy
            .specific(
                []
            )
        store.shield.webDomainCategories = ShieldSettings
            .ActivityCategoryPolicy
            .specific(
                []
            )
    }

    func saveSelection(selection: FamilyActivitySelection) {
        let defaults = UserDefaults.standard
        defaults.set(
            try? encoder.encode(selection),
            forKey: userDefaultsKey
        )
    }

    func savedSelection() -> FamilyActivitySelection? {
        let defaults = UserDefaults.standard

        guard let data = defaults.data(forKey: userDefaultsKey) else {
            return nil
        }

        return try? decoder.decode(
            FamilyActivitySelection.self,
            from: data
        )
    }
    
    func startMonitoring() throws{
        do {
            let apps = savedSelection()
            if (apps != nil) {
                for app in apps!.applications {
                    let bundleId = app.bundleIdentifier ?? ""
                    print(bundleId)
                    let activityName = DeviceActivityName(bundleId)
                    try startMonitoringActivity(activityName:activityName,schedule:createSchedule())
                }
            }
        } catch {
            print("error")
        }
        
    }
                                        
    func createSchedule() -> DeviceActivitySchedule {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date()) // 00:00 текущих суток
        let todayEnd = calendar.date(byAdding: .minute, value: 1, to: todayStart)?.addingTimeInterval(-1)
        let intervalStart = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: todayStart)
        let intervalEnd = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: todayEnd!)

        let schedule = DeviceActivitySchedule(
            intervalStart: intervalStart,
            intervalEnd: intervalEnd,
            repeats: true
        )
                
        return schedule
    }
    
    func startMonitoringActivity(activityName: DeviceActivityName, schedule: DeviceActivitySchedule, events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]) throws {
         let deviceActivityCenter = DeviceActivityCenter()
            // Запускаем мониторинг активности с заданным расписанием и событиями
            try deviceActivityCenter.startMonitoring(activityName, during: schedule, events: events)
            print("Started monitoring activity: \(activityName)")
        }

        func fetchActivities() -> [DeviceActivityName] {
            let deviceActivityCenter = DeviceActivityCenter()
            return deviceActivityCenter.activities
        }

        func fetchSchedule(for activity: DeviceActivityName) -> DeviceActivitySchedule? {
            let deviceActivityCenter = DeviceActivityCenter()
            return deviceActivityCenter.schedule(for: activity)
        }
        

        func testMonitoring() async throws{
            do {
         
                try startMonitoring()

                // Проверяем активные активности
                let activities = fetchActivities()
                print("Currently monitored activities: \(activities)")

            } catch {
                print("Failed to start monitoring activity: \(error)")
            }
        }
    
}
