//
//  AnalysisResult+CoreDataProperties.swift
//  ImageAnalyser
//
//  Created by Robert Coffey on 11/10/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import CoreData


extension AnalysisResult {

    @nonobjc public override class func fetchRequest() -> NSFetchRequest {
        return NSFetchRequest(entityName: "AnalysisResult");
    }

    @NSManaged public var creationDate: NSDate?
    @NSManaged public var image: NSData?
    @NSManaged public var resultNumber: Int16
    @NSManaged public var analysisType: String?
    @NSManaged public var imageLabels: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var url: String?
    @NSManaged public var imageText: String?
    @NSManaged public var translatedText: String?
    @NSManaged public var landmarkLabel: String?
    @NSManaged public var faceLabels: String?
    @NSManaged public var labelText: String?

}
