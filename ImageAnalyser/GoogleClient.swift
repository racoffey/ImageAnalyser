//
//  GoogleClient.swift
//  ImageAnalyser
//
//  Created by Robert Coffey on 20/08/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import MapKit



// Client for handling Google Vision API and Google Translate API interactions and returning a prepared response

class GoogleClient : NSObject {
    
    // Shared session
    var session = NSURLSession.sharedSession()
    
    
    // Request image analysis and return a result object populated with information from JSON response
    func requestImageAnalysis(result : AnalysisResult, completionHandlerForSession: (success: Bool, error: NSError?, result: AnalysisResult?) -> Void) {
        
        // Extract image from result object and encode to required JSON format
        let imageData = result.image?.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
 
        // Extract analysisType from result object
        let analysisType = result.analysisType!
        
        // Initialise jsonBody
        var jsonBody : [String : AnyObject] = [:]
        
        // Build the Google Vision API request depending on the selected analysisType
        let method = ""
        let parameters : [String: AnyObject] = [Constants.GoogleRequestKeys.ApiKey : Constants.GoogleRequestValues.ApiKey as AnyObject]
        
        switch analysisType {
        case "general":
            jsonBody = [
                "requests": [
                    "image": [
                        "content": imageData!
                    ],
                    "features": [
                        [
                            "type": "LABEL_DETECTION",
                            "maxResults": 10
                        ]
                    ]
                ]
            ]
        case "text":
            jsonBody = [
                "requests": [
                    "image": [
                        "content": imageData!
                    ],
                    "features": [
                         [
                         "type": "TEXT_DETECTION",
                         "maxResults": 0
                         ]
                    ]
                ]
            ]
            
        case "landmark":
            jsonBody = [
                "requests": [
                    "image": [
                        "content": imageData!
                    ],
                    "features": [
                        [
                            "type": "LANDMARK_DETECTION",
                            "maxResults": 10
                        ]
                    ]
                ]
            ]
            
        case "face":
            jsonBody = [
                "requests": [
                    "image": [
                        "content": imageData!
                    ],
                    "features": [
                        [
                         "type": "LABEL_DETECTION",
                         "maxResults": 10
                         ],
                         [
                         "type": "FACE_DETECTION",
                         "maxResults": 10
                         ]
                    ]
                ]
            ]
            
        default: break
        }

        // Execute HTTP POST transaction
        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody as [String : AnyObject], type: "vision") { (results, error) in
            
            // Handle error case
            if error!.code == 1 {
                completionHandlerForSession(success: true, error: error!, result: result)
            } else {
                
                //Extract the annotations from the JSON response
                let resultsDict = results as! [String : AnyObject]
                let responses = resultsDict["responses"] as! [AnyObject]
                let annotations = responses[0]

                // Transfer received JSON response annotations into result object and return result
                self.prepareResponse(annotations, result: result) { (success, error, result) in
                    if success {
                        completionHandlerForSession(success: true, error: nil, result: result)
                    } else {
                        completionHandlerForSession(success: false, error: error!, result: nil)
                    }
                }
            }
        }
    }
    
    // Transfer received JSON response annotations into AnalysisResult object
    func prepareResponse(response : AnyObject, result : AnalysisResult, completionHandlerForSession: (success : Bool, error : NSError?, result : AnalysisResult?) -> Void) {
        
        // Instantiate labelText
        var labelText : String = ""
        
        // Set default language as English
        var language = "en"
        
        // Instantiate counters for cycling through annotations
        var count = 0
        var number = 0
        
        // Assign map location variable
        var location = CLLocation()
    
        // Check JSON response dictionary for labelAnnotations and if found extract relevant labels
        if (response["labelAnnotations"]!) != nil {
            
            // Instantiate String for image labels and add heading
            var imageLabels : String = "IMAGE LABELS\n\n"
            
            //Extract labelAnnotations array from response dictionary
            let labelAnnotations = response["labelAnnotations"] as! [AnyObject]

            // Cycle through labelAnnotations array adding text to the imageLabels string
            if labelAnnotations.count != 0 {
                count  = 0
                number = labelAnnotations.count
                
                while count < number {
                    let dict = labelAnnotations[count]
                    let str = dict["description"]!
                    
                    if count == number-1 {
                        imageLabels.appendContentsOf("\(str!).")
                    } else {
                        imageLabels.appendContentsOf("\(str!), ")
                    }
                    count += 1
                }
            }
            
            // Assign imageLabels to labelText for presentation to end user
            labelText = imageLabels
            
            //Update result object
            result.updateImageText(imageLabels)

        }
        
        // Check JSON response dictionary for textAnnotations and if found extract text.
        // If text is not English then automatically provide an English translation of the text
        if (response["textAnnotations"]!) != nil {
            
            //Instantiate string for image text and add heading
            var imageText = "IMAGE TEXT\n\n"
            
            //Extract textAnnotations from response dictionary
            let textAnnotations = response["textAnnotations"] as! [AnyObject]
            
            let dict = textAnnotations[0]
            let text = dict["description"]! as! String
            language = dict["locale"]! as! String
            
            // Add text to imageText string and update result object
            imageText.appendContentsOf(text)
            result.updateImageText(imageText)

            // Language is not English then translate text to English
            if language != "en" {

                // Request transation to English and return result when translation has been received
                requestTranslation(result.imageText!, language: language) { (success, error, textTranslation) in
                    if success{
                        
                        // Update result object with translated text and new Label Text for user display
                        result.updateTranslatedText(textTranslation as! String)
                        let newLabelText = "\(result.imageText!) \n" + " TRANSLATED TEXT\n\n" + result.translatedText! 
                        result.updateLabelText(newLabelText)
                        completionHandlerForSession(success: true, error: nil, result: result)
                    }
                    else {
                        //Return result
                        completionHandlerForSession(success: false, error: error, result: nil)
                    }
                }
            } else {
                // Assign imageText content to display text
                labelText.appendContentsOf(imageText)
                
                // Return result
                completionHandlerForSession(success: true, error: nil, result: result)
            }
        }
        
        
        // Check JSON response dictionay for landmarkAnnotations.  
        // If found extract landmark name and location, plot on a map with annotation showing country and Wikipedia link
        if (response["landmarkAnnotations"]!) != nil {
            
            // Extract landmarkAnnotations from response dictionary
            let landmarkAnnotations = response["landmarkAnnotations"] as! [AnyObject]
            let dict = landmarkAnnotations[0]
            
            // Extract landmark name and location
            let landmarkLabel = dict["description"]! as! String
            let locations = dict["locations"] as! [AnyObject]
            let latLng = locations[0]
            let coordinates = latLng["latLng"]!
            let latitude = coordinates!["latitude"] as! Double
            let longitude = coordinates!["longitude"] as! Double
            
            // Update result plus labelText and location
            result.updateLandmarkLabel(landmarkLabel)
            result.updateCoodinates(latitude, longitude: longitude)
            labelText.appendContentsOf(landmarkLabel)
            location = CLLocation(latitude: latitude, longitude: longitude)
            
            // Get the city and country for the landmark and when obtained return the result
            getCityAndCountry(location, result: result) { (success, error, result) in
                if error == nil {
                    completionHandlerForSession(success: true, error: nil, result: result)
                } else {
                    completionHandlerForSession(success: false, error: error, result: nil)
                }
            }
        }
        
        // Check JSON response for faceAnnotations and if found extract relevant content
        if (response["faceAnnotations"]!) != nil {
            
            //Instantiate string for faceLabels and add heading
            var faceLabels = "\n\n EMOTIONS \n\n"
            
            //Extract faceLabels from JSON response
            let faceAnnotations = response["faceAnnotations"] as! [AnyObject]
            let dict = faceAnnotations[0]
            let angerLikelihood = dict["angerLikelihood"]!
            faceLabels.appendContentsOf(" \n\n EMOTIONS \n\n Anger: \(angerLikelihood!)")
            let joyLikelihood = dict["joyLikelihood"]!
            faceLabels.appendContentsOf(" \n Joy: \(joyLikelihood!)")
            let sorrowLikelihood = dict["sorrowLikelihood"]!
            faceLabels.appendContentsOf(" \n Sorrow: \(sorrowLikelihood!)")
            let surpriseLikelihood = dict["surpriseLikelihood"]!
            faceLabels.appendContentsOf(" \n Surprise: \(surpriseLikelihood!)")
            
            // Add faceLabels Labels to labelText for presentation to end user
            labelText.appendContentsOf(faceLabels)
            
            //Update result object
            result.updateFaceLabels(faceLabels)
        }
            
        if labelText == "" {
            labelText = "Analysis yeilded no labels for this image."
        }
        
        // Update result with final labelText for end user display and return result
        result.updateLabelText(labelText)
        completionHandlerForSession(success: true, error: nil, result: result)

    }

    
    
    func requestTranslation(text: String, language: String, completionHandlerForSession: (Bool, NSError?, AnyObject?) -> Void) {
        print("Reached request translation")
        //let imageData = base64EncodeImage(image)
        //var localError = NSError(domain: "com.udacity.imageanalyser", code: 0, userInfo: [:])
        var jsonBody : [String : AnyObject] = [:]
        let target = "en"
        var responses = [""]
        
        // Build our API request
        let method = ""
        let parameters : [String: AnyObject] = [
            Constants.GoogleRequestKeys.ApiKey : Constants.GoogleRequestValues.ApiKey,
            Constants.GoogleRequestKeys.Source : language,
            Constants.GoogleRequestKeys.Target : target,
            Constants.GoogleRequestKeys.Text : text,
             ]
        
        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody as [String : AnyObject], type: "translate") { (results, error) in
            
            // Handle error case
            if error!.code == 1 {
                completionHandlerForSession(false, error, nil)
                //let resultsDict = error as! [String : AnyObject]
                //print("Error: \(error)")
            } else {
                //Put results into a data object, extract result information into Annotations object which is returned
                
                let resultsDict = results as! [String : AnyObject]
                print("ResultsDict: \(resultsDict)")
                let data = resultsDict["data"]! as AnyObject
                print("Data: \(data)")
                let translations = data["translations"]!! as AnyObject
                print("Translations: \(translations)")
                let translatedTextDict = translations[0]! as AnyObject
                print("TranslatedTextDict: \(translatedTextDict)")
                let translatedText = translatedTextDict["translatedText"]! as! String
                print("TranslatedText: \(translatedText)")

        
                // Successfully complete session
                completionHandlerForSession(true, nil, translatedText)
            }
        }
    }
 
    
    // POST method
    func taskForPOSTMethod(method: String, parameters: [String:AnyObject], jsonBody: [String: AnyObject], type: String, completionHandlerForPOST: (AnyObject?, NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        // Build the URL based on header parameter and json body input
        var parameters = parameters
        var request = NSMutableURLRequest()
        
        // Build request using different parameters depending if the Google Vision or Translate API is being used.
        // X-HTTP-Method-Override GET is required for Translate API.
        switch type {
        case "translate":
            request = NSMutableURLRequest(URL: parseTranslateURLFromParameters(parameters, withPathExtension: method) as NSURL)
            request.addValue("GET", forHTTPHeaderField: "X-HTTP-Method-Override")
        case "vision":
            request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method) as NSURL)
        default:
            break
        }
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(NSBundle.mainBundle().bundleIdentifier ?? "",forHTTPHeaderField: "X-Ios-Bundle-Identifier" )
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        print("Request : \(request)")
        print("All HTTP header fields : \(request.allHTTPHeaderFields)")
        // Prepare request task
        let task = session.dataTaskWithRequest(request as NSURLRequest) { (data, response, error) in
            
            func sendError(error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                sendError("The POST method failed. \(error)")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode   where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your POST request returned a status code other than 2xx!")
                print("Status code : \((response as? NSHTTPURLResponse)?.statusCode)")
                print("Response : \(response)")
                print("Error : \(error)")
                print("Data : \(data)")
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the POST request!")
                return
            }
            
            
            // Parse the data and return the resulting data
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        //Initiate the request
        task.resume()
        
        return task
    }
    

    
 
    
    // ASSISTING FUNCTIONS
 
    
    // Create Goolge Vision URL from parameters
    func parseURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Google.ApiScheme
        components.host = Constants.Google.ApiHost
        components.path = Constants.Google.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]() as [NSURLQueryItem]?
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem as NSURLQueryItem)
        }
        return components.URL! as NSURL
    }
    
    // Create Google Translate URL from parameters
    func parseTranslateURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Google.ApiScheme
        components.host = Constants.Google.ApiHostTranslate
        components.path = Constants.Google.ApiPathTranlate + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]() as [NSURLQueryItem]?
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem as NSURLQueryItem)
        }
        return components.URL! as NSURL
    }
    
    
    // Parse raw JSON to NS object
    private func convertDataWithCompletionHandler(data: NSData, completionHandlerForConvertData: (AnyObject?, NSError?) -> Void) {
        
        var parsedResult: AnyObject?
        //let error = NSError(domain: "Imageanalyser", code: 0, userInfo: [:])
        
        //Attempt to parse data and report error if failure
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data as NSData, options: .MutableContainers)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON"]
            completionHandlerForConvertData("", NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        // Return parsed result
        completionHandlerForConvertData(parsedResult!, nil)
    }
    
