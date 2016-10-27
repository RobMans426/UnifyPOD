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
        
        let tapgr = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.viewTapped))
        self.view.addGestureRecognizer( tapgr )
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.viewTapped), name: NSNotification.Name(rawValue: "AttractLoopUserStopped"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.reloadData), name: NSNotification.Name(rawValue: "ReloadData"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let settings = PODSettings.instance
        
        if( !shownSettings && (settings.getPrinter() == nil || settings.getRegionCode() == nil || settings.getRegionCode() == "" )) {
            
            self.shownSettings = true
            
            debugPrint("Show Settings...")
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateViewController(withIdentifier: "SettingsViewController")
            self.present(vc, animated: true, completion: {})
            
        } else {
            
            if( PODClient.instance.categories.count == 0 ) {
                
                self.loadData({(completed:Bool) -> Void in
                    
                    if( completed ) {
                        DispatchQueue.main.async(execute: {
                            
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
    
    func loadData( _ completion: @escaping (_ completed:Bool) -> Void ) {
        
        debugPrint( "Reload Data!" )
        self.showProgress()
        //register
        PODClient.instance.register(branchId: PODSettings.instance.getRegionCode()!, completion: { (completed:Bool, branchName:String?) -> Void in
            
            if( completed ) {
                
                PODClient.instance.loadDocumentTree(branchId: PODSettings.instance.getRegionCode()!, completion:{(completed:Bool) -> Void in
                    
                    if( completed ) {
                        
                        debugPrint("DONE!")
                        //grab icons
                        PODClient.instance.loadIcons(branchId: PODSettings.instance.getRegionCode()!, completion:{(completed:Bool) -> Void in
                            
                            if (completed){
                                self.hideProgress()
                            } else{
                                debugPrint("Error: LoadIcon failed")
                                completion( false )
                                self.hideProgress()
                            }
                            PODClient.instance.loadVideo(branchId: PODSettings.instance.getRegionCode()!, completion:{(completed:Bool) -> Void in
                                
                                DispatchQueue.main.async(execute: {
                                    
                                    //self.completeSetup()
                                    completion( true )
                                    
                                })
                                
                            })
                            
                        })
                        
                        
                    } else {
                        
                        debugPrint("Error: LoadDocumentTree failed")
                        completion( false )
                        self.hideProgress()
                    }
                    
                })
                
                
            } else {
                
                debugPrint("Error: Registration Failed")
                completion( false )
                self.hideProgress()
            }
            
        })

        
    }
    
    func completeSetup() {
        
        super.startAttractLoop()
        NotificationCenter.default.addObserver(self, selector: Selector(("appTimeout")), name: NSNotification.Name(rawValue: "KioskApplicationTimeout"), object: nil)
        
    }
    
    func viewTapped() {
        
        let sb = UIStoryboard(name: "DocumentTree", bundle: nil)
        let vc = sb.instantiateInitialViewController()!
        self.present(vc, animated: true, completion: {})
        
    }
    
}
