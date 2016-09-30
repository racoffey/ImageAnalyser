//
//  ViewController.swift
//  ImageAnalyser
//
//  Created by Robert Coffey on 20/08/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var image : UIImage?
    

    @IBOutlet weak var selectCameraButton: UIBarButtonItem!
    @IBOutlet weak var selectImageFolderButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide photo button if no camera source available
        selectCameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)


        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            destVC.image = image! as UIImage
            print("HEre is the image: \(destVC.image)")
        }
    }

    
    @IBAction func selectImageFolderButton(sender: AnyObject) {
                selectImage(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    
    @IBAction func selectCameraButton(sender: AnyObject) {
                        selectImage(UIImagePickerControllerSourceType.Camera)
    }

}

