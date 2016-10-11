//
//  ViewController.swift
//  ImageAnalyser
//
//  Created by Robert Coffey on 20/08/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {

    var image : UIImage?
    
    //Instantiate AnalysisResult object
    var result : AnalysisResult? = nil
    
    //Instantiate the Core Data Stack manager and get context
    var sharedContext = CoreDataStackManager.sharedInstance().context
    
    // Pin counter for naming next pin
    var resultNumber : Int16 = 0
    

    @IBOutlet weak var selectCameraButton: UIBarButtonItem!
    @IBOutlet weak var selectImageFolderButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide photo button if no camera source available
        selectCameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)


        // Start the Fetched Results Controller
        fetchResults()
        
        // Update pin counter
        resultNumber = (fetchedResultsController.fetchedObjects?.count)! + 1

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Fetched results controller for Pin entities
    lazy var fetchedResultsController: NSFetchedResultsController = {
        print("Reached fetchedResultsController")
        let fetchRequest = NSFetchRequest(entityName: "AnalysisResult")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // Fetch results from Core Data and display any error
    func fetchResults() {
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        
        if let error = error {
            displayError("Error fetching Pins from Core Data: \(error)")
        }
    }
    
    func selectImage(source: UIImagePickerControllerSourceType){
        //Instantiate image picker controller, allow the current class to be its delegate, use the Camera as the source and present the view controller
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        //Assign image from image picker to this class, scaling it to fit in the image view. Share and resize buttons are enabled and picker controller is dismissed.
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            self.image = image
            let imageData = GoogleClient.sharedInstance().base64EncodeImageToNSData(image)
            result = AnalysisResult(image: imageData, resultNumber: resultNumber, context: sharedContext)
            print("ResultNumber = \(resultNumber)")
        }
        else {
            print ("Error selecting image")
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        print("Retutning from image picker controller")
        performSegueWithIdentifier("segueToAnalysisSelectorView", sender: self)

    }
    
    //func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("Reached prepare for Segue")
        if segue.identifier == "segueToAnalysisSelectorView" {
            let destVC = segue.destinationViewController as! AnalysisSelectorViewController
            destVC.result = result
        }
    }
    
    //Present message to user
    func displayError(error: String, debugLabelText: String? = nil) {
        print(error)
        
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Information", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
        
    }

    
    @IBAction func selectImageFolderButton(sender: AnyObject) {
                selectImage(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    
    @IBAction func selectCameraButton(sender: AnyObject) {
                        selectImage(UIImagePickerControllerSourceType.Camera)
    }

}

