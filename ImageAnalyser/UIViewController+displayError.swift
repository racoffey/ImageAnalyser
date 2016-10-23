//
//  UIViewController+displayError.swift
//  ImageAnalyser
//
//  Created by Robert Coffey on 23/10/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    //Present message to user
    func displayError(error: String, debugLabelText: String? = nil) {
        
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Information", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        presentViewController(alert, animated: true, completion: nil)
    }
}

