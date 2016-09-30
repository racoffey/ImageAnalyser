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
//import SwiftyJSON


// Flickr API client

class GoogleClient : NSObject {
    
    // Shared session
    var session = NSURLSession.sharedSession()
    

    func requestImageAnalysis(image: UIImage, analysisType: String, completionHandlerForSession: (Bool, String?, AnyObject?) -> Void) {
        let image : UIImage = image
        print("Reached request image analaysis: \(image)")
        let imageData = base64EncodeImage(image)
        //let imageData = image
        var jsonBody : [String : AnyObject] = [:]
        var responses = [""]
        
        // Build our API request
        let method = ""
        let parameters : [String: AnyObject] = [Constants.GoogleRequestKeys.ApiKey : Constants.GoogleRequestValues.ApiKey as AnyObject]
        
        switch analysisType {
        case "general":
            jsonBody = [
                "requests": [
                    "image": [
                        "content": imageData
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
                        "content": imageData
                    ],
                    "features": [
                        /*[
                            "type": "LABEL_DETECTION",
                            "maxResults": 10
                        ],
                         [
                         "type": "FACE_DETECTION",
                         "maxResults": 10
                         ],*/
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
                        "content": imageData
                    ],
                    "features": [
                        /*[
                         "type": "LABEL_DETECTION",
                         "maxResults": 10
                         ],
                         [
                         "type": "FACE_DETECTION",
                         "maxResults": 10
                         ],*/
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
                        "content": imageData
                    ],
                    "features": [
                        /*[
                         "type": "LABEL_DETECTION",
                         "maxResults": 10
                         ],*/
                         [
                         "type": "FACE_DETECTION",
                         "maxResults": 10
                         ] /*,
                        [
                            "type": "LANDMARK_DETECTION",
                            "maxResults": 10
                        ]*/
                    ]
                ]
            ]
            
        default: break
        }


        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody as [String : AnyObject], type: "vision") { (results, error) in
            
            // Handle error case
            if error != nil {
                completionHandlerForSession(false, "Failed to get result data. \(error)", "")
            } else {
                //Put results into a data object, extract result information into Annotations object which is returned

                let resultsDict = results as! [String : AnyObject]
                print("ResultsDict: \(resultsDict)")
                let responses = resultsDict["responses"] as! [AnyObject]
                print("Responses: \(responses)")
                let annotations = responses[0]
                print("Annotations : \(annotations)")

            
                
              /*  self.convertStringWithCompletionHandler(responses) { (results, error) in
                    
                    print("Results = \(results)")
                    //let string : [String : String] = results![0] as? [String : AnyObject]
                    //let labelAnnotations  = string["labelAnnotations"] as! [String]
                }*/
                //print(labelAnnotations[0]["description"])
                

                //self.parseText(string as! String)
                
                
                
            //    let dict = resultsDict["responses"]?.covertToJson([String : AnyObject])
                //let textToParse = (array![0]).covertToJson([String : AnyObject])
                //let res = NSString.stringEncodingForData(results, encodingOptions: [String : AnyObject]?, convertedString: AutoreleasingUnsafeMutablePointer<NSString?>, usedLossyConversion: UnsafeMutablePointer<ObjCBool>)
                
                //self.parseText(textToParse)
                
 //               let responses = resultsDict["responses"] as! [String]
/*                guard let responses = resultsDict["responses"] as! [NSData]{
                    let labelNotation = NSJSONSerialization.dataWithJSONObject(responses, options: .AllowFragments)
                }
  */
        //        let responses = resultsDict["responses"] as! [String : AnyObject]
                //let responsesJSON = self.convertDataWithCompletionHandler(responses, completionHandlerForConvertData: completionHandlerForSession)
                //let labelAnnotations = responses["labelAnnotation"] as! [String : AnyObject]
 //               print(responses)
                
/*
                let photoResults = resultsDict["photos"] as! [String: AnyObject]
                let photosArray = photoResults["photo"] as! [AnyObject]
                if photosArray.endIndex == 0 {
                    completionHandlerForSession(success: false, errorString: "No photos are available for this location!")
                }
                
                // Create Core Data Photo object for each photo in array in memory
                for item in photosArray {
                    let dict = item as! [String: AnyObject]
                    
                    let photo = Photo(title: dict["title"] as! String, url_m: dict["url_m"] as! String, context: context)
                    
                    // Define parent Pin in Photo object
                    photo.pin = pin
                    
                    // Download images on background thread and update Core Data Photo object when downloaded
                    performUIUpdatesOnBackground({
                        if let url  = NSURL(string: photo.url_m!),
                            data = NSData(contentsOfURL: url)
                        {
                            photo.image = data
                        }
                    })
                }
                
                // Save changes to Core Data
                //CoreDataStackManager.sharedInstance().save()
 */
                print("About to request translation")
                // Successfully complete session
                      self.requestTranslation("Gamle breve ledte Katrine Koust på sporet af sin biologiske mor i Sri Lanka. Hun endte med at få en helt ny familie, som hun knuselskede fra første øjeblik.", language: "dk") { (success, errorString, response) in
                    if success {
                        print(response!)
                    } else {
                        print(errorString!)
                    }
                 }

                
                completionHandlerForSession(true, nil, annotations)
            }
        }
            
    }
    
    func requestTranslation(text: String, language: String, completionHandlerForSession: (Bool, String?, AnyObject?) -> Void) {
        print("Reached request translation")
        //let imageData = base64EncodeImage(image)
        var jsonBody : [String : AnyObject] = [:]
        let target = "en"
        var responses = [""]
        
        // Build our API request
        let method = ""
        let parameters : [String: AnyObject] = [Constants.GoogleRequestKeys.ApiKey : (Constants.GoogleRequestValues.ApiKey as AnyObject),       Constants.GoogleRequestKeys.Source : language,
            Constants.GoogleRequestKeys.Target : target,
            Constants.GoogleRequestKeys.Text : text]
        
 /*
        switch analysisType {
        case "general":
            jsonBody = [
                "requests": [
                    "image": [
                        "content": imageData
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
                        "content": imageData
                    ],
                    "features": [
                        /*[
                         "type": "LABEL_DETECTION",
                         "maxResults": 10
                         ],
                         [
                         "type": "FACE_DETECTION",
                         "maxResults": 10
                         ],*/
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
                        "content": imageData
                    ],
                    "features": [
                        /*[
                         "type": "LABEL_DETECTION",
                         "maxResults": 10
                         ],
                         [
                         "type": "FACE_DETECTION",
                         "maxResults": 10
                         ],*/
                        [
                            "type": "LANDMARK_DETECTION",
                            "maxResults": 10
                        ]
                    ]
                ]
            ]
            
        default: break
        }
        */
        
        taskForPOSTMethod(method, parameters: parameters, jsonBody: jsonBody as [String : AnyObject], type: "translate") { (results, error) in
            
            // Handle error case
            if error != nil {
                completionHandlerForSession(false, "Failed to get result data. \(error)", "")
            } else {
                //Put results into a data object, extract result information into Annotations object which is returned
                
                let resultsDict = results as! [String : AnyObject]
                print("ResultsDict: \(resultsDict)")
         /*       let responses = resultsDict["responses"] as! [AnyObject]
                print("Responses: \(responses)")
                let annotations = responses[0]
                print("Annotations : \(annotations)")*/
                
                
                
                /*  self.convertStringWithCompletionHandler(responses) { (results, error) in
                 
                 print("Results = \(results)")
                 //let string : [String : String] = results![0] as? [String : AnyObject]
                 //let labelAnnotations  = string["labelAnnotations"] as! [String]
                 }*/
                //print(labelAnnotations[0]["description"])
                
                
                //self.parseText(string as! String)
                
                
                
                //    let dict = resultsDict["responses"]?.covertToJson([String : AnyObject])
                //let textToParse = (array![0]).covertToJson([String : AnyObject])
                //let res = NSString.stringEncodingForData(results, encodingOptions: [String : AnyObject]?, convertedString: AutoreleasingUnsafeMutablePointer<NSString?>, usedLossyConversion: UnsafeMutablePointer<ObjCBool>)
                
                //self.parseText(textToParse)
                
                //               let responses = resultsDict["responses"] as! [String]
                /*                guard let responses = resultsDict["responses"] as! [NSData]{
                 let labelNotation = NSJSONSerialization.dataWithJSONObject(responses, options: .AllowFragments)
                 }
                 */
                //        let responses = resultsDict["responses"] as! [String : AnyObject]
                //let responsesJSON = self.convertDataWithCompletionHandler(responses, completionHandlerForConvertData: completionHandlerForSession)
                //let labelAnnotations = responses["labelAnnotation"] as! [String : AnyObject]
                //               print(responses)
                
                /*
                 let photoResults = resultsDict["photos"] as! [String: AnyObject]
                 let photosArray = photoResults["photo"] as! [AnyObject]
                 if photosArray.endIndex == 0 {
                 completionHandlerForSession(success: false, errorString: "No photos are available for this location!")
                 }
                 
                 // Create Core Data Photo object for each photo in array in memory
                 for item in photosArray {
                 let dict = item as! [String: AnyObject]
                 
                 let photo = Photo(title: dict["title"] as! String, url_m: dict["url_m"] as! String, context: context)
                 
                 // Define parent Pin in Photo object
                 photo.pin = pin
                 
                 // Download images on background thread and update Core Data Photo object when downloaded
                 performUIUpdatesOnBackground({
                 if let url  = NSURL(string: photo.url_m!),
                 data = NSData(contentsOfURL: url)
                 {
                 photo.image = data
                 }
                 })
                 }
                 
                 // Save changes to Core Data
                 //CoreDataStackManager.sharedInstance().save()
                 */
                // Successfully complete session
                completionHandlerForSession(true, nil, resultsDict)
            }        }
        
    }
  /*
    func parseText( text : String) {
        var text = text
        let charSet = NSCharacterSet(charactersIn: ";=")
        var newText : String = ""
        
        for chr in text.characters {
            if chr == "\"" {
                newText + ""
                print(newText)
            }
            else {
                newText.append(chr)
            }
        }
        text = newText
        
        var array = text.componentsSeparatedByCharactersInSet(charSet)
        
        for var item in array{
            print(item)
            let index = array.indexOf(item)
            newText = ""
            for chr in item.characters {
                if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") && !(chr >= "0" && chr <= "9") && !(chr == ".")  ) {
                    print("Reached here")
                    print(chr)
                }
                else {
                    print(chr)
                    newText.append(chr)
                    print(newText)
                }
            }
            print(index)
            array.removeAtIndex(index!)
            array.insert(newText, atIndex: index!)
            
        }
        print(array)
    }
 */
    
    
