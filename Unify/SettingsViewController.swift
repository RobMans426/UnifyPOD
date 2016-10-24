//
//  SettingsViewController.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/25/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import UIKit

class SettingsViewController : BaseViewController, UIPrinterPickerControllerDelegate, UIAlertViewDelegate {
    
    @IBOutlet weak var regionIdentifier: UITextField!
    
    @IBOutlet weak var printerLabel: UILabel!
    
    let settings = PODSettings.instance
    
    var printer: UIPrinter?
    
    override func viewDidLoad() {
        
        let regionCode = settings.getRegionCode()
        printer = settings.getPrinter()
        
        self.regionIdentifier.text = regionCode
        
        if( printer != nil ) {
            self.printerLabel.text = printer?.displayName
        }
    }
    
    @IBAction func clickSave(sender: AnyObject) {
        debugPrint("Save")
        
        if( printer == nil && self.regionIdentifier.text == nil) {
            
            let alert = UIAlertController(title: "Error", message: "You must input a region and select a printer to continue", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                
            })
            
            alert.addAction( okAction )
            self.presentViewController(alert, animated: true, completion: nil)
            
            
        } else if( printer == nil ) {
            
            let alert = UIAlertController(title: "Error", message: "Please select a printer to enable printing, or click OK to continue without a printer.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                
                self.settings.saveRegionCode( self.regionIdentifier.text! )
                
                self.checkRegistration()
                
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                
                
                
            })
            
            alert.addAction( okAction )
            alert.addAction( cancelAction )
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            
            
            
        } else {
            
            settings.savePrinter( printer! )
            settings.saveRegionCode( self.regionIdentifier.text! )
            
            checkRegistration()
            
        }
    }
    
    private func checkRegistration() {
        
        
        PODClient.instance.register( self.regionIdentifier.text!, completion: {(completed :Bool, branchName: String? ) -> Void in
            
            if( completed ) {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    //self.dismissViewControllerAnimated(true, completion: nil)
                    let alert = UIAlertController(title: "Info", message: "This code is for branch: \(branchName!).  Select OK to continue to use this branch.", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                        
                        self.dismissViewControllerAnimated(false, completion: nil)
                        
                    })
                    
                    let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                        
                        
                        
                    })
                    
                    alert.addAction( okAction )
                    alert.addAction( cancelAction )
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                })
                
                
            } else {
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    let alert = UIAlertController(title: "Error", message: "Not able to register with code \(self.regionIdentifier.text!). Check your code and internet connection.", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(UIAlertAction) -> Void in
                        
                        
                    })
                    
                    alert.addAction( okAction )
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                })
                

                
            }
        })

        
    }
    
    @IBAction func clickPrinter(sender: AnyObject) {
        
        let printerPicker = UIPrinterPickerController(initiallySelectedPrinter: nil)
        printerPicker.delegate = self
        
        printerPicker.presentFromRect(CGRectMake(0, 0, 0, 0), inView: self.view, animated: true, completionHandler: {(pickerController:UIPrinterPickerController, completed:Bool, error:NSError?) -> Void in
            
            if( completed ) {
                debugPrint( pickerController.selectedPrinter )
                
                self.printer = pickerController.selectedPrinter
                self.printerLabel.text = self.printer!.displayName
                debugPrint("Selected Printer:\(self.printer!.URL)")
                
                //print test page
                let testPath = NSBundle.mainBundle().pathForResource("small", ofType: "pdf")
                let testPDFUrl = NSURL(fileURLWithPath: testPath!)
                
                let printinfo = UIPrintInfo(dictionary: nil)
                
                printinfo.jobName = "Test Page"
                printinfo.outputType = .General
                
                let printController = UIPrintInteractionController.sharedPrintController()
                printController.printInfo = printinfo
                printController.showsNumberOfCopies = false
                
                printController.printingItem = testPDFUrl
                
                printController.printToPrinter(self.printer!, completionHandler: {(printController:UIPrintInteractionController, completed:Bool, error:NSError?) -> Void in
                    debugPrint("Print Completion Handler")
                    
                    if( !completed ) {
                        debugPrint( "Print not completed" )
                    }
                    
                    if( error != nil ) {
                        debugPrint("ERROR Printing \(error?.localizedDescription)")
                    }
                    
                    
                })
                
            }
            
        })

    }
    
    func printerPickerControllerDidPresent(printerPickerController: UIPrinterPickerController) {
        debugPrint("Picker Presented")
    }
    
    func printerPickerController(printerPickerController: UIPrinterPickerController, shouldShowPrinter printer: UIPrinter) -> Bool {
        debugPrint("shouldShowPrinter:\(printer.description)")
        return true
    }
    
    func printerPickerControllerParentViewController(printerPickerController: UIPrinterPickerController) -> UIViewController? {
        return self
    }
}