/*    // Parse raw JSON to NS object
    private func convertStringWithCompletionHandler(json: String, completionHandlerForConvertData: (AnyObject?, NSError?) -> Void) {

        var parsedResult: AnyObject?
        
        if let data = json.dataUsingEncoding(NSUTF8StringEncoding) {
            //Attempt to parse data and report error if failure
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)
            } catch {
                let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON"]
                completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
            }
            // Return parsed result
            completionHandlerForConvertData(parsedResult, nil)
        }
        let userInfo = [NSLocalizedDescriptionKey : "Could not encode string to data."]
        completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
    }
*/
    
    // Adjust image size to size accepted by Google Vision API
    func resizeImage(imageSize: CGSize, image: UIImage) -> NSData {
        UIGraphicsBeginImageContext(imageSize)
        image.drawInRect(CGRectMake(0, 0, imageSize.width, imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage! as NSData
    }
    
    func base64EncodeImage(image: UIImage) -> String {
        print("Image = \(image)")
        var imagedata = UIImagePNGRepresentation(image)
        //var imagedata = UIImageJPEGRepresentation(image, 1)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata!.length > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSizeMake(800, oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image) as NSData
        }
        
        return imagedata!.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
    }
    
    func base64EncodeImageToNSData(image: UIImage) -> NSData {
        var imagedata = UIImagePNGRepresentation(image)
        //var imagedata = UIImageJPEGRepresentation(image, 1)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata!.length > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSizeMake(800, oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image) as NSData
        }
        return imagedata!
    }
    

    
    // Using the geoCoder find country and nearest city for landmark and return result
    func getCityAndCountry(location : CLLocation, result : AnalysisResult, completionHandlerForSession: (Bool, NSError?, AnalysisResult?) -> Void) {
        
        let geoCoder = CLGeocoder()
        //var country = ""
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in

            if error == nil {
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                
  /*              // Address dictionary
                print(placeMark.addressDictionary)
                
                // Location name
                if let locationName = placeMark.addressDictionary!["Name"] as? NSString {
                    print(locationName)
                }
                
                // Street address
                if let street = placeMark.addressDictionary!["Thoroughfare"] as? NSString {
                    print(street)
                }
                */
                // Update result with city
                if let city = placeMark.addressDictionary!["City"] as? String {
                    print(city)
                    result.updateCity(city)
                }
                
/*                // Zip code
                if let zip = placeMark.addressDictionary!["ZIP"] as? NSString {
                    print(zip)
                }
                */
                // Update result with country
                if let country = placeMark.addressDictionary!["Country"] as? String {
                    print(country)
                    result.updateCountry(country)
                }
                completionHandlerForSession(true, nil, result)
            } else {
                completionHandlerForSession(false, error, nil)
            }
        }
    }
    
    
 /*   func convertStringToDictionary(json: String) -> [String: AnyObject]? {
        let newJSON : String?
        if let data = json.dataUsingEncoding(NSUTF8StringEncoding) {
            var error: NSError?
            do {
                try newJSON = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? [String: AnyObject]
            } catch  {
                print("error when trying to serialize JSON data")
            }
            
            try {
                newJSON = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(), error: &error) as? [String: AnyObject]
            } catch {
                
            }
            if let error = error {
                print(error)
            }
            return json
        }
        return nil
    }
    */
    
    // Shared Instance
    
    class func sharedInstance() -> GoogleClient {
        struct Singleton {
            static var sharedInstance = GoogleClient()
        }
        return Singleton.sharedInstance
    }
}
