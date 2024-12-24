//
//  Device_Activity_Report.swift
//  Device Activity Report
//
//  Created by Ілля Мʼясников on 24.12.24.
//

import DeviceActivity
import SwiftUI

@main
struct Device_Activity_Report: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        // Add more reports here...
    }
}
