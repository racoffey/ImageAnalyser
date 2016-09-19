//
//  AnalysisSelectorView.swift
//  ImageAnalyser
//
//  Created by Robert Coffey on 20/08/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import UIKit

class AnalysisSelectorViewController: UIViewController {
    
    var image: UIImage?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var analyseButton: UIBarButtonItem!
    @IBOutlet weak var labelView: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textView: UITextView!

    override func viewWillAppear(animated: Bool) {
        print("Image in Analysis View Controller is : \(image)")
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = image
        activityIndicator.hidden = true
        activityIndicator.hidesWhenStopped = true
        self.labelView.hidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }

    //Present message to user
    func displayError(error: String, debugLabelText: String? = nil) {
        print(error)
        
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Information", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayResponse(response : AnyObject){
        var labelText : String = ""
        var count = 0
        var number = 0
        //let response = annotations as! [String : String]
        print("Reponse in displayResponse : \(response)")
        let labelAnnotations = response["labelAnnotations"]!
        print("LabelAnnotations in displayResponse : \(labelAnnotations)")
        print("Number of items in labelAnnotations = \(labelAnnotations!.count)")
        if labelAnnotations!.count != 0 {
            count  = 0
            number = labelAnnotations!.count
            print("Number : \(number)")
            print(labelAnnotations)
            labelText = "IMAGE LABELS: "
            while count < number {
                let dict = labelAnnotations![count]
                let str = dict["description"]!
                labelText.appendContentsOf(" \(str!)")
                count += 1
            }
        }
        print(labelText)
/*
        let faceAnnotations = response["faceAnnotations"]!
        print("FaceAnnotations in DR : \(faceAnnotations)")
        if faceAnnotations != nil {
            count  = 0
            number = faceAnnotations!.count
            print("Number : \(number)")
            labelText.appendContentsOf("\n FACE LABELS: ")
            while count < number {
                let dict = faceAnnotations![count]! as! [NSObject:AnyObject]
                let str = dict["description"]!
                labelText.appendContentsOf(" \(str)")
                count += 1
            }
        }
        
  */      
        

        //print(labelAnnotations!![0]["description"])
        //labelText = labelAnnotations!![0]["description"] as! String
        
        performUIUpdatesOnMain ({
            self.labelView.hidden = true
            self.textView.text = labelText
            self.textView.reloadInputViews()
        })
    }

    @IBAction func analyseButtonPressed(sender: AnyObject) {
        print("Reached Button Pressed")
        activityIndicator.startAnimating()
        self.labelView.hidden = false
        GoogleClient.sharedInstance().requestImageAnalysis(self.image!) { (success, errorString, response) in
            if success {
                self.displayResponse(response!)
            } else {
                self.displayError(errorString!)
            }
        }
        activityIndicator.stopAnimating()
    }
 
}
 
