//
//  NarrativeViewController.swift
//  Astray
//
//  Created by Shalom Rottman-Yang on 2/1/16.
//  Resurrected from its ashes by Vehbi Deger Turan on 2/9/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase

class NarrativeViewController: UIViewController {
    @IBOutlet weak var strFiles: UITextView!
    var myPlayer = AVAudioPlayer()
    var yourSound:NSURL?
    
    func prepareYourSound(myData:NSData) {
        do {
            let myPlayer = try AVAudioPlayer(data: myData, fileTypeHint: filetype)
            myPlayer.prepareToPlay()
        }
        catch {
            print("error from player!!!")
        }
        
    }
    
    var ref: Firebase!
    var payload: String!
    var filetype: String = "mov"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this works to play audio.
        let sample = NSBundle.mainBundle().URLForResource("sample", withExtension: "mp3")
        
        do{
            let audioPlayer = try AVAudioPlayer(contentsOfURL:sample!)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            print("played audio")
        }catch {
            print("Error getting the audio file")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private var firstAppear = true
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            do {
                try playVideo()
                firstAppear = false
            } catch AppError.InvalidResource(let name, let type) {
                debugPrint("Could not find resource \(name).\(type)")
            } catch {
                debugPrint("Generic error")
            }
        }
    }
    
    private func playVideo() throws {
        //let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        //let videoURL = "samplevideo.vid"
        let mediaID = "story1" // pulled from database, storyID comes from the previous page, here we know which story we want to play
        
        let ref = Firebase(url:"https://astray194.firebaseio.com/Stories/"+mediaID+"/data")
        
        let typeRef = Firebase(url:"https://astray194.firebaseio.com/Stories/"+mediaID+"/filetype")
        
        typeRef.observeEventType(.Value, withBlock: { snap in
            
            if snap.value is NSNull {
                print("Can't find anything at the given address!")
                // The value is null
            }
            else{
                self.filetype = snap.value as! String
            }
        })
        
        ref.observeEventType(.Value, withBlock: { snap in
            if snap.value is NSNull {
                print("Can't find anything at the given address!")
                // The value is null
            }
            else{
                self.payload = snap.value as! String!
                let thisUrl = NSURL(string: self.payload)!
                
                let player = AVPlayer(URL: thisUrl) //AVPlayer(contentsOfURL: url, fileTypeHint: "mov")
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.presentViewController(playerController, animated: true) {
                    player.play()
                }
            }
        })
    }
}



enum AppError : ErrorType {
    
    case InvalidResource(String, String)
    
}

