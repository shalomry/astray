//
//  FavoritesController.swift
//  Astray
//
//  Created by Katherine Bernstein on 3/6/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase
import CoreData

class FavoritesController : UITableViewController {
    
    var ref: Firebase!
    @IBOutlet var favoritesTable: UITableView!
    
    @IBOutlet var buttonView: UIView!
    
    
    var listOfUsernames: NSMutableArray!
    var listOfIds: NSMutableArray!
    var listOfBios: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listOfUsernames = NSMutableArray()
        listOfIds = NSMutableArray()
        listOfBios = NSMutableArray()
        self.favoritesTable.tableFooterView = buttonView
        ref = Firebase(url:"https://astray194.firebaseio.com/Users")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            let currUserRef = ref.childByAppendingPath(currUid)
            currUserRef.observeEventType(.Value, withBlock: { snapshot1 in
                if let following = snapshot1.value.objectForKey("following") {
                    for (id) in following as! NSArray {
                        if id.length! > 0 {
                            self.ref.childByAppendingPath(id as! String).observeEventType(.Value, withBlock: { snapshot2 in
                                if let username = snapshot2.value.objectForKey("username") {
                                    self.listOfUsernames.addObject(username)
                                    self.listOfIds.addObject(id as! String)
                                    if let bio = snapshot2.value.objectForKey("bio") {
                                        self.listOfBios.addObject(bio)
                                    } else {
                                        self.listOfBios.addObject("")
                                    }
                                }
                            })
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfUsernames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
            cell.textLabel?.text = listOfUsernames[indexPath.item] as? String
            cell.detailTextLabel?.text = listOfBios[indexPath.item] as? String
        return cell
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        favoritesTable.reloadData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let idClicked = listOfIds[indexPath.item] as? String
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.viewingUid = idClicked!
        navigateToView("ProfileView")
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
}