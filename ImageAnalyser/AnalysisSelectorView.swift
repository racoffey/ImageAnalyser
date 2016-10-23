//
//  AnalysisSelectorView.swift
//  ImageAnalyser
//
//  Created by Robert Coffey on 20/08/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import UIKit
import MapKit

// The AnalysisSelectorViewController presents the image selected by the user for analysis and 4 analysis options.
// Each option uses the corresponding Google Vision API method.
// "General" analysis makes a general analysis of the image and provides keywords.
// "Face" analysis performs both general and face analyses of the image, providing both content and emotion information on an image containing faces.
// "Landmark" returns the name, country and wikipedia link presented as pin + annotation on a map for any landmark found in the image.
// "Text" returns the text content of the image. If the text language is not English it is automatically translated to English.

class AnalysisSelectorViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    //Assign variable for image
    var image: UIImage?
    
    // Instantiate Analysis Result
    var result : AnalysisResult? = nil
    
    // Get context from shared instance from CoreDataStackManager
    var sharedContext = CoreDataStackManager.sharedInstance().context

    //Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var generalButton: UIBarButtonItem!
    @IBOutlet weak var textButton: UIBarButtonItem!
    @IBOutlet weak var landmarkButton: UIBarButtonItem!
    @IBOutlet weak var faceButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mapView: MKMapView!


    override func viewWillAppear(animated: Bool) {
        
        // Extract image from result in Core Data, size and present.
        image = UIImage(data: (result?.image)!)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = image
        
        //Prepare activity indicator and other view settings
        activityIndicator.hidden = true
        activityIndicator.hidesWhenStopped = true
        textView.hidden = false
        mapView.hidden = true

        // If analaysis has already been performed present the respective text or map view in case of landmark analysis.
        // Otherwise inform user to select wanted analysis type.
        if result?.labelText != nil {
            if result?.analysisType == "landmark" {
              displayMapView()
            } else {
            textView.text = result?.labelText
            }
        } else {
            textView.text = "\n Select analysis type"
        }

        // Assign map view delegate to this class
        self.mapView.delegate = self
    }
    

    //ASSISTING FUNCTIONS

    
    // Present textual analysis response to the user
    func displayResponse(){
        performUIUpdatesOnMain ({
            self.activityIndicator.stopAnimating()
            self.textView.hidden = false
            self.textView.text = self.result!.labelText
            self.textView.reloadInputViews()
        })
    }
    

    // Start animating activity indicator and inform user analysis is underway
    func animateActivityIndicator(){
        performUIUpdatesOnMain ({
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
            self.textView.hidden = false
            self.textView.text = "\n Image being analysed..."
            self.textView.reloadInputViews()
        })
    }
 
 
    // Remove whitespace from string
    func removeWhiteSpace(var string : String) -> String {
        string = string.stringByReplacingOccurrencesOfString(" ", withString: "_")
        if string.characters.first == "_" {
            string.removeAtIndex(string.startIndex)
        }
        if string.characters.last == "_" {
            string.removeAtIndex(string.endIndex)
        }
        return string
    }
    
    private func requestImageAnalysis(type: String) {
        animateActivityIndicator()
        
        //Store analysis type
        result?.updateAnalysisType(type)
        
        //Initiate analysis of the image and present result
        GoogleClient.sharedInstance().requestImageAnalysis(result!) { (success, error, result) in
            if success {
                self.result = result
                
                // If landmark analysis has been performed so the result as a mapView otherwise show in textView
                if type == "landmark" {
                    self.displayMapView()
                } else {
                    self.displayResponse()
                }
            } else {
                self.activityIndicator.stopAnimating()
                self.displayError(error!.localizedDescription)
            }
        }
    }
    
    
    //MAP FUNCTIONS
    
    // Present landmark response to user as pin and annotation including wikipedia link on map
    func displayMapView() {
        
        if result?.landmarkLabel != nil {
            // Prepare pin annotation and map location
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = (result?.coordinate)!
            let mapLocation = CLLocation(latitude: (result!.latitude), longitude: (result!.longitude))
            
            // Create Wikipedia URL link using by appending the landmark name as a search criteria
            let wikiURL = Constants.WikipediaRequestValues.wikipediaURL + removeWhiteSpace(result!.labelText!)
            
            // If landmark country is included in result display it in the annotation title
            if result?.country != nil {
                dropPin.title = result!.labelText! + (", \((result?.country)!)")
            } else {
                dropPin.title = result!.labelText!
            }
            
            // Include Wikipedia link in annotation subtitle
            dropPin.subtitle = wikiURL
            
            //Display map to end user
            performUIUpdatesOnMain ({
                self.textView.hidden = true
                self.mapView.hidden = false
                self.centerMapOnLocation(mapLocation)
                self.mapView.addAnnotation(dropPin)
                self.mapView.selectAnnotation(dropPin, animated: true)
            })
        } else {
            result?.labelText = "\n Unable to identify landmark"
            performUIUpdatesOnMain({
                self.textView.text = self.result?.labelText
                self.activityIndicator.stopAnimating()
            })

        }
    }
    
    
    //Prepare annotation view
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            //If queued annotations not available then create new with call out and accessory
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -10, y: 10)
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        }
        //Return the annotation view
        return view
    }
    
    
    // Set map view region
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  Constants.Map.RegionRadius * 2.0, Constants.Map.RegionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // Stop animating activity indicator when map is rendered
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool){
        activityIndicator.stopAnimating()
    }
    
    //If call out is tapped then open Wikipedia URL link in subtitle
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {

        let wikiURL = ((view.annotation?.subtitle!)! as String).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        if let url = NSURL(string: wikiURL) {
            UIApplication.sharedApplication().openURL(url, options: [ : ]) { (success) in
                if success {
                } else {
                    self.displayError("Cannot present web page")
                }
            }
        } else {
            displayError("Cannot present web page")
        }
    }
    
    
    
    
    //ACTIONS
    
    // "General" analysis selected
    @IBAction func generalButtonPressed(sender: AnyObject) {
        
        //Request General analysis of the image using
        requestImageAnalysis("general")
    }
    
    
    // "Text" analysis selected
    @IBAction func textButtonPressed(sender: AnyObject) {
        
        //Request Text analysis of the image using
        requestImageAnalysis("text")
    }
    
    
    // "Landmark" analysis selected
    @IBAction func landmarkButtonPressed(sender: AnyObject) {
        
        //Request Landmark analysis of the image using
        requestImageAnalysis("landmark")
      
        /*
        animateActivityIndicator()

        //Store analysis type
        result?.updateAnalysisType("landmark")
        
        //Initiate analysis of the image and present result on map in landmark case.
        GoogleClient.sharedInstance().requestImageAnalysis(result!) { (success, error, result) in
            if success {
                self.result = result
                self.displayMapView()
            } else {
                self.activityIndicator.stopAnimating()
                self.displayError(error!.localizedDescription)
            }
        }*/
    }
    
    
    // "Face" analysis selected
    @IBAction func faceButtonPressed(sender: AnyObject) {
        //Request Face analysis of the image using
        requestImageAnalysis("face")
    }
}

