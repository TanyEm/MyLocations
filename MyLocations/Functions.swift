//
//  Functions.swift
//  MyLocations
//
//  Created by Tanya Tomchuk on 25.05.17.
//  Copyright © 2017 Tanya Tomchuk. All rights reserved.
//

import Foundation
import Dispatch //This imports the Grand Central Dispatch framework, or GCD for short.

//This function takes a closure as its final parameter.
//Inside that closure you tell the view controller to dismiss itself.
//DispatchQueue.main.asyncAfter() uses the time given by .now() + delayInSeconds
//to schedule the closure for some point in the future.
func afterDelay(_ seconds: Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}

let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

//This defines a new global function for handling fatal Core Data errors.
let MyManagedObjectContextSaveDidFailNotification = Notification.Name(
    rawValue: "MyManagedObjectContextSaveDidFailNotification")
// After dumping the debug info, the function does the following:
func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    //NotificationCenter to post a notification
    NotificationCenter.default.post(
        name: MyManagedObjectContextSaveDidFailNotification, object: nil)
}
