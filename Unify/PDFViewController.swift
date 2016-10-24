//
//  PDFViewController.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/25/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import UIKit

class PDFViewController : BaseViewController, UIPrinterPickerControllerDelegate {
    
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var printView: UIView!
    @IBOutlet weak var printImage: UIImageView!
    @IBOutlet weak var emailImage: UIImageView!
    
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var printButton: UIButton!
    
    @IBOutlet weak var webView: UIWebView!
    
    var pdfURL : NSURL?
    var content : Category?
    
    var blurView: UIVisualEffectView?
    
    
    override func getGAIName() -> String? {
        
        if (content?.label != nil) {
            return "Document View - \(content!.label!)"
        }
        else {
            return nil
        }
        
    }
    
    override func viewDidLoad() {
        
        setupButtons()
        
        let request = NSURLRequest(URL: pdfURL!)
        webView.scalesPageToFit = true
        webView.loadRequest( request )
    }
    
    func setupButtons() {
        
        emailButton.addTarget(self, action: "buttonSelected:", forControlEvents: UIControlEvents.TouchDown)
        printButton.addTarget(self, action: "buttonSelected:", forControlEvents: UIControlEvents.TouchDown)
        
        emailButton.addTarget(self, action: "clickEmail:", forControlEvents: UIControlEvents.TouchUpInside)
        printButton.addTarget(self, action: "clickPrint:", forControlEvents: UIControlEvents.TouchUpInside)
        
        emailButton.addTarget(self, action: "buttonUnselected:", forControlEvents: UIControlEvents.TouchUpOutside)
        printButton.addTarget(self, action: "buttonUnselected:", forControlEvents: UIControlEvents.TouchUpOutside)
        
        
    }
    
    func buttonSelected( button: UIButton ) {
        
        
        if( button == self.printButton ) {
            
            
            printView.backgroundColor = UIColor(red: 82/255, green: 195/255, blue: 237/255, alpha: 1)
            printImage.image = UIImage(named: "printer_over")
            
        } else {
            emailView.backgroundColor = UIColor(red: 82/255, green: 195/255, blue: 237/255, alpha: 1)
            emailImage.image = UIImage(named: "email_over")
        }
        
    }
    
    func buttonUnselected( button: UIButton ) {
        
        if( button == self.printButton ) {
            
            printView.backgroundColor = UIColor.blackColor()
            printImage.image = UIImage(named: "printer_off")
            
        } else {
            
            emailView.backgroundColor = UIColor.blackColor()
            emailImage.image = UIImage(named: "email_off")
        }
        
    }
    
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "removeBlurView", name: "PDFRemoveBlur", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver( self )
    }
    
    @IBAction func clickClose(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
        super.setIsModalUp( false )
    }
    
    func addBlurView() {
        blurView = UIVisualEffectView(frame: self.view.bounds)
        blurView!.effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        self.view.addSubview( blurView! )
    }
    
    func removeBlurView() {
        
        if( blurView != nil ) {
            debugPrint("Remove Blur View.")
            blurView?.removeFromSuperview()
            blurView = nil
        }
    }
    
    
    @IBAction func clickEmail(sender: AnyObject) {
        debugPrint("clickEmail")
        
        addBlurView()
        
        let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("PopupEmailViewController") as! PopupEmailViewController
        
        vc.modalInPopover = true
        vc.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        vc.pdfURL = self.content!.content!.url!
            
        self.presentViewController(vc, animated: true, completion: {})
        
        self.buttonUnselected( emailButton )
    }
    
    @IBAction func clickPrint(sender: AnyObject) {
        debugPrint("clickPrint")
        
        addBlurView()
        
        let settings = PODSettings.instance
        
        if settings.getPrinter() != nil && UIPrintInteractionController.canPrintURL( pdfURL! ) {
            
            let printinfo = UIPrintInfo(dictionary: nil)
            
            printinfo.jobName = pdfURL!.lastPathComponent!
            printinfo.outputType = .General
            
            let printController = UIPrintInteractionController.sharedPrintController()
            printController.printInfo = printinfo
            printController.showsNumberOfCopies = false
            
            debugPrint("PrintItem: \(pdfURL)")
            
            printController.printingItem = pdfURL
            
            debugPrint("Settings Printer: \(settings.getPrinter()?.URL)")
            
            let printerPicker = UIPrinterPickerController(initiallySelectedPrinter: nil)
            printerPicker.delegate = self
            
            let printer = settings.getPrinter()!
            
            printerPicker.delegate = self
            
            /*
            
            printerPicker.presentFromRect(<#T##rect: CGRect##CGRect#>, inView: self.view, animated: false, completionHandler: completionHandler: {(pickerController:UIPrinterPickerController, completed:Bool, error:NSError?) -> Void in)
            */
            /*
            printerPicker.presentFromRect(CGRectMake(0, 0, 0, 0), inView: self.view, animated: true, completionHandler: {(pickerController:UIPrinterPickerController, completed:Bool, error:NSError?) -> Void in
                
                if( completed ) {
                    debugPrint( pickerController.selectedPrinter )
                    //let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    //delegate.defaultPrinter = pickerController.selectedPrinter
                    let printer2 = pickerController.selectedPrinter
                    
                    debugPrint("Selected Printer:\(printer2?.URL)")
                    
                    printController.printToPrinter(printer, completionHandler: {(printController:UIPrintInteractionController, completed:Bool, error:NSError?) -> Void in
                        debugPrint("Print Completion Handler")
                        
                        if( !completed ) {
                            debugPrint( "Print not completed" )
                        }
                        
                        if( error != nil ) {
                            debugPrint("ERROR Printing \(error?.localizedDescription)")
                        }
                        
                        let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
                        let vc = sb.instantiateViewControllerWithIdentifier("PopupSuccessViewController") as! PopupSuccessViewController
                        
                        vc.successType = PopupSuccessViewController.SuccessType.PRINT
                        
                        vc.modalInPopover = true
                        vc.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
                        vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                        
                        self.presentViewController(vc, animated: true, completion: {})
                    })
                    
                }
                
            })
*/
            
            
            printController.printToPrinter(printer, completionHandler: {(printController:UIPrintInteractionController, completed:Bool, error:NSError?) -> Void in
                debugPrint("Print Completion Handler")
                
                if( !completed ) {
                    debugPrint( "Print not completed" )
                }
                
                if( error != nil ) {
                    debugPrint("ERROR Printing \(error?.localizedDescription)")
                }
                
                let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
                let vc = sb.instantiateViewControllerWithIdentifier("PopupSuccessViewController") as! PopupSuccessViewController
                
                vc.successType = PopupSuccessViewController.SuccessType.PRINT
                
                vc.modalInPopover = true
                vc.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
                vc.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
                
                self.presentViewController(vc, animated: true, completion: {})
            })

            
            self.buttonUnselected( printButton )
            
        } else {
            
            let alert = UIAlertController(title: "Error", message: "Sorry, the printer is unavailable at this time. Please notify a Branch Representative to assist you.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                
                self.removeBlurView()
                
            })
            
            alert.addAction( okAction )
            self.presentViewController(alert, animated: true, completion: nil)

            
            debugPrint("Can not print PDF")
            
        }
    }
    
    
}