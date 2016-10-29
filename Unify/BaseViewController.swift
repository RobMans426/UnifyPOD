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
import CoreData

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class BaseViewController: UIViewController {
    
    var loadingView : UIView?
    var loadingAVPlayer : AVPlayer?
    let settingControl = PODSettings.instance
    let clientControl = PODClient.instance
    
    var marrHitData : NSMutableArray!
    
    func appTimeout() {
        debugPrint("App Timeout: Call Start Attract Loop")
        self.startAttractLoop()
    }
    
    func getGAIName() -> String? {
        return nil
    }
    
    func getGAIid() -> String? {
        return nil
    }
    
    func getGAIUrl() -> String? {
        return nil
    }
    
    func  getRegionCode() -> String? {
        return settingControl.getRegionCode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        
        var trackedId = self.getGAIid()
        if (trackedId == nil){
            trackedId = nil
        }
        
        var trackedUrl = self.getGAIUrl()
        if (trackedUrl == nil){
            trackedUrl = nil
        }
        
        var userId = self.getRegionCode()
        if (userId == nil){
            userId = nil
        }
        
        if( trackedName != nil && trackedId != nil && trackedUrl != nil ){
            
            //clientControl.clearCoreData()
            self.seedHits(id: Int(trackedId!),name: trackedName, url: trackedUrl, branchId: userId)
        }
        
        
        //add tracking!
        debugPrint("Add GA Hit")
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIDescription, value: trackedUrl)
        tracker?.set(kGAITitle, value: trackedName)
        tracker?.set(kGAIPage, value: trackedId)
        tracker?.set(kGAIUserId, value: userId)
        
        let screenView = GAIDictionaryBuilder.createScreenView().build() as NSDictionary? as? [AnyHashable: Any] ?? [:]
        tracker?.send( screenView )
        
        //dispatch now....
        GAI.sharedInstance().dispatch()
    }
    
    func startAttractLoop() {
        
        //only start if we are showing
//        if( !self.isViewLoaded || /*self.view.window == false */ self.view.window == nil) {
//            debugPrint("View not viewable")
//            return
//        }
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        if( delegate.isVideoUp ) {
            debugPrint("Video is already playing.  Ignore. \(self)")
            return
        } else {
            debugPrint("Start Attract Loop \(self)")
        }
        

        loadingView = UIView(frame: self.view.frame)
        loadingView?.backgroundColor = UIColor.black
        
        let tempDir = NSTemporaryDirectory()
        let fullPath = "\(tempDir)attract_loop.mp4"
        
        
        let vidURL = URL( fileURLWithPath: fullPath )
//        let vidURL = NSURL(fileURLWithPath: Bundle.main.path(forResource: "1Sum_Attract", ofType: "mp4")! )
        
        self.loadingAVPlayer = AVPlayer(url: vidURL as URL)
        let playerLayer = AVPlayerLayer(player: self.loadingAVPlayer)
        playerLayer.frame = loadingView!.bounds
        loadingView!.layer.addSublayer(playerLayer)
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(BaseViewController.stopAttractLoop))
        loadingView!.addGestureRecognizer( gr )
        
        self.view.addSubview( loadingView! )
        
        self.loadingAVPlayer!.actionAtItemEnd = AVPlayerActionAtItemEnd.none
        
        //add listener for movie ended
        NotificationCenter.default.addObserver(self, selector: #selector(BaseViewController.attractLoopEnded(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.loadingAVPlayer!.currentItem)
        
        self.loadingAVPlayer!.play()
        
        delegate.isVideoUp = true
    }
    
    @objc fileprivate func attractLoopEnded(_ notification: Notification) {
        debugPrint("Attract Loop Ended:  Restart!")
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }
    
    func stopAttractLoop() {
        
        debugPrint("Stopping attract loop")
        self.loadingAVPlayer?.pause()
        self.loadingView?.removeFromSuperview()
        self.loadingView = nil
        self.loadingAVPlayer = nil
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.isVideoUp = false
        
        //NSNotificationCenter.defaultCenter().postNotificationName("AttractLoopUserStopped", object: nil)
        
    }
    
    func setIsModalUp( _ bool: Bool ) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.isModalUp = bool
    }
    
    func isModalUp() -> Bool {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.isModalUp
    }
    
    func showSetup(){
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "SettingsViewController")
        self.present(vc, animated: true, completion: {})        
    }
    
    func showProgress(message: String, showBackbround: Bool){
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = message
        hud.label.textColor = UIColor.white
        if showBackbround {
            hud.backgroundColor = UIColor.black
        } else {
            hud.backgroundColor = UIColor.clear
        }
     
        hud.isUserInteractionEnabled = false
        self.view.isUserInteractionEnabled = false
        
    }
    
    func hideProgress() {
        DispatchQueue.main.async(execute: {
            
            _ = [MBProgressHUD.hide(for: self.view, animated: true)]

        })
        self.view.isUserInteractionEnabled = true
    }
    
    func seedHits(id: Int!,name: String!, url: String!, branchId: String!) {
        
        let seedMOC = DataController().managedObjectContext
        let entity = NSEntityDescription.insertNewObject(forEntityName: "PageViews", into: seedMOC) as! PageViews
        
        
        entity.setValue(id, forKey: "id")
        entity.setValue(name, forKey: "documentName")
        entity.setValue(url, forKey: "documentURL")
        entity.setValue(branchId, forKey: "branchId")
        
        do {
            try seedMOC.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
}
