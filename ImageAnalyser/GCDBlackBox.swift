//
//  GCDClient.swift
//  ImageAnalyser
//
//  Created by Robert Coffey on 06/09/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//


import Foundation

// Used to handle UI activity using main thread
func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}


// Used to handle UI activity using background thread
func performUIUpdatesOnBackground(updates: () ->Void) {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
        updates()
    }
}

func delay(seconds : Double) {
    let delay = seconds * Double(NSEC_PER_SEC)
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
    dispatch_after(time, dispatch_get_main_queue()) {
        // After x seconds this line will be executed
    }
}

