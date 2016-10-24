//
//  PopupEmailViewController.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/27/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import UIKit

class PopupEmailViewController : BaseViewController {
    
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    var pdfURL:String = ""
    
    override func viewDidLoad() {
        
        errorLabel.hidden = true
        
        
    }
    
    @IBAction func clickClose(sender: AnyObject) {
        self.presentingViewController?.dismissViewControllerAnimated(false, completion: {
            NSNotificationCenter.defaultCenter().postNotificationName("PDFRemoveBlur", object: nil)
        })

    }
    
    @IBAction func clickSend(sender: AnyObject) {
        debugPrint("Send Email")
        
        do {
            
            let email = self.emailField.text!
            let regEmai = try NSRegularExpression(pattern: "^[\\w\\.\\:]+@\\w+\\.\\w+$", options: NSRegularExpressionOptions.CaseInsensitive)
            let range = NSMakeRange(0, email.characters.count)
            
            if regEmai.numberOfMatchesInString( email, options: NSMatchingOptions.Anchored, range: range) == 0 {
                
                self.errorLabel.text = "Pleae enter a valid email address"
                self.errorLabel.hidden = false
                
            } else {
                
                PODClient.instance.sendEmail( emailField.text!, documentURL: pdfURL, completion: {(completed:Bool) -> Void in
                    
                    if( completed ) {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                        //dismiss self
                        self.dismissViewControllerAnimated(false, completion: nil)
                        
                        //show success
                        let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
                        let vc = sb.instantiateViewControllerWithIdentifier("PopupSuccessViewController") as! PopupSuccessViewController
                        
                        vc.successType = PopupSuccessViewController.SuccessType.EMAIL
                        
                        vc.modalInPopover = true
                        vc.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
                        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                        
                        self.presentingViewController!.presentViewController(vc, animated: true, completion: {})
                        
                        })
                        
                    } else {
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            let alert = UIAlertController(title: "Error", message: "Sorry, the email option is unavailable at this time. Please ask a Branch Representative for assistance.", preferredStyle: UIAlertControllerStyle.Alert)
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                                
                            })
                            
                            alert.addAction( okAction )
                            self.presentViewController(alert, animated: true, completion: nil)

                            
                            
                        })
                        
                        
                    }
                })
                
            
                
                
            }
            
        } catch {
            
            debugPrint("Error:\(error)")
        }
        
        
        
    }
}