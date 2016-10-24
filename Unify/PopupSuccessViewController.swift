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
        case EMAIL
        case PRINT
    }
    
    var successType: SuccessType = SuccessType.PRINT
    
    override func viewDidLoad() {
        
        //make info label say correct message
        
        if( self.successType == SuccessType.EMAIL ) {
            //email
            infoLabel.text = "Your information was emailed."
            
        } else {
            //print
            infoLabel.text = "Your information is printing."
            
        }
        
        
        
    }
    
    @IBAction func clickReturn(sender: AnyObject) {
        debugPrint("PopupSuccess clickReturn")
        
         NSNotificationCenter.defaultCenter().postNotificationName("DocumentTreeCloseModals", object: nil)
        
    }
    
    
    @IBAction func clickDone(sender: AnyObject) {
        debugPrint("PopupSuccess clickDone")
        
        self.presentingViewController?.dismissViewControllerAnimated(false, completion: {
            NSNotificationCenter.defaultCenter().postNotificationName("DocumentTreeReturnToMain", object: nil)
        })
    }
}