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

class AnalysisSelectorViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    
    var image: UIImage?
    
    // Instantiate Analysis Result
    var result : AnalysisResult? = nil
    
    // Get context from shared instance from CoreDataStackManager
    var sharedContext = CoreDataStackManager.sharedInstance().context

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var generalButton: UIBarButtonItem!
    @IBOutlet weak var textButton: UIBarButtonItem!
    @IBOutlet weak var landmarkButton: UIBarButtonItem!
    @IBOutlet weak var faceButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mapView: MKMapView!


    override func viewWillAppear(animated: Bool) {
        
        image = UIImage(data: (result?.image)!)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = image
        activityIndicator.hidden = true
        activityIndicator.hidesWhenStopped = true

        if result?.labelText != nil {
            if result?.analysisType == "landmark" {
              displayMapView()
            } else {
            textView.text = result?.labelText
            }
        } else {
            textView.text = "Select analysis type"
        }

        textView.hidden = false
        mapView.hidden = true

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.mapView.delegate = self



    }

    //Present message to user
    func displayError(error: String, debugLabelText: String? = nil) {
        print(error)
        
        // Show error to user using Alert Controller
        let alert = UIAlertController(title: "Information", message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

    
    func displayResponse(){
        performUIUpdatesOnMain ({
            self.activityIndicator.stopAnimating()
            self.textView.hidden = false
            self.textView.text = self.result!.labelText
            self.textView.reloadInputViews()
        })
    }
    
    func displayMapView() {
        let dropPin = MKPointAnnotation()
        dropPin.coordinate = (result?.coordinate)!
        let mapLocation = CLLocation(latitude: (result!.latitude), longitude: (result!.longitude))
        
        let wikiURL = Constants.WikipediaRequestValues.wikipediaURL + removeWhiteSpace(result!.labelText!)
     //   let wikiURL = Constants.WikipediaRequestValues.wikipediaURL + result!.labelText!
        dropPin.title = result!.labelText! + (", \((result?.country)!)")
        dropPin.subtitle = wikiURL
        performUIUpdatesOnMain ({
            self.textView.hidden = true
            self.mapView.hidden = false
            //self.mapView.setCenterCoordinate(location!, animated: true)
            self.centerMapOnLocation(mapLocation)
            self.mapView.addAnnotation(dropPin)
            self.mapView.selectAnnotation(dropPin, animated: true)
        })
    }
    
    func animateActivityIndicator(){
        performUIUpdatesOnMain ({
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
            self.textView.hidden = false
            self.textView.text = "Image being analysed..."
            self.textView.reloadInputViews()
        })
    }
 /*
    func getCityFromLocation(location : CLLocation) -> String {

        let geoCoder = CLGeocoder()
        var cityCountryString = ""
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            // Place details
            var placeMark: CLPlacemark!
            print("Placemark = \(placeMark)")
            placeMark = placemarks?[0]
            
            // Address dictionary
            print(placeMark.addressDictionary)
            
            // Location name
            if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                print(locationName)
            }
            
            // Street address
            if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                print(street)
            }
            
            // City
            if let city = placeMark.addressDictionary!["City"] as? String {
                print(city)
                self.result!.updateCity(city)
            }
            
            // Zip code
            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                print(zip)
            }
            
            // Country
            if let country = placeMark.addressDictionary!["Country"] as? String {
                print(country)
                self.result!.updateCountry(country)
            }

            
        })
        return cityCountryString
    } */
 
    func removeWhiteSpace(var string : String) -> String {
        print("String with whitespace: \(string)")
        string = string.stringByReplacingOccurrencesOfString(" ", withString: "_")
        if string.characters.first == "_" {
            string.removeAtIndex(string.startIndex)
        }
        if string.characters.last == "_" {
            string.removeAtIndex(string.endIndex)
        }
        print("String with no whitespace: \(string)")
        return string
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        //Use Student Location as annotation object, create annotation view and assign queued annotations if possible
        //     if let annotation = annotation as? StudentLocation {
        let identifier = "pin"
        var view: MKPinAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
            as? MKPinAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            //If queued annotations not availabel then create new with call out and accessory
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -10, y: 10)
            view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
        }
        //Return the annotation view
        return view
        //    }
        //    return nil
    }
    
    //Set map view region
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  Constants.Map.RegionRadius * 2.0, Constants.Map.RegionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool){
        activityIndicator.stopAnimating()

    }
    
    //If call out it tapped then open URL link in Student Location
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!,
                 calloutAccessoryControlTapped control: UIControl!) {
        
        
        //let annotation = view.annotation
        print("Call out was pressed")
        print("URL =  \(view.annotation?.subtitle!)")
        //let wikiURL = (view.annotation?.subtitle!)! as String  https://en.wikipedia.org/wiki/Skógafoss
        let wikiURL = ((view.annotation?.subtitle!)! as String).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        print(wikiURL)
        if let url = NSURL(string: wikiURL) {
            print("Url being opened = \(url)")
            UIApplication.sharedApplication().openURL(url, options: [ : ]) { (success) in
                if success {
                    print ("URL opened")
                } else {
                    self.displayError("Cannot present web page")
                }
            }
        } else {
            displayError("Cannot present web page")
        }
/*        print("Url being opened = \(url)")
        UIApplication.sharedApplication().openURL(url!, options: [ : ]) { (success) in
            if success {
                print ("URL opened")
            } else {
                self.displayError("Cannot present web page")
            }
        }*/
/*
        do {
            let url = try NSURL(fileURLWithPath: wikiURL)
            print("Url being opened = \(url)")
            UIApplication.sharedApplication().openURL(url)
        } catch is ErrorType {
            displayError("Cannot present web page")
        }
        
*/
        
        //Check URL is properly formatted and if not present error on map
        /*if let url = NSURL(fileURLWithPath: wikiURL) {
            print("Url being opened = \(url)")
            UIApplication.sharedApplication().openURL(url)
        }
        else {
            displayError("Cannot present web page")
        }*/
    }

    @IBAction func generalButtonPressed(sender: AnyObject) {
        print("Reached Button Pressed")
        animateActivityIndicator()
        result?.updateAnalysisType("general")
        GoogleClient.sharedInstance().requestImageAnalysis(result!) { (success, error, result) in
            if success {
                self.result = result
                print("Image label = \(result?.labelText)")
                self.displayResponse()
            } else {
                self.displayError(error.localizedDescription)
            }
        }
    }
    
    @IBAction func textButtonPressed(sender: AnyObject) {
        print("Text Button Pressed")
        animateActivityIndicator()
        result?.updateAnalysisType("text")
        GoogleClient.sharedInstance().requestImageAnalysis(result!) { (success, error, result) in
            if success {
                self.result = result
                print("Image label = \(result?.labelText)")
                self.displayResponse()
            } else {
                self.displayError(error.localizedDescription)
            }
        }
        displayResponse()
    }
    
    @IBAction func landmarkButtonPressed(sender: AnyObject) {
        print("Landmark Button Pressed")
        animateActivityIndicator()
        print("Image in landmark Button pressed: \(self.image!)")
        result?.updateAnalysisType("landmark")
        GoogleClient.sharedInstance().requestImageAnalysis(result!) { (success, error, result) in
            if success {
                self.result = result
              //  self.getCityFromLocation(CLLocation(latitude: (result!.latitude), longitude: (result!.longitude))) { () in
          /*      var newLabelText = result?.labelText
                print("City : \(result!.city)")
                print("Country : \(result!.country)")
                //newLabelText = newLabelText! + ",\(result!.city!)"
                //newLabelText = newLabelText! + ", \(result!.country!)"
                result?.updateLabelText(newLabelText!)
                */
                self.displayMapView()
            } else {
                self.displayError(error.localizedDescription)
            }
        }

    }
    
    
    @IBAction func faceButtonPressed(sender: AnyObject) {
        print("Face Button Pressed")
        animateActivityIndicator()
        print("Image in face Button pressed: \(self.image!)")
        
        result?.updateAnalysisType("face")
        GoogleClient.sharedInstance().requestImageAnalysis(result!) { (success, error, result) in
            if success {
                self.result = result
                print("Image label = \(result?.labelText)")
                self.displayResponse()
            } else {
                self.displayError(error.localizedDescription)
            }
        }
    }
    
    @IBAction func translatedButtonPressed(sender: AnyObject) {
        print("Translate Button Pressed")
        let stringToTranslate = "Hola, soy Robert. Pero creo que si"
        let language = "es"
        performUIUpdatesOnMain ({
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
            self.textView.hidden = false
            self.textView.text = "Text being translated being analysed..."
            self.textView.reloadInputViews()
        })
        //print("Image in face Button pressed: \(self.image!)")
        GoogleClient.sharedInstance().requestTranslation(stringToTranslate, language: language) { (success, errorString, result) in
            if success {
                self.displayResponse()
            } else {
                self.displayError(errorString!)
            }
        }
    }
    
    
}

