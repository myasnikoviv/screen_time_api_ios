//
//  DeviceActivityMonitorExtension 2.swift
//  Runner
//
//  Created by Ілля Мʼясников on 24.12.24.
//


import DeviceActivity
import Foundation

class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    /// Обновление данных в App Group
    func sendDataToAppGroup(updatedData: [String: String]) {
        let sharedDefaults = UserDefaults(suiteName: "group.screenTime.com")
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Получаем текущие данные
        if var existingData = sharedDefaults?.dictionary(forKey: "deviceActivityData") as? [String: String] {
            // Удаляем данные старше 7 дней
            let filteredData = existingData.filter { dateKey, _ in
                if let date = dayFormatter.date(from: dateKey) {
                    return calendar.dateComponents([.day], from: date, to: currentDate).day! < 7
                }
                return false
            }
            
            // Обновляем данные: добавляем новые и заменяем существующие
            updatedData.forEach { date, minutes in
                if let existingMinutes = filteredData[date], let totalMinutes = Int(existingMinutes) {
                    filteredData[date] = "\(totalMinutes + Int(minutes)!)"
                } else {
                    filteredData[date] = minutes
                }
            }
            
            sharedDefaults?.set(filteredData, forKey: "deviceActivityData")
        } else {
            // Если данных ещё нет, просто сохраняем
            sharedDefaults?.set(updatedData, forKey: "deviceActivityData")
        }
    }
    
    /// Обработка достижения порога
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Парсим событие: ожидаем формат minX
        guard let minutesString = event.rawValue.replacingOccurrences(of: "min", with: ""),
              let minutes = Int(minutesString) else {
            print("Invalid event name format: \(event.rawValue)")
            return
        }
        
        let currentDate = dayFormatter.string(from: Date())
        
        // Формируем новые данные: текущая дата — количество минут
        let newData: [String: String] = [
            currentDate: "\(minutes)"
        ]
        
        sendDataToAppGroup(updatedData: newData)
    }
}