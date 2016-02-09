//
//  RecordingViewController.swift
//  Astray
//
//  Created by Shalom Rottman-Yang on 2/8/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices
import Firebase
import CoreData


class RecordingViewController: UIViewController {
    
    var ref: Firebase!

    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url:"https://astray194.firebaseio.com")

        startCameraFromViewController(self, withDelegate: self)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func startCameraFromViewController(viewController: UIViewController, withDelegate delegate: protocol<UIImagePickerControllerDelegate, UINavigationControllerDelegate>) -> Bool {
        print("starting camera")
        if UIImagePickerController.isSourceTypeAvailable(.Camera) == false {
            return false
        }
        
        var cameraController = UIImagePickerController()
        cameraController.sourceType = .Camera
        cameraController.mediaTypes = [kUTTypeMovie as NSString as String]
        cameraController.allowsEditing = false
        cameraController.delegate = delegate
        print("presenting view controller")
        presentViewController(cameraController, animated: true, completion: nil)

        return true
    }
    
    func video(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        var title = "Success"
        var message = "Video was saved"
        
        if let saveError = error {
            title = "Error"
            message = "Video failed to save"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

    
    private func uploadVideo() throws {
        if mainInstance.path != "" {
            let NSDataMovieData = NSData(contentsOfFile:mainInstance.path)
            let movieData = NSString(data: NSDataMovieData!, encoding:NSUTF8StringEncoding)
            //let movieData = NSDataMovieData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)// or encodingwith64???!?!?!?!EncodingEndLineWithLineFeed
            ref = Firebase(url:"https://astray194.firebaseio.com/Stories/story5/data")
            ref.setValue(movieData)
            ref.observeEventType(.Value, withBlock: { snap in
                print("\(snap.value)")
            })
        }
    }
}

extension RecordingViewController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        // Handle a movie capture
        if mediaType == kUTTypeMovie {
            print("movie recorded")
            mainInstance.path = (info[UIImagePickerControllerMediaURL] as! NSURL).path!
            if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(mainInstance.path) {
                print("video path compatible")
                UISaveVideoAtPathToSavedPhotosAlbum(mainInstance.path, self, "video:didFinishSavingWithError:contextInfo:", nil)
                print("saved video at path")
            }
            do {
                print("trying to upload video")
                try uploadVideo()
            } catch {
                print("Upload video failed")
            }
        }
        print("dismissing view controller")
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension RecordingViewController: UINavigationControllerDelegate {
}
