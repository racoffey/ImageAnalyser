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
    
    
    // Core data model constants
    struct CDModel {
        static let ModelName = "Model"
        static let SQLFileName = "Model.sqlite"
    }
    
    
    // Google URL API parameters
    struct Google {
        static let ApiScheme = "https"
        
        // For Vision API
        static let ApiHost = "vision.googleapis.com"
        static let ApiPath = "/v1/images:annotate"
        
        // For Translate API
        static let ApiHostTranslate = "www.googleapis.com"
        static let ApiPathTranlate = "/language/translate/v2"
    }
    
    
    // Google request keys
    struct GoogleRequestKeys {
        static let ApiKey = "key"
        static let DataFormat = "format"
        static let BundleIdentifier = "X-Ios-Bundle-Identifier"
        static let Source = "source"
        static let TargetLanguage = "target"
        static let Text = "q"
        static let Language = "language"
    }
    
    
    // Google request values
    struct GoogleRequestValues {
        static let ApiKey = "--- Google API Key goes here!!! ---"
        static let DataFormat = "json"
        static let BundleIdentifer = ""
        static let EnglishLanguage = "en"
    }
    
    
    //Wikipedia request values
    struct WikipediaRequestValues {
        static let wikipediaURL = "https://en.wikipedia.org/wiki/"
    }
    
    
    // Map attributes
    struct Map {
        static let RegionRadius: CLLocationDistance  = 250000
    }
}
