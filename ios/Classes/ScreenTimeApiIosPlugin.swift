import Flutter
import _DeviceActivity_SwiftUI
import UIKit
import FamilyControls
import SwiftUI
import Foundation


@objc public class ScreenTimeApiIosPlugin: NSObject, FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "screen_time_api_ios", binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "screen_time_api_ios/events", binaryMessenger: registrar.messenger())
        let instance = ScreenTimeApiIosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "authorize":
            Task {
                try await FamilyControlModel.shared.authorize()
            }
            result(nil)
        case "isAuthorized":
            handleIsAuthorized(result: result)
        case "openStatistics":
            Task {
                presentDeviceActivityReport()
            }
            result(nil)
        case "stopMonitoring":
            Task {
                try FamilyControlModel.shared.stopMonitoring()
            }
            result(nil)
        case "startMonitoring":
            Task {
                try FamilyControlModel.shared.startMonitoring()
            }
            result(nil)
        case "fetchActivityEvent":
            checkForNewActivityEvent(result: result)
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleIsAuthorized(result: @escaping FlutterResult) {
        let isAuthorized = FamilyControlModel.shared.requestAuthorizationStatus() == .approved
        result(isAuthorized)
    }
    
    func fetchLastActivityEvent() -> String? {
        let sharedDefaults = UserDefaults(suiteName: "group.screenTime.com")
        
        if let data = sharedDefaults?.dictionary(forKey: "deviceActivityData") as? [String: String] {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                let jsonString = String(data: jsonData, encoding: .utf8)
                return jsonString
            } catch {
                print("Error serializing dictionary to JSON: \(error)")
                return nil
            }
        }
        
        return nil
    }
    
    public func checkForNewActivityEvent(result: @escaping FlutterResult) {
        if let lastEvent = fetchLastActivityEvent() {
            result(lastEvent)
        }
    }
    
    @objc func onPressClose(){
            dismiss()
        }
        
        func showController() {
            DispatchQueue.main.async {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                let windows = windowScene?.windows
                let controller = windows?.filter({ (w) -> Bool in
                    return w.isHidden == false
                }).first?.rootViewController as? FlutterViewController
                
                let selectAppVC: UIViewController = UIHostingController(rootView: ContentView())
                selectAppVC.navigationItem.rightBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: .close,
                    target: self,
                    action: #selector(self.onPressClose)
                )
                let naviVC = UINavigationController(rootViewController: selectAppVC)
                controller?.present(naviVC, animated: true, completion: nil)
            }
        }
        
        func dismiss(){
            DispatchQueue.main.async {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                let windows = windowScene?.windows
                let controller = windows?.filter({ (w) -> Bool in
                    return w.isHidden == false
                }).first?.rootViewController as? FlutterViewController
                controller?.dismiss(animated: true, completion: nil)
            }
        }
    
    func presentDeviceActivityReport() {
        DispatchQueue.main.async { 
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                print("Cannot find root view controller")
                return
            }
            
            let reportView = DeviceActivityReport(
                DeviceActivityReport.Context(rawValue: "Total Activity"),
                filter: DeviceActivityFilter(
                    segment: .hourly(during: DateInterval(start: Date().addingTimeInterval(-60 * 60 * 24), end: Date())),
                    users: .all, // or .children
                    devices: .init([.iPhone])
                )
            )

            let hostingController = UIHostingController(rootView: reportView)

            rootViewController.present(hostingController, animated: true)
        }
    }
    
    
    
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
