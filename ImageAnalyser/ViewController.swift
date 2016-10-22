//
//  ViewController.swift
//  ImageAnalyser
//
//  Created by Robert Coffey on 20/08/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import UIKit
import CoreData

// Initial view controller presented to user when opening the app.  User is offered to select an image for analysis. 
// Camera or Photo Album, as well as, History can also be selected.

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {
    
    //Instantiate AnalysisResult object
    var result : AnalysisResult? = nil
    
    //Instantiate the Core Data Stack manager and get context
    var sharedContext = CoreDataStackManager.sharedInstance().context
    
    // Counter for naming next AnalysisResult in Core Data
    var resultNumber : Int16 = 0
    
    //Outlets
    @IBOutlet weak var selectCameraButton: UIBarButtonItem!
    @IBOutlet weak var selectImageFolderButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide photo button if no camera source available
        selectCameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)

        // Initiate the Fetched Results Controller
        fetchResults()
        
        // Update pin counter
        resultNumber = (fetchedResultsController.fetchedObjects?.count)! + 1

    }
    
    
    // Create FetchedResultsController for AnalysisResult entities
    lazy var fetchedResultsController: NSFetchedResultsController = {

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
            displayError("Error performing fetch of Analysis Results: \(error.localizedDescription)")
        }
    }
    
    
    //Instantiate image picker controller, allow the current class to be its delegate, use the Camera or Photo Album as the source and present the view controller
    func selectImage(source: UIImagePickerControllerSourceType){

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    
    //Assign image from image picker to this class, scaling it to fit in the image view. Share and resize buttons are enabled and picker controller is dismissed.
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){

        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            let imageData = GoogleClient.sharedInstance().base64EncodeImageToNSData(image)
            result = AnalysisResult(image: imageData, resultNumber: resultNumber, context: sharedContext)
        }
        else {
            displayError("Error selecting image")
        }
        
        // Dismiss view controller and segue to the AnalysisView Controller
        dismissViewControllerAnimated(true, completion: nil)
        performSegueWithIdentifier("segueToAnalysisSelectorView", sender: self)
    }
    
    // Pass the result object to the destination AnalysisViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueToAnalysisSelectorView" {
            let destVC = segue.destinationViewController as! AnalysisSelectorViewController
            destVC.result = result
        }
    }
    
    //Present message to user using UIAlertController
    func displayError(error: String, debugLabelText: String? = nil) {
        
        let alert = UIAlertController(title: "Information", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // Action when ImageFolder Button selected
    @IBAction func selectImageFolderButton(sender: AnyObject) {
        selectImage(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    //Acion when CameraButton selected
    @IBAction func selectCameraButton(sender: AnyObject) {
        selectImage(UIImagePickerControllerSourceType.Camera)
    }
}

