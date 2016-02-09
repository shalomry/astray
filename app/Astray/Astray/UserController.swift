//
//  UserController.swift
//  Astray
//
//  Created by Katherine Bernstein on 2/8/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase
import CoreData

class UserController : UIViewController, UIActionSheetDelegate {
    
    var ref: Firebase!
    @IBOutlet weak var newBioField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url:"https://astray194.firebaseio.com")
    }
    
    @IBAction func updateProfile() {
        updateBio(newBioField.text)
    }
    
    func updateBio(newBio:String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            let usersRef = self.ref.childByAppendingPath("Users")
            let currUserRef = usersRef.childByAppendingPath(currUid)
            let bioRef = currUserRef.childByAppendingPath("bio")
            bioRef.setValue(newBio)
        }
    }
    
    @IBAction func logout() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.currUid = nil
    }
    
}