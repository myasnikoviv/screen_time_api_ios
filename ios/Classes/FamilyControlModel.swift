import Foundation
import FamilyControls
import DeviceActivity
import ManagedSettings

class FamilyControlModel: ObservableObject {
    static let shared = FamilyControlModel()
    private let deviceActivityCenter = DeviceActivityCenter()
    private let store = ManagedSettingsStore()
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    private let userDefaultsKey = "ScreenTimeSelection"
    
    var selectionToDiscourage = FamilyActivitySelection() {
            willSet {
                print ("got here \(newValue)")

                let applications = newValue.applicationTokens
                let categories = newValue.categoryTokens

                print ("applications \(applications)")
                print ("categories \(categories)")


//                store.shield.applications = applications.isEmpty ? nil : applications
//
//                store.shield.applicationCategories = ShieldSettings
//                    .ActivityCategoryPolicy
//                    .specific(
//                        categories
//                    )
//                store.shield.webDomainCategories = ShieldSettings
//                    .ActivityCategoryPolicy
//                    .specific(
//                        categories
//                    )
//                self.saveSelection(selection: newValue)
            }
        }

    func authorize() async throws {
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }


    func startMonitoring()  throws{
        do {
            let schedules = createSchedules()
            let events = createThresholdsForDay()
                do {
                    try startMonitoringActivity(activityName: DeviceActivityName("today"), schedule:schedules.todaySchedule, events: events)
                    print("Monitoring started for today")
                    try startMonitoringActivity(activityName: DeviceActivityName("everyday"), schedule:schedules.dailySchedule, events: events)
                    print("Monitoring started for everyday")
                    
                } catch {
                    print("Failed to start monitoring. Error: \(error)")
                }
            
        }
    }
    
    func stopMonitoring() throws {
        deviceActivityCenter.stopMonitoring()
    }
    
    func createThresholdsForDay() -> [DeviceActivityEvent.Name: DeviceActivityEvent] {
        var thresholds: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]
        let totalMinutesInDay = 24 * 60
        let interval = 15
        
        for minute in stride(from: interval, to: totalMinutesInDay + 1, by: interval) {
            let thresholdName = DeviceActivityEvent.Name("min\(minute)")
            thresholds[thresholdName] = DeviceActivityEvent(threshold: DateComponents(minute: minute))
        }

        return thresholds
    }
                                        
    func createSchedules() -> (todaySchedule: DeviceActivitySchedule, dailySchedule: DeviceActivitySchedule) {
        let calendar = Calendar.current
        let now = Date()
        
        let intervalStartToday = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now)!
        let intervalEndToday = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: endOfDay)
        
        let todaySchedule = DeviceActivitySchedule(
            intervalStart: intervalStartToday,
            intervalEnd: intervalEndToday,
            repeats: false
        )
        
        let startOfTomorrow = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)
        let intervalStartTomorrow = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: startOfTomorrow)
        let endOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfTomorrow)!
        let intervalEndTomorrow = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: endOfTomorrow)
        
        let dailySchedule = DeviceActivitySchedule(
            intervalStart: intervalStartTomorrow,
            intervalEnd: intervalEndTomorrow,
            repeats: true
        )
        
        return (todaySchedule, dailySchedule)
    }
    
    func startMonitoringActivity(activityName: DeviceActivityName, schedule: DeviceActivitySchedule, events: [DeviceActivityEvent.Name: DeviceActivityEvent] = [:]) throws {
            try deviceActivityCenter.startMonitoring(activityName, during: schedule, events: events)
            print("Started monitoring activity: \(activityName)")
        }

    func fetchActivities() -> [DeviceActivityName] {
            return deviceActivityCenter.activities
        }

    func fetchSchedule(for activity: DeviceActivityName) -> DeviceActivitySchedule? {
            return deviceActivityCenter.schedule(for: activity)
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
}
