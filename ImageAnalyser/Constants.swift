//
//  Constants.swift
//  ImageAnalyser
//
//  Created by Robert Coffey on 20/08/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//


import Foundation
import UIKit
import MapKit

// Constants

struct Constants {
    
    // General constants
    struct General {
        static let maxPages : UInt32 = 100
    }
    
    // Core data model constants
    struct CDModel {
        static let ModelName = "Model"
        static let SQLFileName = "Model.sqlite"
    }
    
    
    // Google URL API parameters
    struct Google {
        static let ApiScheme = "https"
        static let ApiHost = "vision.googleapis.com"
        static let ApiPath = "/v1/images:annotate"
        
        static let ApiHostTranslate = "www.googleapis.com"
        static let ApiPathTranlate = "/language/translate/v2"
    }
    
    
    // Google request keys
    struct GoogleRequestKeys {
        static let ApiKey = "key"
        static let DataFormat = "format"
        static let BundleIdentifier = "X-Ios-Bundle-Identifier"
        static let Source = "source"
        static let Target = "target"
        static let Text = "q"
        
        static let NoJsonCallBack = "nojsoncallback"
        static let Extras = "extras"
        static let SafeSearch = "safe_search"
        static let PerPage = "per_page"
        static let BoundingBox = "bbox"
        static let Method = "method"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let Radius = "radius"
        static let Page = "page"
    }
    
    // Google request values
    struct GoogleRequestValues {
        static let ApiKey = "Google API here"
        static let DataFormat = "json"
        static let BundleIdentifer = ""
        
        static let NoJsonCallBack = "1"
        static let Extras = "url_m,date_taken"
        static let SafeSearch = "1"
        static let PerPage = "12"
        static let Method = "flickr.photos.search"
    }
    
    //Wikipedia request values
    struct WikipediaRequestValues {
        static let wikipediaURL = "https://en.wikipedia.org/wiki/"
    }
    
    
    // Flickr Response Keys
    struct FlickrResponseKeys {
        static let StatusCode = "status"
        static let ErrorMessage = "error"
        static let Results = "results"
        static let PhotoId = "id"
        static let Owner = "owner"
        static let Secret = "secret"
        static let DateTaken = "date_taken"
        static let Farm = "farm"
        static let Server = "server"
    }
    
    // Map attributes
    struct Map {
        static let RegionRadius: CLLocationDistance  = 250000
    }
}
