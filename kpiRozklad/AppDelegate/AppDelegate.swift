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

struct global {
    static var sheduleType: SheduleType = .groups
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()
    private let settings = Settings.shared
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        settings.isShowGreetings = false
//        settings.isGroupsShedule = false
//        settings.isTeacherShedule = true
//
        if settings.isGroupsShedule == true && settings.isTeacherShedule == false {
            global.sheduleType = .groups
        } else {
            global.sheduleType = .teachers
        }
//        settings.teacherName = ""
        
        if settings.sheduleUpdateTime == "" {
            settings.isTryToRefreshShedule = true
            deleteAllFromCoreData()
 
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"

            Settings.shared.sheduleUpdateTime = formatter.string(from: date)
        } else if settings.updateAtOnce == "" {
            settings.isTryToRefreshShedule = true
            settings.updateAtOnce = "updated"
            deleteAllFromCoreData()
            
            let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            if let sheduleVC : SheduleViewController = mainStoryboard.instantiateViewController(withIdentifier: SheduleViewController.identifier) as? SheduleViewController {
                sheduleVC.server(requestType: SheduleType.groups)
            }
        } else {
//            settings.isShowGreetings = false
        }
        
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let mainVC = mainStoryboard.instantiateInitialViewController()
        guard let greetingVC = mainStoryboard.instantiateViewController(withIdentifier: GreetingViewController.identifier) as? GreetingViewController else { return false }
        
        window?.rootViewController = settings.isShowGreetings ? greetingVC : mainVC
        
        return true
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
          
        let needID = url.host?.removingPercentEncoding
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let sheduleVC : SheduleViewController = mainStoryboard.instantiateViewController(withIdentifier: SheduleViewController.identifier) as? SheduleViewController else { return false }
        
        for i in 1..<3 {
            sheduleVC.currentWeek = i
            sheduleVC.isNeedToScroll = false
            sheduleVC.makeLessonsShedule(lessonsInit: nil)
            let lessonsForTableView = sheduleVC.lessonsForTableView
            for day in lessonsForTableView {
                let lessons = day.value
                for lesson in lessons {
                    if lesson.lessonID == needID {
                        
                        guard let sheduleDetailVC : SheduleDetailViewController = mainStoryboard.instantiateViewController(withIdentifier: SheduleDetailViewController.identifier) as? SheduleDetailViewController else { return false }
                        
                        sheduleDetailVC.lesson = lesson

                        guard let mainTabBar : UITabBarController = mainStoryboard.instantiateViewController(withIdentifier: "Main") as? UITabBarController else { return false }
                        
                        mainTabBar.selectedIndex = 0
                        DispatchQueue.main.async {
                            if let vc = mainTabBar.selectedViewController as? UINavigationController {
                                vc.pushViewController(sheduleDetailVC, animated: true)
                            }
                        }
                      
                        window?.rootViewController = mainTabBar
                    }
                }
            }
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
        let container = NSCustomPersistentContainer(name: "kpiRozklad")
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

    // MARK: - Core Data Saving support

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
