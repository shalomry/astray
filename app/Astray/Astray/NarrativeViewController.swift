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
    @IBOutlet weak var playPause: UIButton!
    var audioPlayer: AVAudioPlayer! = AVAudioPlayer()
    var playing = false
    var yourSound:NSURL?
    
    
    var ref: Firebase!
    var payload: String!
    var fileType: String = "mov"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TRYING FOR IMAGE : loading image from url http://stackoverflow.com/questions/24231680/loading-image-from-url
        //        var url:NSURL = NSURL.URLWithString("http://myURL/ios8.png")
        //        var data:NSData = NSData.dataWithContentsOfURL(url, options: nil, error: nil)
        //
        //        imageView.image = UIImage.imageWithData(data)// Error here
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func controlAudio() {
//        if playing {
//            audioPlayer.pause()
//            playPause.setTitle(">", forState: .Normal)
//        } else {
//            audioPlayer.play()
//            playPause.setTitle("| |", forState: .Normal)
//        }
//        playing = !playing
//    }
//    
//    @IBAction func restartAudio() {
//        audioPlayer.stop()
//        audioPlayer.currentTime = 0
//        audioPlayer.prepareToPlay()
//        playPause.setTitle("| |", forState: .Normal)
//        audioPlayer.play()
//        playing = true
//    }
    
    private var firstAppear = true
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            do {
                try setupVideo()
            } catch AppError.InvalidResource(let name, let type) {
                debugPrint("Could not find resource \(name).\(type)")
            } catch {
                debugPrint("Generic error")
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
//        playing = false
//        audioPlayer.stop()
//        audioPlayer.currentTime = 0
    }
    
      
    private func setupVideo() throws {
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.currStory != nil {
            print(appDelegate.currStory)
            var storyInfoRef = Firebase(url:"https://astray194.firebaseio.com/Stories/"+appDelegate.currStory!)
            storyInfoRef.observeEventType(.Value, withBlock: { snap in
                let dict = snap.value as! NSDictionary
                
                self.fileType = dict.valueForKey("fileType") as! String
                self.payload = dict.valueForKey("data") as! String
                
                print(dict.valueForKey("title") as! String)
                
                let decodeOption = NSDataBase64DecodingOptions(rawValue: 0)
                let decodedData = NSData(base64EncodedString: self.payload, options: decodeOption)
                
                //try saving the data somewhere and then accessing that URL and playing it.
                
                let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
                let docDir = paths[0] //should i do .first instead of 0???
                let dataPath = (docDir as NSString).stringByAppendingPathComponent("cacheddata.mp3")
                
                decodedData!.writeToFile(dataPath, atomically: true)
                let url = NSURL(fileURLWithPath: dataPath)
                
                let player = AVPlayer(URL: url)
                let playerController = AVPlayerViewController()
                playerController.player = player
                self.view.addSubview(playerController.view)
                playerController.view.frame = self.view.frame
                self.presentViewController(playerController, animated: true) {
                    print("playing video!!")
                    player.play()
                }
                //CALL UPON EXIT, UPON LEAVING THE VIDEO SCREEN::::: SUPER IMPORTANT, DELETE FILE
                do{
                    try NSFileManager.defaultManager().removeItemAtURL(url)
                }
                catch{
                    print("everything burns - figure out cache system better, things did not go as expected")
                }
                
            })
        }
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func delete() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currStory = appDelegate.currStory {
            let storyArray = NSMutableArray()
            storyArray.addObject(currStory)
            appDelegate.deleteStories(storyArray)
            self.navigateToView("ProfileView")
        }
    }
}



enum AppError : ErrorType {
    
    case InvalidResource(String, String)
    
}

