//
//  ExtensionDelegate.swift
//  kpiRozkladWatch Extension
//
//  Created by Денис Данилюк on 07.06.2020.
//  Copyright © 2020 Denis Danilyuk. All rights reserved.
//

import WatchKit
import WatchConnectivity


class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        setupWatchConnectivity()
    }
    
    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            if #available(watchOSApplicationExtension 5.0, *) {
                switch task {
                case let backgroundTask as WKApplicationRefreshBackgroundTask:
                    // Be sure to complete the background task once you’re done.
                    backgroundTask.setTaskCompletedWithSnapshot(false)
                case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                    // Snapshot tasks have a unique completion call, make sure to set your expiration date
                    snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
                case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                    // Be sure to complete the connectivity task once you’re done.
                    connectivityTask.setTaskCompletedWithSnapshot(false)
                case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                    // Be sure to complete the URL session task once you’re done.
                    urlSessionTask.setTaskCompletedWithSnapshot(false)
                case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                    // Be sure to complete the relevant-shortcut task once you're done.
                    relevantShortcutTask.setTaskCompletedWithSnapshot(false)
                case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                    // Be sure to complete the intent-did-run task once you're done.
                    intentDidRunTask.setTaskCompletedWithSnapshot(false)
                default:
                    // make sure to complete unhandled task types
                    task.setTaskCompletedWithSnapshot(false)
                }
            } else {
                // Fallback on earlier versions
            }
        }
    }

}


extension ExtensionDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            fatalError("Can't activate session with error: \(error.localizedDescription)")
        }
        print("WC Session activated with state: \(activationState.rawValue)")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        do {
            try saveDataAndPostNotification(applicationContext: applicationContext)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    /// Debug
    /// Because didReceiveApplicationContext is not working with watch os 7.0
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        do {
            try saveDataAndPostNotification(applicationContext: message)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func saveDataAndPostNotification(applicationContext: [String : Any]) throws {
        do {
            print("Data start saving")

            guard let lessonsData = applicationContext["lessons"] as? Data else { return }

            let decoder = JSONDecoder.init()
            
            let lessons = try decoder.decode([Lesson].self, from: lessonsData)
            
            let groupOrTeacherName = applicationContext["groupOrTeacherName"] as? String ?? ""
            
            guard let currentColourData = applicationContext["currentColourData"] as? Data else {
                fatalError("Can't cast currentColour as Data")
            }
            guard let nextColourData = applicationContext["nextColourData"] as? Data else {
                fatalError("Can't cast nextColourData as Data")
            }

            StoreUserDefaults.shared.lessons = lessons
            StoreUserDefaults.shared.groupOrTeacherName = groupOrTeacherName.uppercased()
            StoreUserDefaults.shared.cellNextColour = UIColor.color(withData: nextColourData)
            StoreUserDefaults.shared.cellCurrentColour = UIColor.color(withData: currentColourData)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "lessonsData"), object: nil)
            }

            print("Data saved")
        } catch {
            print(error.localizedDescription)
        }
    }

    
}
