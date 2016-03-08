//
//  SearchController.swift
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

class SearchController : UITableViewController {
    
    
    @IBOutlet var resultsTable: UITableView!

    var ref: Firebase!
    
    var listOfUsernames: NSMutableArray!
    var listOfIds: NSMutableArray!
    var allUsernames: NSMutableArray!
    var allIds: NSMutableArray!
    var allEmails: NSMutableArray!
    
    @IBOutlet weak var searchBar: UISearchBar!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        listOfUsernames = NSMutableArray()
        listOfIds = NSMutableArray()
        allIds = NSMutableArray()
        allUsernames = NSMutableArray()
        allEmails = NSMutableArray()
        ref = Firebase(url:"https://astray194.firebaseio.com/Users")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
             //   print("USER")
              //  print(" ")
                print("id: " + rest.key)
               // print(rest.value)
                print(rest.value.valueForKey("username")!)
                print(rest.value.valueForKey("email")!)
                print(" ")
                if let username = rest.value.valueForKey("username") {
                    if let email = rest.value.valueForKey("email") {
                        self.allIds.addObject(rest.key)
                        self.allUsernames.addObject(username)
                        self.allEmails.addObject(email)
                    }
                }
            }
        })
    }

//
//        if let currUid = appDelegate.currUid {
//            let currUserRef = ref.childByAppendingPath(currUid)
//            currUserRef.observeEventType(.Value, withBlock: { snapshot1 in
//                if let following = snapshot1.value.objectForKey("following") {
//                    for (id) in following as! NSArray {
//                        if id.length! > 0 {
//                            self.ref.childByAppendingPath(id as! String).observeEventType(.Value, withBlock: { snapshot2 in
//                                if let username = snapshot2.value.objectForKey("username") {
//                                    self.listOfUsernames.addObject(username)
//                                    self.listOfIds.addObject(id as! String)
//                                }
//                            })
//                        }
//                    }
//                }
//            })
//        }
//    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        print("FILTERING STUFF")
        let filteredUsernames = allUsernames.filter { username in
            return username.name.lowercaseString.containsString(searchText.lowercaseString)
        }
        
        tableView.reloadData()
    }

//    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return listOfUsernames.count
//    }
//    
//    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
//        cell.textLabel?.text = listOfUsernames[indexPath.item] as? String
//        return cell
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        resultsTable.reloadData()
//    }
//    
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let idClicked = listOfIds[indexPath.item] as? String
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        appDelegate.viewingUid = idClicked!
//        navigateToView("ProfileView")
//    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
}