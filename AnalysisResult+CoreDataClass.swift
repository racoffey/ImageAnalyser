//
//  AnalysisResult+CoreDataClass.swift
//  ImageAnalyser
//
//  Created by Robert Coffey on 10/10/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import CoreData
import UIKit
import MapKit

@objc(AnalysisResult)
public class AnalysisResult: NSManagedObject {
    
    //Initiate AnalysisResult object including Entity Description
    convenience init(image : NSData, resultNumber : Int16, context: NSManagedObjectContext){

        if let ent = NSEntityDescription.entityForName("AnalysisResult",
                                                       inManagedObjectContext: context){
            self.init(entity: ent, insertIntoManagedObjectContext: context)
            self.creationDate = NSDate()
            self.image = image
            self.resultNumber = resultNumber
            
        }else{
            fatalError("Unable to find Entity name!")
        }
    }
   
    // Provide coordinate for landmark where relevant
    var coordinate: CLLocationCoordinate2D {
        let coordinate = CLLocationCoordinate2DMake(self.latitude , self.longitude )
        return coordinate
    }
    
    //UPDATE FUNCTIONS
    
    func updateImageText(imageText: String){
        willChangeValueForKey("imageText")
        self.imageText = imageText
        didChangeValueForKey("imageText")
    }
    
    func updateAnalysisType(analysisType: String){
        willChangeValueForKey("analysisType")
        self.analysisType = analysisType
        didChangeValueForKey("analysisType")
    }
    
    func updateLandmarkLabel(landmarkLabel: String){
        willChangeValueForKey("landmarkLabel")
        self.landmarkLabel = landmarkLabel
        didChangeValueForKey("landmarkLabel")
    }
    
    func updateCoodinates(latitude: Double, longitude: Double) {
        willChangeValueForKey("latitude")
        self.latitude = latitude
        didChangeValueForKey("latitude")
        
        willChangeValueForKey("longitude")
        self.longitude = longitude
        didChangeValueForKey("longitude")
    }
    
    func updateFaceLabels(faceLabels: String){
        willChangeValueForKey("faceLabels")
        self.faceLabels = faceLabels
        didChangeValueForKey("faceLabels")
    }
    
    func updateLabelText(labelText: String){
        willChangeValueForKey("labelText")
        self.labelText = labelText
        didChangeValueForKey("labelText")
    }
    
    func updateCity(city: String){
        willChangeValueForKey("city")
        self.city = city
        didChangeValueForKey("city")
    }
    
    func updateCountry(country: String){
        willChangeValueForKey("country")
        self.country = country
        didChangeValueForKey("country")
    }
    
    func updateTranslatedText(translatedText: String){
        willChangeValueForKey("translatedText")
        self.translatedText = translatedText
        didChangeValueForKey("translatedText")
    }
}
