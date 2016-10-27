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
    @IBOutlet weak var accessToken: UITextField!
    @IBOutlet weak var printerLabel: UILabel!
    
    let settings = PODSettings.instance
    
    var printer: UIPrinter?
    
    override func viewDidLoad() {
        
        let regionCode = settings.getRegionCode()
        let accessToken = settings.getAccessToken()
        printer = settings.getPrinter()
        
        self.regionIdentifier.text = regionCode
        self.accessToken.text = accessToken
        if( printer != nil ) {
            self.printerLabel.text = printer?.displayName
        }
    }
    
    @IBAction func clickSave(_ sender: AnyObject) {
        debugPrint("Save")
        
        if( printer == nil && self.regionIdentifier.text == nil && self.accessToken.text == nil) {
            
            let alert = UIAlertController(title: "Error", message: "You must input a access token, a region code and select a printer to continue", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
                
            })
            
            alert.addAction( okAction )
            self.present(alert, animated: true, completion: nil)
            
            
        } else if (self.accessToken.text == nil) {
            
            let alert = UIAlertController(title: "Error", message: "Please enter your access token to continue.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
                
                self.settings.saveRegionCode( self.regionIdentifier.text! )
                self.settings.saveAccessToken( self.accessToken.text! )
                
                self.checkRegistration()
                
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
                
                
                
            })
            
            alert.addAction( okAction )
            alert.addAction( cancelAction )
            
            self.present(alert, animated: true, completion: nil)
            
        } else if( printer == nil ) {
            
            let alert = UIAlertController(title: "Error", message: "Please select a printer to enable printing, or click OK to continue without a printer.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
                
                self.settings.saveRegionCode( self.regionIdentifier.text! )
                self.settings.saveAccessToken(self.accessToken.text!)
                self.checkRegistration()
                
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
                
                
                
            })
            
            alert.addAction( okAction )
            alert.addAction( cancelAction )
            
            self.present(alert, animated: true, completion: nil)
            
            
            
            
        } else {
            
            settings.savePrinter( printer! )
            settings.saveRegionCode( self.regionIdentifier.text! )
            settings.saveAccessToken(self.accessToken.text!)
            
            checkRegistration()
            
        }
    }
    
    fileprivate func checkRegistration() {
        
        self.showProgress()
        PODClient.instance.register(accessToken: self.accessToken.text!, branchId: self.regionIdentifier.text!, completion: {(completed :Bool, branchName: String? ) -> Void in
            
            if( completed ) {
                
                DispatchQueue.main.async(execute: {
                    
                    //self.dismissViewControllerAnimated(true, completion: nil)
                    let alert = UIAlertController(title: "Info", message: "This code is for branch: \(branchName!).  Select OK to continue to use this branch.", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
                        
                        self.dismiss(animated: false, completion: nil)
                        
                    })
                    
                    let cancelAction = UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
                        
                        
                        
                    })
                    
                    alert.addAction( okAction )
                    alert.addAction( cancelAction )
                    self.present(alert, animated: true, completion: nil)
                    self.hideProgress()
                })
                
                
            } else {
                
                DispatchQueue.main.async(execute: {
                    
                    let alert = UIAlertController(title: "Error", message: "Not able to register with code \(self.regionIdentifier.text!). Check your code and internet connection.", preferredStyle: UIAlertControllerStyle.alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
                        
                        
                    })
                    
                    alert.addAction( okAction )
                    self.present(alert, animated: true, completion: nil)
                    self.hideProgress()
                })
                

                
            }
        })

        
    }
    
    @IBAction func clickPrinter(_ sender: AnyObject) {
        
        let printerPicker = UIPrinterPickerController(initiallySelectedPrinter: nil)
        printerPicker.delegate = self
        
        printerPicker.present(from: CGRect(x: 0, y: 0, width: 0, height: 0), in: self.view, animated: true, completionHandler: {(pickerController, completed, error)  in
            
            if( completed ) {
                debugPrint( pickerController.selectedPrinter )
                
                self.printer = pickerController.selectedPrinter
                self.printerLabel.text = self.printer!.displayName
                debugPrint("Selected Printer:\(self.printer!.url)")
                
                //print test page
                let testPath = Bundle.main.path(forResource: "small", ofType: "pdf")
                let testPDFUrl = URL(fileURLWithPath: testPath!)
                
                let printinfo = UIPrintInfo(dictionary: nil)
                
                printinfo.jobName = "Test Page"
                printinfo.outputType = .general
                
                let printController = UIPrintInteractionController.shared
                printController.printInfo = printinfo
                printController.showsNumberOfCopies = false
                
                printController.printingItem = testPDFUrl
                
                printController.print(to: self.printer!, completionHandler: {(printController, completed, error) in
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
    
    func printerPickerControllerDidPresent(_ printerPickerController: UIPrinterPickerController) {
        debugPrint("Picker Presented")
    }
    
    func printerPickerController(_ printerPickerController: UIPrinterPickerController, shouldShow printer: UIPrinter) -> Bool {
        debugPrint("shouldShowPrinter:\(printer.description)")
        return true
    }
    
    func printerPickerControllerParentViewController(_ printerPickerController: UIPrinterPickerController) -> UIViewController? {
        return self
    }
}
