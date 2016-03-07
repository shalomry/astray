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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url:"https://astray194.firebaseio.com/Users")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            let currUserRef = ref.childByAppendingPath(currUid)
            currUserRef.observeEventType(.Value, withBlock: { snapshot1 in
                if let following = snapshot1.value.objectForKey("following") {
                    print(following)
                    for (id) in following as! NSArray {
                        if id.length! > 0 {
                            self.ref.childByAppendingPath(id as! String).observeEventType(.Value, withBlock: { snapshot2 in
                                if let username = snapshot2.value.objectForKey("username") {
                                    //add row with username
                                }
                            })
                        }
                    }
                }
            })
        }
    }
}