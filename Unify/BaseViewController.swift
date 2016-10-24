//
//  BaseViewController.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/25/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import UIKit
import Google
import AVFoundation

class BaseViewController: UIViewController {
    
    var loadingView : UIView?
    var loadingAVPlayer : AVPlayer?
    
    func appTimeout() {
        debugPrint("App Timeout: Call Start Attract Loop")
        self.startAttractLoop()
    }
    
    func getGAIName() -> String? {
        return nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear( animated )
        
        self.sendGAHit()        
        
    }
    
    func sendGAHit() {
                
        //get name of view for ga... default will be className
        let className = "\(self.classForCoder)"
        
        if( className == "ContainerViewController" ) {
            return
        }
        
        var trackedName = self.getGAIName()
        if( trackedName == nil ) {
            trackedName = className
        }
        
        //add tracking!
        debugPrint("Add GA Hit")
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: trackedName )
        let screenView = GAIDictionaryBuilder.createScreenView().build() as [NSObject:AnyObject]
        tracker.send( screenView )
        
        //dispatch now....
        GAI.sharedInstance().dispatch()
    }
    
    func startAttractLoop() {
        
        //only start if we are showing
        if( !self.isViewLoaded() || self.view.window == false ) {
            debugPrint("View not viewable")
            return
        }
        
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if( delegate.isVideoUp ) {
            debugPrint("Video is already playing.  Ignore. \(self)")
            return
        } else {
            debugPrint("Start Attract Loop \(self)")
        }
        
        
        loadingView = UIView(frame: self.view.frame)
        loadingView?.backgroundColor = UIColor.blackColor()
        
        let tempDir = NSTemporaryDirectory()
        let fullPath = "\(tempDir)attract_loop.mp4"

        
        let vidURL = NSURL( fileURLWithPath: fullPath )
        //let vidURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("1Sum_Attract", ofType: "mp4")! )
        
        self.loadingAVPlayer = AVPlayer(URL: vidURL)
        let playerLayer = AVPlayerLayer(player: self.loadingAVPlayer)
        playerLayer.frame = loadingView!.bounds
        loadingView!.layer.addSublayer(playerLayer)
        
        let gr = UITapGestureRecognizer(target: self, action: "stopAttractLoop")
        loadingView!.addGestureRecognizer( gr )
        
        self.view.addSubview( loadingView! )
        
        self.loadingAVPlayer!.actionAtItemEnd = AVPlayerActionAtItemEnd.None
        
        //add listener for movie ended
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "attractLoopEnded:", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.loadingAVPlayer!.currentItem)
        
        self.loadingAVPlayer!.play()
        
        
        delegate.isVideoUp = true
    }
    
    @objc private func attractLoopEnded(notification: NSNotification) {
        debugPrint("Attract Loop Ended:  Restart!")
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seekToTime(kCMTimeZero)
    }
    
    func stopAttractLoop() {
        
        debugPrint("Stopping attract loop")
        self.loadingAVPlayer?.pause()
        self.loadingView?.removeFromSuperview()
        self.loadingView = nil
        self.loadingAVPlayer = nil
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.isVideoUp = false
        
        //NSNotificationCenter.defaultCenter().postNotificationName("AttractLoopUserStopped", object: nil)
        
    }
    
    func setIsModalUp( bool: Bool ) {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        delegate.isModalUp = bool
    }
    
    func isModalUp() -> Bool {
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return delegate.isModalUp
    }
    
    func showSetup(){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("SettingsViewController")
        self.presentViewController(vc, animated: true, completion: {})        
    }
    
}