//
//  PDFViewController.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/25/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PDFViewController : BaseViewController, UIPrinterPickerControllerDelegate {
    
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var printView: UIView!
    @IBOutlet weak var printImage: UIImageView!
    @IBOutlet weak var emailImage: UIImageView!
    
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var printButton: UIButton!
    
    @IBOutlet weak var webView: UIWebView!
    
    var pdfURL: URL?
    var content: Category?
    var category: Content?
    var blurView: UIVisualEffectView?
    
    // ****** for getting google analytics trackers ******
    
    // PDF name
    override func getGAIName() -> String? {
        
        if (content?.label != nil) {
            return "Document View - \(content!.label!)"
        }
        else {
            return nil
        }
        
    }
    
    // PDF id
    override func getGAIid() -> String? {
        
        if (content?.id != nil) {
            return content!.id!
        } else{
            return nil
        }
    }
    
    // PDF url
    override func getGAIUrl() -> String? {
        
        if (content?.url != nil) {
            return content!.url!
        } else{
            return nil
        }
    }
    
    override func viewDidLoad() {
        
        setupButtons()
        
        let request = URLRequest(url: pdfURL!)
        webView.scalesPageToFit = true
        webView.loadRequest( request )
    }
    
    // ********************************************************
    
    func setupButtons() {
        
        emailButton.addTarget(self, action: #selector(PDFViewController.buttonSelected(_:)), for: UIControlEvents.touchDown)
        printButton.addTarget(self, action: #selector(PDFViewController.buttonSelected(_:)), for: UIControlEvents.touchDown)
        
        emailButton.addTarget(self, action: #selector(PDFViewController.clickEmail(_:)), for: UIControlEvents.touchUpInside)
        printButton.addTarget(self, action: #selector(PDFViewController.clickPrint(_:)), for: UIControlEvents.touchUpInside)
        
        emailButton.addTarget(self, action: #selector(PDFViewController.buttonUnselected(_:)), for: UIControlEvents.touchUpOutside)
        printButton.addTarget(self, action: #selector(PDFViewController.buttonUnselected(_:)), for: UIControlEvents.touchUpOutside)
        
        
    }
    
    func buttonSelected( _ button: UIButton ) {
        
        
        if( button == self.printButton ) {
            
            printView.backgroundColor = UIColor(red: 82/255, green: 195/255, blue: 237/255, alpha: 1)
            printImage.image = UIImage(named: "printer_over")
            
        } else {
            emailView.backgroundColor = UIColor(red: 82/255, green: 195/255, blue: 237/255, alpha: 1)
            emailImage.image = UIImage(named: "email_over")
        }
        
    }
    
    func buttonUnselected( _ button: UIButton ) {
        
        if( button == self.printButton ) {
            
            printView.backgroundColor = UIColor.black
            printImage.image = UIImage(named: "printer_off")
            
        } else {
            
            emailView.backgroundColor = UIColor.black
            emailImage.image = UIImage(named: "email_off")
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(PDFViewController.removeBlurView), name: NSNotification.Name(rawValue: "PDFRemoveBlur"), object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver( self )
    }
    
    @IBAction func clickClose(_ sender: AnyObject) {
        self.dismiss(animated: false, completion: nil)
        super.setIsModalUp( false )
    }
    
    func addBlurView() {
        blurView = UIVisualEffectView(frame: self.view.bounds)
        blurView!.effect = UIBlurEffect(style: UIBlurEffectStyle.light)
        self.view.addSubview( blurView! )
    }
    
    func removeBlurView() {
        
        if( blurView != nil ) {
            debugPrint("Remove Blur View.")
            blurView?.removeFromSuperview()
            blurView = nil
        }
    }
    
    
    @IBAction func clickEmail(_ sender: AnyObject) {
        debugPrint("clickEmail")
        
        addBlurView()
        
        let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "PopupEmailViewController") as! PopupEmailViewController
        
        vc.isModalInPopover = true
        vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
        vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
        vc.pdfURL = self.content!.content!.url!
            
        self.present(vc, animated: true, completion: {})
        
        // add to EmailDocs entity
        self.seedEmails(id: Int(self.getGAIid()!), name: self.getGAIName(), url: self.getGAIUrl(), branchId: settingControl.getRegionCode())
        
        self.buttonUnselected( emailButton )
    }
    
    @IBAction func clickPrint(_ sender: AnyObject) {
        debugPrint("clickPrint")
        
        addBlurView()
        
        let settings = PODSettings.instance
        
        if settings.getPrinter() != nil && UIPrintInteractionController.canPrint( pdfURL! ) {
            
            let printinfo = UIPrintInfo(dictionary: nil)
            
            printinfo.jobName = pdfURL!.lastPathComponent
            printinfo.outputType = .general
            
            let printController = UIPrintInteractionController.shared
            printController.printInfo = printinfo
            printController.showsNumberOfCopies = false
            
            debugPrint("PrintItem: \(pdfURL)")
            
            printController.printingItem = pdfURL
            
            debugPrint("Settings Printer: \(settings.getPrinter()?.url)")
            
            let printerPicker = UIPrinterPickerController(initiallySelectedPrinter: nil)
            printerPicker.delegate = self
            
            let printer = settings.getPrinter()!
            
            printerPicker.delegate = self
            
            printController.print(to: printer, completionHandler: { (printController, completed, error) in
                debugPrint("Print Completion Handler")
                
                if( !completed ) {
                    debugPrint( "Print not completed" )
                }
                
                if( error != nil ) {
                    debugPrint("ERROR Printing \(error?.localizedDescription)")
                }
                
                let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
                let vc = sb.instantiateViewController(withIdentifier: "PopupSuccessViewController") as! PopupSuccessViewController
                
                vc.successType = PopupSuccessViewController.SuccessType.print
                
                vc.isModalInPopover = true
                vc.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
                
                self.present(vc, animated: true, completion: {})
            })
            
            // add to PrintedDocs entity
            self.seedPrints(id: Int(self.getGAIid()!), name: self.getGAIName(), url: self.getGAIUrl(), branchId: settingControl.getRegionCode())
            self.buttonUnselected( printButton )
            
        } else {
            
            let alert = UIAlertController(title: "Error", message: "Sorry, the printer is unavailable at this time. Please notify a Branch Representative to assist you.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) -> Void in
                
                self.removeBlurView()
                
            })
            
            alert.addAction( okAction )
            self.present(alert, animated: true, completion: nil)

            
            debugPrint("Can not print PDF")
            
        }
    }
    
    func seedPrints(id: Int!,name: String!, url: String!, branchId: String!) {
        
        let seedMOC = DataController().managedObjectContext
        let entityPrint = NSEntityDescription.insertNewObject(forEntityName: "PrintedDocs", into: seedMOC) as! PrintedDocs
        
        
        entityPrint.setValue(id, forKey: "id")
        entityPrint.setValue(name, forKey: "documentName")
        entityPrint.setValue(url, forKey: "documentURL")
        entityPrint.setValue(branchId, forKey: "branchId")
        
        do {
            try seedMOC.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
    func seedEmails(id: Int!,name: String!, url: String!, branchId: String!) {
        
        let seedMOC = DataController().managedObjectContext
        let entityEmails = NSEntityDescription.insertNewObject(forEntityName: "EmailedDocs", into: seedMOC) as! EmailedDocs
        
        
        entityEmails.setValue(id, forKey: "id")
        entityEmails.setValue(name, forKey: "documentName")
        entityEmails.setValue(url, forKey: "documentURL")
        entityEmails.setValue(branchId, forKey: "branchId")
        
        do {
            try seedMOC.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
    }
    
}
