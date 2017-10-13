//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Tanya Tomchuk on 13/10/2017.
//  Copyright © 2017 Tanya Tomchuk. All rights reserved.
//

import Foundation
import UIKit

// The simplest way to make the status bar white for all your view controllers
// in the entire app is to replace the UITabBarController with your own subclass.
class MyTabBarController: UITabBarController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // By returning nil from childViewControllerForStatusBarStyle, the tab bar controller
    // will look at its own preferredStatusBarStyle property instead of those from
    // the other view controllers
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return nil
    }
}
