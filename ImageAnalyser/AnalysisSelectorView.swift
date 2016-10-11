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
    
    // Instantiate Result
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
        print("Image in Analysis View Controller is : \(self.parentViewController)")
        image = UIImage(data: (result?.image)!)
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        imageView.image = image
        activityIndicator.hidden = true
        activityIndicator.hidesWhenStopped = true
        textView.text = "Select analysis type"
        if result?.labelText != nil {
            if result?.analysisType == "landmark" {
              displayMapView()
            } else {
            textView.text = result?.labelText
            }
        }
        
        print("Textview text = \(textView.text)")
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
    
 /*   func displayResponse(response : AnyObject){
        var labelText : String = ""
        var count = 0
        var number = 0
        var location = CLLocationCoordinate2D?()
        var landmark = false
        
        //let response = annotations as! [String : String]
        print("Reponse in displayResponse : \(response)")
        
        if (response["labelAnnotations"]!) != nil {
            var imageText : String = ""
            let labelAnnotations = response["labelAnnotations"] as! [AnyObject]
            print("LabelAnnotations in displayResponse : \(labelAnnotations)")
            print("Number of items in labelAnnotations = \(labelAnnotations.count)")
            if labelAnnotations.count != 0 {
                count  = 0
                number = labelAnnotations.count
                print("Number : \(number)")
                print(labelAnnotations)
                imageText = "IMAGE LABELS:\n"
                while count < number {
                    print("Count : \(count)")
                    print("Label text : \(imageText)")
                    let dict = labelAnnotations[count]
                    let str = dict["description"]!
                    
                    if count == number-1 {
                        imageText.appendContentsOf("\(str!).")
                    } else {
                        imageText.appendContentsOf("\(str!), ")
                    }
                    count += 1
                }
            }
            labelText = imageText
            result?.updateImageText(imageText)
            print(labelText)
        } else {
            print("Response contains no lable annotations")
        }
        
        if (response["textAnnotations"]!) != nil {
            let textAnnotations = response["textAnnotations"] as! [AnyObject]
            print("TextAnnotations in displayResponse : \(textAnnotations)")
            print("Number of items in textAnnotations = \(textAnnotations.count)")
        
            labelText = "IMAGE TEXT:\n"
            let dict = textAnnotations[count]
            let str = dict["description"]!
            labelText.appendContentsOf(" \(str!)")
            
            print(labelText)
        } else {
            print("No text annotations in response")
        }
        
        if (response["landmarkAnnotations"]!) != nil {
            let landmarkAnnotations = response["landmarkAnnotations"] as! [AnyObject]
            print("LandmarkAnnotations in displayResponse : \(landmarkAnnotations)")
            
            //labelText = "LANDMARK: "
            let dict = landmarkAnnotations[count]
            let str = dict["description"]!
            labelText.appendContentsOf(" \(str!)")
            print(labelText)
            
            let locations = dict["locations"] as! [AnyObject]
            print("Locations = \(locations)")
            let latLng = locations[0]
            print("Latlng = \(latLng)")
            let coordinates = latLng["latLng"]!
            print("Coordinates = \(coordinates)")
            let latitude = coordinates!["latitude"] as! Double
            let longitude = coordinates!["longitude"] as! Double
            print("latitude = \(latitude)")
            print("longitude = \(longitude)")
            location = CLLocationCoordinate2DMake(latitude, longitude)
            landmark = true
            
        } else {
            print("No landmark annotations in response")
        }
        
        if (response["faceAnnotations"]!) != nil {
            let faceAnnotations = response["faceAnnotations"] as! [AnyObject]
            print("FaceAnnotations in displayResponse : \(faceAnnotations)")
            
            //labelText = "LANDMARK: "
            let dict = faceAnnotations[0]
            let angerLikelihood = dict["angerLikelihood"]!
            labelText.appendContentsOf(" \n\n EMOTIONS: \n Anger: \(angerLikelihood!)")
            let joyLikelihood = dict["joyLikelihood"]!
            labelText.appendContentsOf(" \n Joy: \(joyLikelihood!)")
            let sorrowLikelihood = dict["sorrowLikelihood"]!
            labelText.appendContentsOf(" \n Sorrow: \(sorrowLikelihood!)")
            let surpriseLikelihood = dict["surpriseLikelihood"]!
            labelText.appendContentsOf(" \n Surprise: \(surpriseLikelihood!)")
            print(labelText)
            
/*            let angerLikelihood = dict["angerLikelihood"] as! [AnyObject]
            print("AngerLikelihood = \(angerLikelihood)")
            let joyLikelihood = dict["joyLikelihood"] as! [AnyObject]
            print("AngerLikelihood = \(joyLikelihood)")*/
            /*let latLng = locations[0]
            print("Latlng = \(latLng)")
            let coordinates = latLng["latLng"]!
            print("Coordinates = \(coordinates)")
            let latitude = coordinates!["latitude"] as! Double
            let longitude = coordinates!["longitude"] as! Double
            print("latitude = \(latitude)")
            print("longitude = \(longitude)")
            location = CLLocationCoordinate2DMake(latitude, longitude)
            landmark = true*/
            
        } else {
            print("No face annotations in response")
        }

