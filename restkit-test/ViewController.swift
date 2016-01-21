//
//  ViewController.swift
//  restkit-test
//
//  Created by fixd on 1/20/16.
//  Copyright © 2016 fixd. All rights reserved.
//

import UIKit
import RestKit

class ViewController: UIViewController, UITableViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
//    let context = RKManagedObjectStore.defaultStore().mainQueueManagedObjectContext
    
//    let dc = DataController()
    
    var context: NSManagedObjectContext?
    
    var refreshControl = UIRefreshControl()
    
    var request = NSFetchRequest()
    
    var fetchedResultsController : NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let g = Gist(id: 1, url: "https://example.com", htmlUrl: "https://example.com", description: "yoooo", isPublic: true, createdAt: "2013-02-12T22:58:52Z", updatedAt: "2013-02-12T22:58:52Z")
//        print(g)
        
//        let entity = NSEntityDescription.entityForName("Gist", inManagedObjectContext: RKManagedObjectStore.defaultStore().mainQueueManagedObjectContext)
//        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
//        
//        let store = RKManagedObjectStore.defaultStore()
        
//        let app = UIApplication.sharedApplication().delegate as! AppDelegate
//        let context = app.context!
//        let model = app.managedObjectModel
//        let store = RKManagedObjectStore(managedObjectModel: model)
        
        //set up fetchedResultscontrolller
        request.entity = NSEntityDescription.entityForName("Gist", inManagedObjectContext: self.context!)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.fetchBatchSize = 20
//        let f = NSFetchedResultsController()
        fetchedResultsController = NSFetchedResultsController(fetchRequest: self.request, managedObjectContext: self.context!, sectionNameKeyPath: nil, cacheName: "Master")
        fetchedResultsController!.delegate = self
        
        
        let button = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject")
        self.navigationItem.rightBarButtonItem = button
        refreshControl.addTarget(self, action: "loadGists", forControlEvents: .ValueChanged)
        refreshControl.beginRefreshing()
        
        loadGists()
        
//        let store = RKManagedObjectStore.defaultStore()
//        let mapping = RKEntityMapping(forEntityForName: "Gist", inManagedObjectStore: store)
//        mapping.addAttributeMappingsFromDictionary([
//            "id": "gistID",
//            "url": "jsonURL",
//            "description": "descriptionText",
//            "public": "public",
//            "created_at": "createdAt"
//            ])
//        let descriptor = RKResponseDescriptor(mapping: mapping, method: .GET, pathPattern: "/gists/public", keyPath: nil, statusCodes: RKStatusCodeIndexSetForClass(RKStatusCodeClass.Successful))
//        
//        let request = NSURLRequest(URL: NSURL(string: "https://api.github.com/gists/public")!)
//
//        print("request", request)
//        
//        let operation = RKManagedObjectRequestOperation(request: request, responseDescriptors: [descriptor])
//        operation.setCompletionBlockWithSuccess({ (op, result) -> Void in
//            print("success", op, result)
//            }) { (op, result) -> Void in
//                print("fail", op, result)
//        }
//        operation.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadGists() {
        let manager = RKObjectManager.sharedManager()
        manager.getObjectsAtPath("/gists/public", parameters: nil, success: { (op, result) -> Void in
            print("done")
            self.refreshControl.endRefreshing()
            }) { (op, err) -> Void in
                print("err")
                self.refreshControl.endRefreshing()
                let alertController = UIAlertController(title: "Error", message: err.description, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    func insertNewObject(sender: AnyObject?){
        let managedObject = NSEntityDescription.insertNewObjectForEntityForName(request.entity!.name!, inManagedObjectContext: context!)
        managedObject.setValue(NSDate(), forKey: "timeStamp")
        try! context!.save()
    }
    
    //table delegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController!.sections {
            return sections.count
        }else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        drawCell(cell, indexPath: indexPath)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(getGist(indexPath))
    }
    
    func getGist(path: NSIndexPath) -> Gist {
        return fetchedResultsController!.objectAtIndexPath(path) as! Gist
    }
    
    
    //fetched results controller
    
//    lazy var fetchedResultsController : NSFetchedResultsController = {
//        var entity = NSEntityDescription.entityForName("Gist", inManagedObjectContext: self.context!)
//        let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false)
//        self.request.entity = entity
//        self.request.sortDescriptors = [sortDescriptor]
//        self.request.fetchBatchSize = 20
//        let f = NSFetchedResultsController(fetchRequest: self.request, managedObjectContext: self.context!, sectionNameKeyPath: nil, cacheName: "Master")
//        f.delegate = self
//        
//        return f
//    }()

    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        let tableView = self.tableView
        switch(type){
        case .Insert:
            tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            let cell = tableView.cellForRowAtIndexPath(indexPath!)!
            drawCell(cell, indexPath: indexPath!)
        case .Move:
            break
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    // model->view mapping
    
    func drawCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let gist = getGist(indexPath)
        cell.textLabel!.text = gist.titleText()
        cell.detailTextLabel!.text = gist.subtitleText()
    }
}

//class DataController : NSObject {
//    
//    var context: NSManagedObjectContext
//    
//    var model: NSManagedObjectModel
//    
//    //var store: NSPersistentStore
//    
//    override init() {
//        guard let modelURL = NSBundle.mainBundle().URLForResource("restkit_test", withExtension: "momd") else {
//            fatalError("Error loading")
//        }
//        model = NSManagedObjectModel(contentsOfURL: modelURL)!
//        let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
//        context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
//        context.persistentStoreCoordinator = psc
//        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
//            //(.DocumentDirectory, inDomains: .UserDomainMask, appropriateForURL: )
//            let storeURL = urls[urls.endIndex-1].URLByAppendingPathComponent("DataModel.sqlite")
//            try! psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
//        //}
//    }
//    
//}

