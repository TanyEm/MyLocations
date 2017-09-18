//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Tanya Tomchuk on 19.04.17.
//  Copyright © 2017 Tanya Tomchuk. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let tabBarController = window!.rootViewController as! UITabBarController
        
        if let tabBarViewControllers = tabBarController.viewControllers {
            let currentLocationViewController = tabBarViewControllers[0] as! CurrentLocationViewController
            currentLocationViewController.managedObjectContext = managedObjectContext
            
            // This looks up the LocationsViewController in the storyboard
            // and gives it a reference to the managed object context.
            let navigationController = tabBarViewControllers[1] as! UINavigationController
            
            let locationsViewController = navigationController.viewControllers[0] as! LocationsViewController
            locationsViewController.managedObjectContext = managedObjectContext
            
            // "CoreData: FATAL ERROR: The persistent cache of section information does
            // not match the current configuration.  You have illegally mutated the
            // NSFetchedResultsController's fetch request, its predicate, or its sort
            // descriptor without either disabling caching or using
            // +deleteCacheWithName:"
            // Solution: You can force the LocationsViewController to load its view 
            // immediately when the app starts up. Without this, it delays loading 
            // the view until you switch tabs, causing Core Data to get confused.
            let _ = locationsViewController.view
            
            // Before the MapViewController class can use the managedObjectContext, you have to give it a reference to that object first.
            let mapViewController = tabBarViewControllers[2] as! MapViewController
            mapViewController.managedObjectContext = managedObjectContext
            
            customizeAppearance()
        }
        print(applicationDocumentsDirectory)
        // method so that the notification handler is registered with NotificationCenter.
        listenForFatalCoreDataNotifications()
        return true
    }

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
    
    //This is the code need to load the data model, and to connect it to an SQLite data store.
    //The goal here is to create a so-called NSManagedObjectContext object.
    lazy var persistentContainer: NSPersistentContainer = {
        //it instantiate a new NSPersistentContainer object with the name of the data model
        let container = NSPersistentContainer(name: "DataModel")
        //it is loads the data from the database into memory and sets up the Core Data stack
        container.loadPersistentStores(completionHandler: {
            storeDescription, error in
            if let error = error {
                fatalError("Could load data store: \(error)")
            }
        })
        return container
    }()
    
    //create the NSManagedObjectContext object and connectittothe persistent store coordinator
    lazy var managedObjectContext: NSManagedObjectContext = self.persistentContainer.viewContext
    func listenForFatalCoreDataNotifications() {
        // Telled NotificationCenter that you want to be notified 
        // whenever a MyManagedObjectContextSaveDidFailNotification is posted.
        NotificationCenter.default.addObserver(
            forName: MyManagedObjectContextSaveDidFailNotification,
            object: nil, queue: OperationQueue.main, using: { notification in
                // Created a UIAlertController to show the error message.
                let alert = UIAlertController(
                    title: "Internal Error",
                    message:
                    "There was a fatal error in the app and it cannot continue.\n\n"
                        + "Press OK to terminate the app. Sorry for the inconvenience.",
                    preferredStyle: .alert)
                //  Added an action for the alert’s OK button. Instead of calling fatalError(), 
                // the closure creates an NSException object to terminate the app.
                // And it provides more information to the crash log.
                let action = UIAlertAction(title: "OK", style: .default) { _ in
                    let exception = NSException(
                        name: NSExceptionName.internalInconsistencyException,
                        reason: "Fatal Core Data error", userInfo: nil)
                    exception.raise()
                }
                alert.addAction(action)
                // present the alert.
                self.viewControllerForShowingAlert().present(alert, animated: true, completion: nil)
        })
    }
    // To show the alert with present (animated, completion) you need a view controller
    // that is currently visible, so this helper method finds one that is.
    func viewControllerForShowingAlert() -> UIViewController {
        let rootViewController = self.window!.rootViewController!
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController
        } else {
            return rootViewController
        }
    }
    
    // This changes the “bar tint” or background color of all navigation bars and tab bars in 
    // the app to black in one fell swoop. It also sets the color of the navigation bar’s
    // title label to white and applies the tint color to the tab bar.
    func customizeAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor.black
        UINavigationBar.appearance().titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.white ]
        UITabBar.appearance().barTintColor = UIColor.black
        
        let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
        
        UITabBar.appearance().tintColor = tintColor
    }
}