/*
        if response["textAnnotations"] != nil {
            let textAnnotations = response["textAnnotations"] as! [AnyObject]
            print("TextAnnotations in displayResponse : \(textAnnotations)")
            print("Number of items in labelAnnotations = \(textAnnotations.count)")
            if textAnnotations.count != 0 {
                count  = 0
                number = textAnnotations.count
                print("Number : \(number)")
                print(labelAnnotations)
                labelText = "/n TEXT IN IMAGE: "
                while count < number {
                    let dict = textAnnotations[count]
                    let str = dict["description"]!
                    labelText.appendContentsOf(" \(str!)")
                    count += 1
                }
            }
        } else {
            print("No text in image")
        }*/
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
        
        if landmark {
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = location!
            let mapLocation = CLLocation(latitude: (location!.latitude), longitude: (location!.latitude))
            
            print(getCityFromLocation(mapLocation))
            
            let wikiURL = Constants.WikipediaRequestValues.wikipediaURL + removeWhiteSpace(labelText)
            dropPin.title = labelText
            dropPin.subtitle = wikiURL
            performUIUpdatesOnMain ({
                self.textView.hidden = true
                self.mapView.hidden = false
                //self.mapView.setCenterCoordinate(location!, animated: true)
                self.centerMapOnLocation(mapLocation)
                self.mapView.addAnnotation(dropPin)
                self.mapView.selectAnnotation(dropPin, animated: true)
            })
        } else {
            performUIUpdatesOnMain ({
                self.activityIndicator.stopAnimating()
                self.textView.hidden = false
                self.textView.text = labelText
                self.textView.reloadInputViews()
            })
        }
    }*/
    
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
        
        print(getCityFromLocation(mapLocation))
        
        let wikiURL = Constants.WikipediaRequestValues.wikipediaURL + removeWhiteSpace(result!.labelText!)
        dropPin.title = result!.labelText
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
            if let city = placeMark.addressDictionary!["City"] as? NSString {
                print(city)
                cityCountryString.appendContentsOf(city as String)
            }
            
            // Zip code
            if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                print(zip)
            }
            
            // Country
            if let country = placeMark.addressDictionary!["Country"] as? NSString {
                print(country)
                cityCountryString.appendContentsOf(", " + (country as String))
            }

            
        })
        return cityCountryString
    }
    
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
        GoogleClient.sharedInstance().requestImageAnalysis(result!) { (success, errorString, result) in
            if success {
                self.result = result
                print("Image label = \(result?.labelText)")
                self.displayResponse()
            } else {
                self.displayError(errorString!)
            }
        }
    }
    
    @IBAction func textButtonPressed(sender: AnyObject) {
        print("Text Button Pressed")
        animateActivityIndicator()
        result?.updateAnalysisType("text")
        GoogleClient.sharedInstance().requestImageAnalysis(result!) { (success, errorString, result) in
            if success {
                self.result = result
                print("Image label = \(result?.labelText)")
                self.displayResponse()
            } else {
                self.displayError(errorString!)
            }
        }
        displayResponse()
    }
    
    @IBAction func landmarkButtonPressed(sender: AnyObject) {
        print("Landmark Button Pressed")
        animateActivityIndicator()
        print("Image in landmark Button pressed: \(self.image!)")
        result?.updateAnalysisType("landmark")
        GoogleClient.sharedInstance().requestImageAnalysis(result!) { (success, errorString, result) in
            if success {
                self.result = result
                self.displayMapView()
            } else {
                self.displayError(errorString!)
            }
        }

    }
    
    
    @IBAction func faceButtonPressed(sender: AnyObject) {
        print("Face Button Pressed")
        animateActivityIndicator()
        print("Image in face Button pressed: \(self.image!)")
        
        result?.updateAnalysisType("face")
        GoogleClient.sharedInstance().requestImageAnalysis(result!) { (success, errorString, result) in
            if success {
                self.result = result
                print("Image label = \(result?.labelText)")
                self.displayResponse()
            } else {
                self.displayError(errorString!)
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

