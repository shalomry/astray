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

class CreateAccountViewController : UIViewController, UIActionSheetDelegate, UITextViewDelegate {
    

    @IBOutlet weak var newUsernameField: UITextField!
    @IBOutlet weak var usernameBackground: UILabel!
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var emailBackground: UILabel!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var passwordBackground: UILabel!
    @IBOutlet weak var bioBackground: UILabel!
    @IBOutlet weak var bioField: UITextView!
    
    @IBOutlet weak var createAccountErrorMessage: UILabel!
    let invalidEmailMsg = "The specified email address is invalid."
    let emailTakenMsg = "An account with that email already exists."
    let noUsernameMsg = "You must choose a username."
    let passwordTooShortMsg = "Your password must be at least 8 characters long."
    let usernameTakenMsg = "An account with that username already exists."
    var ref: Firebase!
    var existingUsernames: NSMutableArray!
    
    var placeHolderText = "bio"
    
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
        
        usernameBackground.layer.shadowOffset = CGSize(width: 0, height: 0)
        usernameBackground.layer.shadowRadius = 5
        usernameBackground.layer.shadowOpacity = 1.0
        passwordBackground.layer.shadowOffset = CGSize(width: 0, height: 0)
        passwordBackground.layer.shadowRadius = 5
        passwordBackground.layer.shadowOpacity = 1.0
        emailBackground.layer.shadowOffset = CGSize(width: 0, height: 0)
        emailBackground.layer.shadowRadius = 5
        emailBackground.layer.shadowOpacity = 1.0
        bioBackground.layer.shadowOffset = CGSize(width: 0, height: 0)
        bioBackground.layer.shadowRadius = 5
        bioBackground.layer.shadowOpacity = 1.0
        self.view.bringSubviewToFront(self.newUsernameField)
        self.view.bringSubviewToFront(self.newEmailField)
        self.view.bringSubviewToFront(self.newPasswordField)
        self.view.bringSubviewToFront(self.bioField)
    }
    
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        self.bioField.textColor = UIColor(red: 12.0/255.0, green: 18.0/255.0, blue: 24.0/255.0, alpha: 1)
        
        if(self.bioField.text == placeHolderText) {
            self.bioField.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if(bioField.text == "") {
            self.bioField.text = placeHolderText
            self.bioField.textColor = UIColor(red: 12.0/255.0, green: 18.0/255.0, blue: 24.0/255.0, alpha: 1)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.bioField.textColor = UIColor(red: 12.0/255.0, green: 18.0/255.0, blue: 24.0/255.0, alpha: 1)
        self.bioField.text = placeHolderText
        self.bioField.textContainer.lineFragmentPadding = 0;
        self.bioField.textContainerInset = UIEdgeInsetsZero;
        
        //COMMENT IN TO BRING BACK AUTH
        //    self.navigationItem.setHidesBackButton(true, animated:true)
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
