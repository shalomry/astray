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
    var username: String?
    var email: String?
    @IBOutlet weak var newBioField: UITextView!
    @IBOutlet weak var profileUsernameLabel: UILabel!
    @IBOutlet weak var profileBioLabel: UILabel!
    @IBOutlet weak var settingsUsernameLabel: UILabel!
    @IBOutlet weak var storyUsernameLabel: UILabel!
    @IBOutlet weak var profileEmailLabel: UILabel!
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var goToStoriesButton: UIButton!
    @IBOutlet weak var passwordConfirmation: UITextField!
    @IBOutlet weak var settingsError: UILabel!
    
    let invalidPasswordText = "The password you entered was incorrect."
    let invalidEmailText = "Please enter a valid email address."
    let emailTakenText = "An account with that email already exists."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url:"https://astray194.firebaseio.com/Users")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if self.settingsError != nil {
            self.settingsError.text = ""
        }
        if let currUid = appDelegate.currUid {
            let currUserRef = ref.childByAppendingPath(currUid)
            currUserRef.observeEventType(.Value, withBlock: { snapshot in
                print(snapshot.value)
                if let username = snapshot.value.objectForKey("username") {
                    self.username = "\(username)"
                    if self.profileUsernameLabel != nil {
                        self.profileUsernameLabel.text = "\(username)"
                    }
                    if self.settingsUsernameLabel != nil {
                        self.settingsUsernameLabel.text = "\(username)"
                    }
                    if self.storyUsernameLabel != nil {
                        self.storyUsernameLabel.text = "\(username)"
                    }
                    
                    if self.goToStoriesButton != nil {
                        let title = "\(username)'s Stories"
                        self.goToStoriesButton.setTitle(title, forState: .Normal)
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
                if let email = snapshot.value.objectForKey("email") {
                    self.email = "\(email)"
                    if self.newEmailField != nil {
                        self.newEmailField.text = "\(email)"
                    }
                    if self.profileEmailLabel != nil {
                        self.profileEmailLabel.text = "\(email)"
                    }
                }
            })
        }
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    @IBAction func logout() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.currUid = nil
        self.navigateToView("LoginView")
    }
    
    @IBAction func updateProfile() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            let currUserRef = ref.childByAppendingPath(currUid)
            if let currUid = appDelegate.currUid {
                let currUserRef = ref.childByAppendingPath(currUid)
                currUserRef.observeEventType(.Value, withBlock: { snapshot in
                    if let email = snapshot.value.objectForKey("email") {
                        if self.newEmailField.text != "\(email)" {
                            print("CHANGING EMAIL")
                            let ref = Firebase(url:"https://astray194.firebaseio.com")
                            ref.changeEmailForUser("\(email)", password: self.passwordConfirmation.text, toNewEmail: self.newEmailField.text, withCompletionBlock: { error in
                                if error != nil {
                                    print(error)
                                    self.settingsError.text = "Please enter a valid email address."
                                    if error.code == -5 {
                                        self.settingsError.text = self.invalidEmailText
                                    } else if error.code == -6 {
                                        self.settingsError.text = self.invalidPasswordText
                                    } else if error.code == -9 {
                                        self.settingsError.text = self.emailTakenText
                                    }
                                } else {
                                    print("IT WORKED")
                                    let emailRef = currUserRef.childByAppendingPath("email")
                                    emailRef.setValue(self.newEmailField.text)
                                    let bioRef = currUserRef.childByAppendingPath("bio")
                                    bioRef.setValue(self.newBioField.text)
                                    self.navigateToView("ProfileView")
                                }
                            })
                        } else {
                            let bioRef = currUserRef.childByAppendingPath("bio")
                            bioRef.setValue(self.newBioField.text)
                            self.navigateToView("ProfileView")
                        }
                    } else { print("NOT CHANGING EMAIL") }
                })
            }
        }
    }
}