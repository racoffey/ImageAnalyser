//
//  ResultsHistoryViewController.swift
//  ImageAnalyser
//
//  Created by Robert Coffey on 10/10/2016.
//  Copyright © 2016 Robert Coffey. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

// The ResultsHistoryViewControler presents images that have been earlier analysed by the user.  
// Selecting an image segues to the AnalysisSelector View Controller when the image and earlier results are presented.

class ResultsHistoryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    // Arrays to keep track of insertions, deletions, and updates.
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths: [NSIndexPath]!
    var updatedIndexPaths: [NSIndexPath]!
    
    
    // Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    // Instantiate AnalysisResult
    var result : AnalysisResult? = nil
    
    // Get context from shared instance from CoreDataStackManager
    var sharedContext = CoreDataStackManager.sharedInstance().context
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Start the fetched results controller
        fetchResults()
        collectionView.reloadData()
        
        // If there are no AnalysisResults stored display message to user
        let count = (fetchedResultsController.fetchedObjects?.count)! as Int
        if count < 1 {
            displayError("There is no result history to show")
        }
        
        // Add collection view delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Add the collectionView
        self.view.addSubview(collectionView)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Lay out the collection view so that cells take up 1/3 of the width with no space in between.
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let width = floor(self.collectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    
    // Perform fetch of AnalysisResults from Core Data
    func fetchResults () {
        var error: NSError?
        do {
            try fetchedResultsController.performFetch()
        } catch let error1 as NSError {
            error = error1
        }
        if let error = error {
                displayError("Error performing fetch of Analysis Results: \(error.localizedDescription)")
        }
    }
    
    
    // UICollectionView functions
    
    // Get number of sections for collection view if available or return with 1
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.fetchedResultsController.sections?.count ?? 1
    }
    
    
    // Get number of objects to be shown in the collection view
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let numberOfObjects = (fetchedResultsController.fetchedObjects?.count)! as Int
        return numberOfObjects
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        // Get the AnalysisResult for this indexPath
        let result = fetchedResultsController.objectAtIndexPath(indexPath) as! AnalysisResult
        
        // Get the next cell
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath)
        
        // Configure image view
        let imageView = UIImageView(frame: CGRectMake(1, 1, collectionView.frame.size.width/3-1, collectionView.frame.size.width/3-1))
        
        // If AnalysisResult image available then use this
        if (result.image != nil) {
            let image = UIImage(data: result.image!)!
            imageView.image = image
        }
        
        // Add image view to cell and return
        cell.contentView.addSubview(imageView)
        return cell
    }
    
    
    // Perform segue to AnalaysisSelectorView for image selected by user
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        result = fetchedResultsController.objectAtIndexPath(indexPath) as? AnalysisResult
        performSegueWithIdentifier("segueToSelectorView", sender: self)
    }
    
    
    // Pass result to AnalysisSelectorViewController
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier! == "segueToSelectorView" {
            let destVC = segue.destinationViewController as! AnalysisSelectorViewController
            destVC.result = result
        }
    }
    
    
    // Get fetchedResultsController for AnalysisResults
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "AnalysisResult")
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    
    // CONTROLLER DELEGATE METHODS
    
    // Whenever changes are made to Core Data the following three methods are invoked. This first method is used to create three fresh arrays to record the index paths that will be changed.
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        // We are about to handle some new changes. Start out with empty arrays for each change type
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths = [NSIndexPath]()
        updatedIndexPaths = [NSIndexPath]()
    }
    
    
    // The second method may be called multiple times, once for each object that is added, deleted, or changed. We store the index paths into the three arrays.
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        switch type{
            
        case .Insert:
            // Here we record that a new AnalysisResult instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
            
        case .Delete:
            // Here we record that a AnalysisResult instance has been deleted from Core Data. We remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
            
        case .Update:
            // This records changes to AnalysisResults after they are created.
            updatedIndexPaths.append(indexPath!)
            break
            
        case .Move:
            // We don't expect items to move in this app.
            break
        }
    }
    
    // This method is invoked after changes in the current batch have been collected
    // into the three index path arrays (insert, delete, and upate). Here we loop through the
    // arrays and perform the changes.
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
                self.collectionView.reloadData()
                self.collectionView.reloadInputViews()
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
            
            }, completion: nil)
        
    }
}
