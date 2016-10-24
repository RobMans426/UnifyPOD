//
//  PODSettings.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/25/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import UIKit

class PODSettings : NSObject {
    
    static let instance = PODSettings()
    
    let KEY_PRINTER_URL = "pod_printer_url"
    let KEY_REGION_CODE = "pod_region_code"
    let KEY_AUTH_TOKEN = "pod_auth_token"
    
    override private init() {
        
    }
    
    func savePrinter( printer:UIPrinter ) -> Void {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(printer.URL.absoluteString, forKey: KEY_PRINTER_URL)
    }
    
    func getPrinter() -> UIPrinter? {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let urlstring = defaults.valueForKey( KEY_PRINTER_URL ) as? String
        
        if( urlstring != nil ) {
            
            let url = NSURL(string: urlstring!)
            return UIPrinter(URL: url! )
        }
        
        return nil
    }
    
    
    
    
    func saveRegionCode( code:String ) -> Void {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(code, forKey: KEY_REGION_CODE)
        
    }
    
    func getRegionCode() -> String? {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.valueForKey( KEY_REGION_CODE ) as? String
    }
    
    
    
    
    func saveAuthToken( code:String ) -> Void {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setValue(code, forKey: KEY_AUTH_TOKEN)
        
    }
    
    func getAuthToken() -> String? {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        return defaults.valueForKey( KEY_AUTH_TOKEN ) as? String
    }
    
    
    
}