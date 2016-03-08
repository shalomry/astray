//
//  LoginViewController.swift
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

import Foundation

class CreateAccountViewController : UIViewController, UIActionSheetDelegate {
    

    @IBOutlet weak var newUsernameField: UITextField!
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var bioField: UITextField!
    
    @IBOutlet weak var createAccountErrorMessage: UILabel!
    let invalidEmailMsg = "The specified email address is invalid."
    let emailTakenMsg = "An account with that email already exists."
    let noUsernameMsg = "You must choose a username."
    let passwordTooShortMsg = "Your password must be at least 8 characters long."
    let usernameTakenMsg = "An account with that username already exists."
    var ref: Firebase!
    var existingUsernames: NSMutableArray!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VIEW DID LOAD")
        ref = Firebase(url:"https://astray194.firebaseio.com")

        if self.createAccountErrorMessage != nil {
            self.createAccountErrorMessage.text = ""
        }
        
        existingUsernames = NSMutableArray()
        let usersRef = ref.childByAppendingPath("Users")
        usersRef.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot)
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
                if let username = rest.value.valueForKey("username") {
                    self.existingUsernames.addObject(username.lowercaseString)
                }
            }
        })
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            print("could instantiate")
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func createUser(email:String, password:String, username:String, bio:String) {
        if username.characters.count == 0 {
            self.createAccountErrorMessage.text = self.noUsernameMsg
        } else if password.characters.count < 8 {
            self.createAccountErrorMessage.text = self.passwordTooShortMsg
        } else if self.existingUsernames.containsObject(username.lowercaseString) {
            self.createAccountErrorMessage.text = self.usernameTakenMsg
        } else {
            
            self.ref.createUser(email, password: password,
                withValueCompletionBlock: { error, result in
                    if error != nil {
                        if error.code == -5 {
                            self.createAccountErrorMessage.text = self.invalidEmailMsg
                        } else if error.code == -9 {
                            self.createAccountErrorMessage.text = self.emailTakenMsg
                        }
                        
                    } else {
                        let uid = result["uid"] as? String
                        print("Successfully created user account with uid: \(uid)")
                        print(username)
                        print(uid!)
                        let usersRef = self.ref.childByAppendingPath("Users")
                        let newUserRef = usersRef.childByAppendingPath(uid!)
                        let user : NSDictionary = [
                            "username":username,
                            "bio":bio,
                            "email":email,
                            "listofcreatedstories": ["0":""] as NSDictionary,
                            "storiestheyveseen": ["0":""] as NSDictionary,
                            "availablestories":["0":""] as NSDictionary,
                            "following":["0":""] as NSDictionary,
                            "followers":["0":""] as NSDictionary
                        ]
                        newUserRef.setValue(user)
                        self.navigateToView("DiscoverView")
                    }
                }
            )
        }
    }
    
    @IBAction func create(sender: UIButton) {
        if let email = self.newEmailField.text, let username = self.newUsernameField.text, let password = self.newPasswordField.text, let bio = self.bioField.text {
            createUser(email, password: password, username: username, bio: bio)
        }
    }
    
    @IBAction func cancel() {
        self.navigateToView("LoginView")
    }
    
    override func viewWillAppear(animated: Bool) {
        //COMMENT IN TO BRING BACK AUTH
        //    self.navigationItem.setHidesBackButton(true, animated:true)
    }
    
    
    //    func loginWithFacebook() {
    //        ref.authWithOAuthPopup("facebook", function(error, authData) {
    //            if (error) {
    //                console.log("Login Failed!", error);
    //            } else {
    //                console.log("Authenticated successfully with payload:", authData)
    //            }
    //        });
    //    }
    
    
}
