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

class LoginViewController : UIViewController, UIActionSheetDelegate, UITextFieldDelegate {
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var loginEmailField: UITextField!
    @IBOutlet weak var emailBackground: UILabel!
    @IBOutlet weak var passwordBackground: UILabel!
    var ref: Firebase!
    var keyboardShowing: Bool = false
    
    @IBOutlet weak var loginErrorMessage: UILabel!
    let unknownEmailMsg = "Oops! We couldn't find the specified email address."
    let invalidPasswordMsg = "Oops! The password you entered is incorrect."
    let invalidEmailMsg = "The specified email address is invalid."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VIEW DID LOAD")
        ref = Firebase(url:"https://astray194.firebaseio.com")
        
        if self.loginErrorMessage != nil {
            self.loginErrorMessage.text = ""
        }
        loginEmailField.delegate = self
        loginPasswordField.delegate = self
        
        passwordBackground.layer.shadowOffset = CGSize(width: 0, height: 0)
        passwordBackground.layer.shadowRadius = 5
        passwordBackground.layer.shadowOpacity = 1.0
        emailBackground.layer.shadowOffset = CGSize(width: 0, height: 0)
        emailBackground.layer.shadowRadius = 5
        emailBackground.layer.shadowOpacity = 1.0
        self.view.bringSubviewToFront(self.loginPasswordField)
        self.view.bringSubviewToFront(self.loginEmailField)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: loginPasswordField)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: loginPasswordField)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if (keyboardShowing) { return }
        keyboardShowing = true
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y -= keyboardSize.height
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if (!keyboardShowing) {return}
        keyboardShowing = false
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
        
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            print("could instantiate")
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    @IBAction func login(sender: UIButton) {
        print(self.loginEmailField.text)
        print(self.loginPasswordField.text)
        if let email = self.loginEmailField.text, let password = self.loginPasswordField.text {
            loginUser(email, password: password)
        }
            
        
    
    }

    @IBAction func create(sender: UIButton) {
        self.navigateToView("CreateAccountView")
    }

    func loginUser(email:String, password:String) {
        ref.authUser(email, password: password,
            withCompletionBlock: { error, authData in
                if error != nil {
                    if error.code == -5 {
                        self.loginErrorMessage.text = self.unknownEmailMsg
                    } else if error.code == -6 {
                        self.loginErrorMessage.text = self.invalidPasswordMsg
                    }
                } else {
                    print("Successfully logged in \(email)")
                    print("uid: \(authData.uid)")
                    let usersRef = self.ref.childByAppendingPath("Users")
                    let currRef = usersRef.childByAppendingPath(authData.uid)
                    print(currRef.key)
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.currUid = authData.uid
                    print("CURRID: " + appDelegate.currUid!)
                    self.navigateToView("DiscoverView")
                }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
    }
    
}