/*    // Request photos related to Pin location from Flickr
    func getPhotos(context: NSManagedObjectContext, pin: Pin, completionHandlerForSession: (success: Bool, errorString: String?) -> Void) {
        
        // General random page number between 1 and maxPages
        let page = Int(arc4random_uniform(Constants.General.maxPages) + 1)
        
        //Establish parameters for GET request
        let method = ""
        let parameters: [String: AnyObject] =
            [Constants.FlickrRequestKeys.ApiKey : Constants.FlickrRequestValues.ApiKey,
             Constants.FlickrRequestKeys.DataFormat : Constants.FlickrRequestValues.DataFormat,
             Constants.FlickrRequestKeys.Extras : Constants.FlickrRequestValues.Extras,
             Constants.FlickrRequestKeys.NoJsonCallBack : Constants.FlickrRequestValues.NoJsonCallBack,
             Constants.FlickrRequestKeys.PerPage : Constants.FlickrRequestValues.PerPage,
             Constants.FlickrRequestKeys.SafeSearch : Constants.FlickrRequestValues.SafeSearch,
             Constants.FlickrRequestKeys.Method : Constants.FlickrRequestValues.Method,
             Constants.FlickrRequestKeys.Latitude : pin.latitude!,
             Constants.FlickrRequestKeys.Longitude : pin.longitude!,
             Constants.FlickrRequestKeys.Page : page]
        
        
        //Execute GET method
        taskForGETMethod(method, parameters: parameters) { (results, error) in
            
            // Handle error case
            if error != nil {
                completionHandlerForSession(success: false, errorString: "Failed to get photos. \(error)")
            } else {
                //Put results into a data object, extract photos into photoResults and then individual photos into Photos array
                var resultsDict = results as! [String: AnyObject]
                let photoResults = resultsDict["photos"] as! [String: AnyObject]
                let photosArray = photoResults["photo"] as! [AnyObject]
                if photosArray.endIndex == 0 {
                    completionHandlerForSession(success: false, errorString: "No photos are available for this location!")
                }
                
                // Create Core Data Photo object for each photo in array in memory
                for item in photosArray {
                    let dict = item as! [String: AnyObject]
                    
                    let photo = Photo(title: dict["title"] as! String, url_m: dict["url_m"] as! String, context: context)
                    
                    // Define parent Pin in Photo object
                    photo.pin = pin
                    
                    // Download images on background thread and update Core Data Photo object when downloaded
                    performUIUpdatesOnBackground({
                        if let url  = NSURL(string: photo.url_m!),
                            data = NSData(contentsOfURL: url)
                        {
                            photo.image = data
                        }
                    })
                }
                
                // Save changes to Core Data
                CoreDataStackManager.sharedInstance().save()
                
                // Successfully complete session
                completionHandlerForSession(success: true, errorString: nil)
            }
        }
    }
*/
    
    // POST method
    func taskForPOSTMethod(method: String, parameters: [String:AnyObject], jsonBody: [String: AnyObject], type: String, completionHandlerForPOST: (AnyObject?, NSError?) -> Void) -> NSURLSessionDataTask {
        
        
        // Build the URL based on header parameter and json body input
        var parameters = parameters
        var request = NSMutableURLRequest()
        
        switch type {
        case "translate":
            request = NSMutableURLRequest(URL: parseTranslateURLFromParameters(parameters, withPathExtension: method) as NSURL)
        case "vision":
            request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method) as NSURL)
        default:
            break
        }

        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(NSBundle.mainBundle().bundleIdentifier ?? "",forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        //request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        print(request)
        print(request.allHTTPHeaderFields)
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
    

    
    
 /*
    // GET method
    func taskForGETMethod(method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        //Construct the URL request using input parameters
        let request = NSMutableURLRequest(URL: parseURLFromParameters(parameters, withPathExtension: method))
        
        //Prepare the request task
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print("Error : \(error)")
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            //Was there an error?
            guard (error == nil) else {
                sendError("The HTTP GET request failed. Check network connection!")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                //self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForGET)
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Parse the data and use the data and return the result
            self.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        // Execute the request
        task.resume()
        
        return task
    }
  */
    
    // Assisting functions
 /*
    // Create JSON string based on parameters dictionary
    func covertToJson (parameters: [String: AnyObject]) -> String {
        var jsonBody: String = "{"
        var newValue: String
        for (key, value) in parameters {
            print("Key = \(key)")
            print("Value = \(value)")
            if value is Double {
                newValue = String(_cocoaString: value)
                let string: String = ("\"\(key)\": \(newValue), ")
                jsonBody.appendContentsOf(string)
            }
            else {
                newValue = value as! String
                let string: String = ("\"\(key)\": \"\(newValue)\", ")
                jsonBody.appendContentsOf(string)
            }
        }
        //Last comma and space removed and brace added
        jsonBody.remove(at: jsonBody.endIndex.index(before:))
        jsonBody.remove(at: jsonBody.endIndex.index(before:))
        jsonBody.append("}")
        return jsonBody
    }
  */
    
    // Create a URL from parameters
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
        
        //Attempt to parse data and report error if failure
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data as NSData, options: .MutableContainers)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        // Return parsed result
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // Parse raw JSON to NS object
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
