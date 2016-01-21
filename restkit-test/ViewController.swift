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
    
    let manager = ObjectManager.instance
    
    var refreshControl = UIRefreshControl()
    
    let request = ObjectManager.instance.createRequest(Gist.self)
    
    var fetchedResultsController : NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up fetchedResultscontrolller
//        request.entity = NSEntityDescription.entityForName("Gist", inManagedObjectContext: manager.context)
//        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
//        request.fetchBatchSize = 20
//        let f = NSFetchedResultsController()
        fetchedResultsController = NSFetchedResultsController(fetchRequest: self.request, managedObjectContext: manager.context, sectionNameKeyPath: nil, cacheName: "Master")
        fetchedResultsController!.delegate = self
        
        
        let button = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject")
        self.navigationItem.rightBarButtonItem = button
        refreshControl.addTarget(self, action: "loadGists", forControlEvents: .ValueChanged)
        refreshControl.beginRefreshing()
        
        loadGists()
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
        let managedObject = NSEntityDescription.insertNewObjectForEntityForName(request.entity!.name!, inManagedObjectContext: manager.context)
        managedObject.setValue(NSDate(), forKey: "timeStamp")
        try! manager.context.save()
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
        cell.textLabel!.text = gist.titleText
        cell.detailTextLabel!.text = gist.subtitleText
    }
}

