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

class SearchController : UITableViewController, UISearchResultsUpdating {
    
    
    @IBOutlet var resultsTable: UITableView!

    var ref: Firebase!
    
    var listOfUsernames: NSMutableArray!
    var listOfIds: NSMutableArray!
    var allUsernames: NSMutableArray!
    var allIds: NSMutableArray!
    var allEmails: NSMutableArray!
    var allBios: NSMutableArray!
    var filteredUsernames: NSMutableArray!
    var filteredIds: NSMutableArray!
    var filteredBios: NSMutableArray!
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var searchBar: UISearchBar!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("IN SEARCH")
        listOfUsernames = NSMutableArray()
        listOfIds = NSMutableArray()
        allIds = NSMutableArray()
        allUsernames = NSMutableArray()
        allEmails = NSMutableArray()
        allBios = NSMutableArray()
        filteredUsernames = NSMutableArray()
        filteredIds = NSMutableArray()
        filteredBios = NSMutableArray()
        ref = Firebase(url:"https://astray194.firebaseio.com/Users")
        //print(ref)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        ref.observeEventType(.Value, withBlock: { snapshot in
            //print(snapshot)
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
             //   print("USER")
              //  print(" ")
//                print("id: " + rest.key)
//               // print(rest.value)
//                print(rest.value.valueForKey("username")!)
//                print(rest.value.valueForKey("email")!)
//                print(" ")
                if let username = rest.value.valueForKey("username") {
                    if let email = rest.value.valueForKey("email") {
                        self.allIds.addObject(rest.key)
                        self.allUsernames.addObject(username)
                        self.allEmails.addObject(email)
    
                        if let bio = rest.value.valueForKey("bio") {
                            self.allBios.addObject(bio)
                        } else {
                            self.allBios.addObject("")
                        }
                    }
                }
            }
        })
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filteredUsernames = NSMutableArray()
        filteredIds = NSMutableArray()
        filteredBios = NSMutableArray()
        if (searchController.searchBar.text?.characters.count > 0) {
            filterContentForSearchText(searchController.searchBar.text!)
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        let usernames = allUsernames.filter { username in
            return username.lowercaseString.containsString(searchText.lowercaseString)
        }
        for (username) in usernames {
            filteredUsernames.addObject(username)
            let idIndex = allUsernames.indexOfObject(username)
            filteredIds.addObject(allIds[idIndex])
            filteredBios.addObject(allBios[idIndex])
        }
        tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredUsernames.count
        }
        return allUsernames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let username: String
        let bio: String
        if searchController.active && searchController.searchBar.text != "" {
            username = filteredUsernames[indexPath.row] as! String
            bio = filteredBios[indexPath.row] as! String
        } else {
            username = allUsernames[indexPath.row] as! String
            bio = allBios[indexPath.row] as! String
        }
        cell.textLabel?.text = username
        cell.detailTextLabel?.text = bio
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let idClicked = filteredIds[indexPath.item] as? String
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