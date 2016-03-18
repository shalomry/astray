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
    //var playerReal: AVAudioPlayer! = AVAudioPlayer()
    
    //pick whichever one depending on the type of media.
    var playerReal: AVPlayer! = AVPlayer()
    //var audioPlayer
    //var textDisplayer
    var playing = true
    
    var fileURL: NSURL!
    var ref: Firebase!
    var payload: String!
    var fileType: String = "mov"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
              try setupVideo()
        } catch AppError.InvalidResource(let name, let type) {
            debugPrint("Could not find resource \(name).\(type)")
        } catch {
            debugPrint("Generic error")
        }

        
        
   //     self.view.addSubview(self.overlay)
        
        //FOR VIDEO: AVPLAYERLAYER FIGURE OUT
        
        // FOR BUTTON FUNCS: http://pastebin.com/6Yz61NW7
        
        
        
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
    
    @IBAction func controlAudio() {
        if playing {
            playerReal.pause()
            playPause.setTitle(">", forState: .Normal)
        } else {
            playerReal.play()
            playPause.setTitle("| |", forState: .Normal)
        }
        playing = !playing
    }
    
//    
  //  http://stackoverflow.com/questions/7139927/set-uislider-value-to-avplayer-currenttime
    
//    -(IBAction) timeScrubberChange:(id) sender{
//    CMTime t = CMTimeMake(self.nowPlayingTimeScrubber.value, 1);
//    self.nowPlayingCurrentTime.text = [self formatTimeCodeAsString: t.value];
//    self.nowPlayingDuration.text = [self formatTimeCodeAsString:(self.actualDuration - t.value)];
//    [self.avPlayer seekToTime:t];
//    }
    
    
//circular sliders for time and audio????
    
    //https://github.com/eliotfowler/EFCircularSlider
    
    @IBAction func restartAudio() {
        playerReal.pause()
        playerReal.seekToTime(CMTimeMake(0, 1))
        playPause.setTitle("| |", forState: .Normal)
        playerReal.play()
        playing = true
    }
    
    private var firstAppear = true
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        playing = false
        playerReal.pause()
        playerReal.seekToTime(CMTimeMake(0, 1))
    }
    
      
    private func setupVideo() throws {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.currStory != nil {
            let storyInfoRef = Firebase(url:"https://astray194.firebaseio.com/Stories/"+appDelegate.currStory!)
            storyInfoRef.observeSingleEventOfType(.Value, withBlock: { snap in
                let dict = snap.value as! NSDictionary
                
                self.fileType = dict.valueForKey("fileType") as! String
                self.payload = dict.valueForKey("data") as! String
                
                print(dict.valueForKey("title") as! String)
                
                let decodeOption = NSDataBase64DecodingOptions(rawValue: 0)
                let decodedData = NSData(base64EncodedString: self.payload, options: decodeOption)
                
                let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
                let docDir = paths[0]
                let dataPath = (docDir as NSString).stringByAppendingPathComponent("cacheddata.mp3")
                
                decodedData!.writeToFile(dataPath, atomically: true)
                self.fileURL = NSURL(fileURLWithPath: dataPath)
                
                self.playerReal = AVPlayer(URL: self.fileURL)
                let playerController = AVPlayerViewController()
                playerController.player = self.playerReal
                self.playerReal.play()
            })
        }
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    @IBAction func backToExplore() {
        do{
            try NSFileManager.defaultManager().removeItemAtURL(self.fileURL)
        }
        catch{
            print("Could not delete the cached files!")
        }

        self.navigateToView("DiscoverView")
    }
    
    
    //TODO: check if this story was uploaded by the given user.
    //if so, show the delete button.
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

