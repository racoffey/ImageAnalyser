//
//  AppDelegate.swift
//  ImageAnalyser
//
//  Created by Robert Coffey on 20/08/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import UIKit
import MapKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // Instantiate CoreDataStackManager
    let stackManager = CoreDataStackManager.sharedInstance()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Start Autosaving when application launches
        stackManager.autoSave(60)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {

        // Save Core Data when resigning active state
        stackManager.save()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
        //Save Core Data when entering background state
        stackManager.save()
    }


    func applicationWillTerminate(application: UIApplication) {
        
        // Save Core Data when application terminates
        stackManager.save()
    }
}

