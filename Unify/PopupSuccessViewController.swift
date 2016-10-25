//
//  PopupSuccessViewController.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/27/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import UIKit

class PopupSuccessViewController : BaseViewController {
    
    
    @IBOutlet weak var infoLabel: UILabel!
    
    enum SuccessType {
        case email
        case print
    }
    
    var successType: SuccessType = SuccessType.print
    
    override func viewDidLoad() {
        
        //make info label say correct message
        
        if( self.successType == SuccessType.email ) {
            //email
            infoLabel.text = "Your information was emailed."
            
        } else {
            //print
            infoLabel.text = "Your information is printing."
            
        }
        
        
        
    }
    
    @IBAction func clickReturn(_ sender: AnyObject) {
        debugPrint("PopupSuccess clickReturn")
        
         NotificationCenter.default.post(name: Notification.Name(rawValue: "DocumentTreeCloseModals"), object: nil)
        
    }
    
    
    @IBAction func clickDone(_ sender: AnyObject) {
        debugPrint("PopupSuccess clickDone")
        
        self.presentingViewController?.dismiss(animated: false, completion: {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "DocumentTreeReturnToMain"), object: nil)
        })
    }
}
