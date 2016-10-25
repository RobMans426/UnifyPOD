//
//  KioskApplication.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/25/16.
//  Copyright © 2015 DragonArmy. All rights reserved.
//

//import Cocoa
import UIKit

class KioskApplication: UIApplication {
    
    var idleTimer: Timer?
    
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)
        
        let touches = event.allTouches
        if( (touches?.count)! > 0 ) {
            let phase = touches?.first?.phase
            if( phase == UITouchPhase.began ) {
                debugPrint("Tapped")
                self.resetIdleTimer()
            }
            
        }
    }
    
    func resetIdleTimer() {
        
        if( self.idleTimer != nil ) {
            self.idleTimer?.invalidate()
        }
        
        let timeOut = 60.0
        self.idleTimer = Timer.scheduledTimer(timeInterval: timeOut, target: self, selector: #selector(KioskApplication.idleTimerExceeded), userInfo: nil, repeats: false)
        
    }
    
    func idleTimerExceeded() {
        debugPrint("idleTimerExceeded")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "KioskApplicationTimeout"), object: nil)
        }

}
