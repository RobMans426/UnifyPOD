//
//  HomeViewController.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/25/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import UIKit

class HomeViewController : BaseViewController {
    
    var shownSettings : Bool = false
    
    override func viewDidLoad() {
        
        //check to see if we need to present settings...
        
        let tapgr = UITapGestureRecognizer(target: self, action: "viewTapped")
        self.view.addGestureRecognizer( tapgr )
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "viewTapped", name: "AttractLoopUserStopped", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadData", name: "ReloadData", object: nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        let settings = PODSettings.instance
        
        if( !shownSettings && (settings.getPrinter() == nil || settings.getRegionCode() == nil || settings.getRegionCode() == "" )) {
            
            self.shownSettings = true
            
            debugPrint("Show Settings...")
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewControllerWithIdentifier("SettingsViewController")
            self.presentViewController(vc, animated: true, completion: {})
            
        } else {
            
            if( PODClient.instance.categories.count == 0 ) {
                
                self.loadData({(completed:Bool) -> Void in
                    
                    if( completed ) {
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            self.completeSetup()
                            
                        })
                    }
                    
                })
                
            }
        }
    }
    
    func reloadData() {
        self.loadData({(completed:Bool) -> Void in
            
            //meh do nothing
        
        })
    }
    
    func loadData( completion: (completed:Bool) -> Void ) {
        
        debugPrint( "Reload Data!" )
        
        /*
        PODClient.instance.register(PODSettings.instance.getRegionCode()!, completion: { (completed:Bool, branchName:String?) -> Void in
            
            if( completed ) {
                
                PODClient.instance.loadDocumentTree(PODSettings.instance.getRegionCode()!, completion:{(completed:Bool) -> Void in
                    
                    if( completed ) {
                        
                        debugPrint("DONE!")
                        
                        
                        completion( completed: true )
                    }
                })
                
            }
            })
        
        */
            
        
        
            
        //register
        PODClient.instance.register(PODSettings.instance.getRegionCode()!, completion: { (completed:Bool, branchName:String?) -> Void in
            
            if( completed ) {
                
                PODClient.instance.loadDocumentTree(PODSettings.instance.getRegionCode()!, completion:{(completed:Bool) -> Void in
                    
                    if( completed ) {
                        
                        debugPrint("DONE!")
                        
                        //grab icons
                        PODClient.instance.loadIcons(PODSettings.instance.getRegionCode()!, completion:{(completed:Bool) -> Void in
                            
                            PODClient.instance.loadVideo(PODSettings.instance.getRegionCode()!, completion:{(completed:Bool) -> Void in
                                
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    //self.completeSetup()
                                    completion( completed: true )
                                    
                                })
                                
                            })
                            
                        })
                        
                        
                    } else {
                        
                        debugPrint("Error: LoadDocumentTree failed")
                        completion( completed: false )
                        
                    }
                    
                })
                
                
            } else {
                
                debugPrint("Error: Registration Failed")
                completion( completed: false )
                
            }
            
        })

        
    }
    
    func completeSetup() {
        
        super.startAttractLoop()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "appTimeout", name: "KioskApplicationTimeout", object: nil)
        
    }
    
    func viewTapped() {
        
        let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
        let vc = sb.instantiateInitialViewController()!
        self.presentViewController(vc, animated: true, completion: {})
        
    }
    
}