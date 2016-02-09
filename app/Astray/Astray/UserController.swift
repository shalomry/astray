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
    @IBOutlet weak var profileUsernameLabel: UILabel!
    @IBOutlet weak var profileBioLabel: UILabel!
    @IBOutlet weak var settingsUsernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url:"https://astray194.firebaseio.com/Users")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            let currUserRef = ref.childByAppendingPath(currUid)
            currUserRef.observeEventType(.Value, withBlock: { snapshot in
                print(snapshot.value)
                if let username = snapshot.value.objectForKey("username") {
                    if self.profileUsernameLabel != nil {
                        self.profileUsernameLabel.text = "\(username)"
                    }
                    if self.settingsUsernameLabel != nil {
                        self.settingsUsernameLabel.text = "\(username)"
                    }
                }
                if let bio = snapshot.value.objectForKey("bio") {
                    if self.newBioField != nil {
                        self.newBioField.text = "\(bio)"
                    }
                    if self.profileBioLabel != nil {
                        self.profileBioLabel.text = "\(bio)"
                    }
                }
            })
        }
    }
    
    @IBAction func updateProfile() {
        updateBio(newBioField.text)
    }
    
    func updateBio(newBio:String) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            let currUserRef = ref.childByAppendingPath(currUid)
            let bioRef = currUserRef.childByAppendingPath("bio")
            bioRef.setValue(newBio)
        }
        if let profileView = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileView") {
            self.navigationController?.pushViewController(profileView, animated: true)
        }
    }
    
    @IBAction func logout() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.currUid = nil
    }
    
}