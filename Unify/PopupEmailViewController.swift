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
        
        errorLabel.isHidden = true
        
    }
    
    @IBAction func clickClose(_ sender: AnyObject) {
        self.presentingViewController?.dismiss(animated: false, completion: {
            NotificationCenter.default.post(name: Notification.Name(rawValue: "PDFRemoveBlur"), object: nil)
        })

    }
    
    @IBAction func clickSend(_ sender: AnyObject) {
        debugPrint("Send Email")
        
        do {
            
            let email = self.emailField.text!
            let regEmai = try NSRegularExpression(pattern: "^[\\w\\.\\:]+@\\w+\\.\\w+$", options: NSRegularExpression.Options.caseInsensitive)
            let range = NSMakeRange(0, email.characters.count)
            
            if regEmai.numberOfMatches( in: email, options: NSRegularExpression.MatchingOptions.anchored, range: range) == 0 {
                
                self.errorLabel.text = "Pleae enter a valid email address"
                self.errorLabel.isHidden = false
                
            } else {
                
                PODClient.instance.sendEmail( recipient: emailField.text!, documentURL: pdfURL, completion: {(completed:Bool) -> Void in
                    
                    if( completed ) {
                        
                        DispatchQueue.main.async(execute: {
                        //dismiss self
                        self.dismiss(animated: false, completion: nil)
                        
                        //show success
                        let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
                        let vc = sb.instantiateViewController(withIdentifier: "PopupSuccessViewController") as! PopupSuccessViewController
                        
                        vc.successType = PopupSuccessViewController.SuccessType.email
                        
                        vc.isModalInPopover = true
                        vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                        
                        self.presentingViewController!.present(vc, animated: true, completion: {})
                        
                        })
                        
                    } else {
                        
                        DispatchQueue.main.async(execute: {
                            
                            let alert = UIAlertController(title: "Error", message: "Sorry, the email option is unavailable at this time. Please ask a Branch Representative for assistance.", preferredStyle: UIAlertControllerStyle.alert)
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
                                
                            })
                            
                            alert.addAction( okAction )
                            self.present(alert, animated: true, completion: nil)
                            
                        })
                        
                        
                    }
                })
                
            
                
                
            }
            
        } catch {
            
            debugPrint("Error:\(error)")
        }
        
        
        
    }
}
