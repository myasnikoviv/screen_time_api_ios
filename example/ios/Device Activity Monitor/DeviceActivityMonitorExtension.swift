import DeviceActivity
import Foundation

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    func sendDataToAppGroup(updatedData: [String: String]) {
        let sharedDefaults = UserDefaults(suiteName: "group.screenTime.com")
        let calendar = Calendar.current
        let currentDate = Date()
        
        if let existingData = sharedDefaults?.dictionary(forKey: "deviceActivityData") as? [String: String] {
            var filteredData = existingData.filter { dateKey, _ in
                if let date = dayFormatter.date(from: dateKey) {
                    return calendar.dateComponents([.day], from: date, to: currentDate).day! < 7
                }
                return false
            }
            
            updatedData.forEach { date, minutes in
                filteredData[date] = minutes
            }
            
            sharedDefaults?.set(filteredData, forKey: "deviceActivityData")
        } else {
            sharedDefaults?.set(updatedData, forKey: "deviceActivityData")
        }
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        let minutesString = event.rawValue.replacingOccurrences(of: "min", with: "")
        
        guard let minutes = Int(minutesString) else {
            print("Invalid event name format: \(event.rawValue)")
            return
        }
        
        let currentDate = dayFormatter.string(from: Date())
        
        let newData: [String: String] = [
            currentDate: "\(minutes)"
        ]
        
        sendDataToAppGroup(updatedData: newData)
    }
}
