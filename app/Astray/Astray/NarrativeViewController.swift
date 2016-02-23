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
        
//TRYING FOR IMAGE : loading image from url http://stackoverflow.com/questions/24231680/loading-image-from-url
//        var url:NSURL = NSURL.URLWithString("http://myURL/ios8.png")
//        var data:NSData = NSData.dataWithContentsOfURL(url, options: nil, error: nil)
//        
//        imageView.image = UIImage.imageWithData(data)// Error here
        
        var urlofFile = NSURL(string: "nil");
        let sample = NSBundle.mainBundle().URLForResource("memchu", withExtension: "mp3")
        //sample can be put in avplayer as url easily. avplayer(url: sample)
        
        let path = NSBundle.mainBundle().pathForResource("memchu", ofType:"mp3")
        let fakeURL = NSURL(fileURLWithPath: path!)
        
        //let data = NSData(contentsOfFile:path!)
        let data = NSData(contentsOfURL: sample!)
        
        if (data != nil)
        {
            let encodeOption = NSDataBase64EncodingOptions(rawValue: 0)
            let decodeOption = NSDataBase64DecodingOptions(rawValue: 0)
            let movieData = data!.base64EncodedStringWithOptions(encodeOption)
            //upload and download from firebase works here, check plus
            let decodedData = NSData(base64EncodedString: movieData, options: decodeOption)

            //try saving the data somewhere and then accessing that URL and playing it.
            
            let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
            let docDir = paths[0] //should i do .first instead of 0???
            let dataPath = (docDir as NSString).stringByAppendingPathComponent("cachedmemchu.mp3")
            
            data!.writeToFile(dataPath, atomically: true)
            urlofFile = NSURL(fileURLWithPath: dataPath)
            print("wrote data to: ")
            print(dataPath)
            
            
            
    
            }
        else{
            print("data was nil")
        }
        
        do{
            print("trying with written data at address")
            //let player = try AVAudioPlayer(data: data!)
            var url = fakeURL
            print(url)
            url = urlofFile!
            print(url)
            let player = AVPlayer(URL: url)
            
            //sample! original, works. //try catch here if you want
            //let player2 = AVPlayer(URL: sample2!)
            let playerController = AVPlayerViewController()
            
            playerController.player = player
            self.addChildViewController(playerController)
            self.view.addSubview(playerController.view)
            playerController.view.frame = self.view.frame
            
            player.play()
            
            //CALL UPON EXIT::::: SUPER IMPORTANT, DELETE FILE
            do{
                try NSFileManager.defaultManager().removeItemAtURL(urlofFile!)
            }
            catch{
                print("everything burns - figure out cache system better, things did not go as expected")
            }
            
        }
        catch {
            print("avaudioplayer didn't work")
        }

//        //this works to play audio.
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        if appDelegate.currStory != nil {
//            var sample : NSURL?
//            if appDelegate.currStory=="MemChu" {
//                sample = NSBundle.mainBundle().URLForResource("memchu", withExtension: "mp3")
//            } else {
//                sample = NSBundle.mainBundle().URLForResource("lakelag", withExtension: "mp3")
//            }
//        
//            do{
//                audioPlayer = try AVAudioPlayer(contentsOfURL:sample!)
//                audioPlayer.prepareToPlay()
//                audioPlayer.play()
//                playing = true
//                print("played audio")
//            }catch {
//                print("Error getting the audio file")
//            }
//        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func controlAudio() {
        if playing {
            audioPlayer.pause()
            playPause.setTitle(">", forState: .Normal)
        } else {
            audioPlayer.play()
            playPause.setTitle("| |", forState: .Normal)
        }
        playing = !playing
    }
    
    @IBAction func restartAudio() {
        audioPlayer.stop()
        audioPlayer.currentTime = 0
        audioPlayer.prepareToPlay()
        playPause.setTitle("| |", forState: .Normal)
        audioPlayer.play()
        playing = true
    }
    
    private var firstAppear = true
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            do {
                //try playVideo()
                //firstAppear = false
            } catch AppError.InvalidResource(let name, let type) {
                debugPrint("Could not find resource \(name).\(type)")
            } catch {
                debugPrint("Generic error")
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        playing = false
        audioPlayer.stop()
        audioPlayer.currentTime = 0
    }
    
    private func uploadVideo() throws {
        // guard let path = NSBundle.mainBundle().pathForResource("samplevideo", ofType:"mov") else {
        guard let path = NSBundle.mainBundle().pathForResource("sample", ofType:"mp3") else {
            throw AppError.InvalidResource("sample", "mp3")
        }
        
        
        let sample = NSBundle.mainBundle().URLForResource("memchu", withExtension: "mp3")
        do{
            
            let player = try AVPlayer(URL: sample!)
            let playerController = AVPlayerViewController()
            
            playerController.player = player
            self.addChildViewController(playerController)
            self.view.addSubview(playerController.view)
            playerController.view.frame = self.view.frame
            
            player.play()
        } catch {
            print("Error getting the audio file")
        }
        
        
        
        
        if path != "" {
            if let data = NSData(contentsOfFile:path){
                
                
                let movieData = data.base64EncodedStringWithOptions([])
                //let movieData = NSString(data: data, encoding:NSASCIIStringEncoding)//NSUTF8StringEncoding)
                //let movieData = NSDataMovieData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)// or encodingwith64???!?!?!?!EncodingEndLineWithLineFeed
                ref = Firebase(url:"https://astray194.firebaseio.com/Stories/story1/data")
                ref.setValue(movieData)
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
                if let thisUrl = NSURL(string: self.payload) {
                    
                    let player = AVPlayer(URL: thisUrl) //AVPlayer(contentsOfURL: url, fileTypeHint: "mov")
                    let playerController = AVPlayerViewController()
                    playerController.player = player
                    self.presentViewController(playerController, animated: true) {
                        player.play()
                    }
                } else {
                    print("Received nil video payload")
                }
            }
        })
    }
}



enum AppError : ErrorType {
    
    case InvalidResource(String, String)
    
}

