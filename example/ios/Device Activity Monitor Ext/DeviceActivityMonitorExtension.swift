//
//  DeviceActivityMonitorExtension.swift
//  Device Activity Monitor Ext
//
//  Created by Ілля Мʼясников on 20.12.24.
//

import DeviceActivity

// Optionally override any of the functions below.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
            super.intervalDidStart(for: activity)
            
            print("intervalDidStart")
        }
        
        override func intervalDidEnd(for activity: DeviceActivityName) {
            super.intervalDidEnd(for: activity)
            
            print("intervalDidEnd")
        }
        
        override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
            super.eventDidReachThreshold(event, activity: activity)
            
            print("eventDidReachThreshold")
        }
        
        override func intervalWillStartWarning(for activity: DeviceActivityName) {
            super.intervalWillStartWarning(for: activity)
            
            // Handle the warning before the interval starts.
        }
        
        override func intervalWillEndWarning(for activity: DeviceActivityName) {
            super.intervalWillEndWarning(for: activity)
            
            
            print("intervalWillEndWarning")
        }
        
        override func eventWillReachThresholdWarning(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
            super.eventWillReachThresholdWarning(event, activity: activity)
            
            print("eventWillReachThresholdWarning")
        }
}
