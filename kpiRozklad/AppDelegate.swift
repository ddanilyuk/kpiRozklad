//
//  AppDelegate.swift
//  kpiRozklad
//
//  Created by Denis on 9/24/19.
//  Copyright © 2019 Denis Danilyuk. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData
import WatchConnectivity

var API = NetworkingApiFacade(apiService: NetworkingApi())

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()
    private let settings = Settings.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupWatchConnectivity()

        if !settings.updateRozkladWithVersion2Point0 {
            deleteAllFromCoreData(managedContext: self.persistentContainer.viewContext)
            settings.isTryToRefreshShedule = true
            
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            settings.sheduleUpdateTime = formatter.string(from: date)
            settings.updateRozkladWithVersion2Point0 = true
        }
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mainVC = mainStoryboard.instantiateInitialViewController()
        guard let greetingVC = mainStoryboard.instantiateViewController(withIdentifier: BoardingViewController.identifier) as? BoardingViewController else { return false }
        
        window?.rootViewController = settings.isShowGreetings ? greetingVC : mainVC
        return true
    }
    
    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // Open app from widget
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(600)) {
            let needID = Int(url.host?.removingPercentEncoding ?? "") ?? 0
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            
            guard let mainTabBar: UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as? UITabBarController else { return }
            
            let lessons = fetchingCoreData(managedContext: managedContext)
            let lessonOptional = lessons.first { $0.id == needID }
            guard let lesson = lessonOptional else { return }
            
            guard let sheduleDetailNavigationVC: SheduleDetailNavigationController = mainStoryboard.instantiateViewController(withIdentifier: SheduleDetailNavigationController.identifier) as? SheduleDetailNavigationController else { return }
            sheduleDetailNavigationVC.lesson = lesson

            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if let navigation = mainTabBar.selectedViewController as? UINavigationController {
                    navigation.presentPanModal(sheduleDetailNavigationVC, sourceView: nil, sourceRect: .zero)
                }
            }
            self.window?.rootViewController = mainTabBar
        }
        return true
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSCustomPersistentContainer(name: "kpiRozkladModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}


extension AppDelegate {
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}


extension AppDelegate: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            fatalError("Can't activate session with error: \(error.localizedDescription)")
        }
        print("WC Session activated with state: \(activationState.rawValue)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive")
        print(#function)
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate")
        print(#function)
        WCSession.default.activate()
    }
    
}
