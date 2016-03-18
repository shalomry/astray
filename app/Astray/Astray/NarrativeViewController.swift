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
    @IBOutlet weak var storyTitle: UILabel!
    @IBOutlet weak var trackBar: UISlider!
    @IBOutlet weak var durationTime: UILabel!
    @IBOutlet weak var currTime: UILabel!
    @IBOutlet weak var deleteStoryButton: UIButton!
    
    var playerReal: AVPlayer! = AVPlayer()
    var playerItemReal: AVPlayerItem!
    var playing = true
    
    var fileURL: NSURL!
    var ref: Firebase!
    var payload: String!
    var fileType: String = "mov"
    
    var timer : NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteStoryButton.hidden = true

        do {
              try setupVideo()
        } catch AppError.InvalidResource(let name, let type) {
            debugPrint("Could not find resource \(name).\(type)")
        } catch {
            debugPrint("Generic error")
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateBar", userInfo: nil, repeats: true)
        
        trackBar.addTarget(self, action: Selector("trackBarMoved"), forControlEvents: UIControlEvents.ValueChanged)

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
            if let image = UIImage(named: "play-button.tiff") {
                playPause.setImage(image, forState: .Normal)
            }
        } else {
            playerReal.play()
            if let image = UIImage(named: "pause-button.tiff") {
                playPause.setImage(image, forState: .Normal)
            }
        }
        playing = !playing
    }
    
    func trackBarMoved() {
        print("MOVED!")
        timer.invalidate()
        let durDuration = (playerReal.currentItem?.asset.duration)!
        let durSecs = CMTimeGetSeconds(durDuration)
        let trackValue = self.trackBar.value
        playerReal.seekToTime(CMTimeMakeWithSeconds(Float64(trackValue) * durSecs, 1))
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateBar", userInfo: nil, repeats: true)
    }
    
    func updateBar() {
        var barValue : Float = 0.1
        barValue = Float(CMTimeGetSeconds(playerReal.currentTime())) / Float(CMTimeGetSeconds((playerReal.currentItem?.asset.duration)!))
        
        self.trackBar.value = barValue
        
        let currMin = Int(CMTimeGetSeconds((playerReal.currentTime()))) / 60
        let currSec = Int(CMTimeGetSeconds((playerReal.currentTime()))) % 60
        var currSecString = String(currSec)
        if currSec < 10 {
            currSecString = "0" + currSecString
        }
        currTime.text = String(currMin) + ":" + currSecString
        
        let durDuration = (playerReal.currentItem?.asset.duration)!
        let durSecs = CMTimeGetSeconds(durDuration)
        
        let durationMin = Int(durSecs) / 60
        let durationSec = Int(CMTimeGetSeconds((playerReal.currentItem?.asset.duration)!)) % 60
        var durationSecString = String(durationSec)
        if durationSec < 10 {
            durationSecString = "0" + durationSecString
        }
        durationTime.text = String(durationMin) + ":" + durationSecString
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
    
    func resetAudio() {
        playerReal.pause()
        playerReal.seekToTime(CMTimeMake(0, 1))
        if let image = UIImage(named: "play-button.tiff") {
            playPause.setImage(image, forState: .Normal)
        }
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
                print(dict.valueForKey("author_id") as! String)
                print(appDelegate.currUid!)
                if((dict.valueForKey("author_id") as! String) == appDelegate.currUid!){
                    self.deleteStoryButton.hidden = false
                    print("nothidden!!")
                    
                }
                
                var newViewCount = dict.valueForKey("viewCount") as! NSNumber
                
                let viewCountRef = Firebase(url: "https://astray194.firebaseio.com/Stories/"+appDelegate.currStory!+"/viewCount")
                let val = newViewCount.integerValue + 1
                viewCountRef.setValue(val)
                
                self.fileType = dict.valueForKey("fileType") as! String
                self.payload = dict.valueForKey("data") as! String
                
                print(dict.valueForKey("title") as! String)
                
                self.storyTitle.text = dict.valueForKey("title") as! String
                
                self.storyTitle.layer.shadowOffset = CGSize(width: 0, height: 0)
                self.storyTitle.layer.shadowRadius = 5
                self.storyTitle.layer.shadowOpacity = 1.0
                
                let decodeOption = NSDataBase64DecodingOptions(rawValue: 0)
                let decodedData = NSData(base64EncodedString: self.payload, options: decodeOption)
                
                let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
                let docDir = paths[0]
                let dataPath = (docDir as NSString).stringByAppendingPathComponent("cacheddata.mp3")
                
                decodedData!.writeToFile(dataPath, atomically: true)
                self.fileURL = NSURL(fileURLWithPath: dataPath)
                
                self.playerItemReal = AVPlayerItem(URL: self.fileURL)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioDone", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItemReal)
                
                self.playerReal = AVPlayer(playerItem: self.playerItemReal)
                let playerController = AVPlayerViewController()
                playerController.player = self.playerReal
                self.playerReal.play()
            })
        }
    }
    
    func audioDone() {
        resetAudio()
        playing = false
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

        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func deleteClicked(sender: AnyObject) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currStory = appDelegate.currStory {
            let storyArray = NSMutableArray()
            storyArray.addObject(currStory)
            appDelegate.deleteStories(storyArray)
            self.navigateToView("ProfileView")
        }
    }
    
}

//http://stackoverflow.hex1.ru/a/9302494
class CustomUISlider : UISlider {
    override func trackRectForBounds(bounds: CGRect) -> CGRect {

        let customBounds = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: 12.0))
        super.trackRectForBounds(customBounds)
        return customBounds
    }
}


enum AppError : ErrorType {
    
    case InvalidResource(String, String)
    
}

