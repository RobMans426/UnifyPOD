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
    
    override fileprivate init() {
        
    }
    
    func savePrinter( _ printer:UIPrinter ) -> Void {
        
        let defaults = UserDefaults.standard
        defaults.setValue(printer.url.absoluteString, forKey: KEY_PRINTER_URL)
    }
    
    func getPrinter() -> UIPrinter? {
        
        let defaults = UserDefaults.standard
        let urlstring = defaults.value( forKey: KEY_PRINTER_URL ) as? String
        
        if( urlstring != nil ) {
            
            let url = URL(string: urlstring!)
            return UIPrinter(url: url! )
        }
        
        return nil
    }
    
    
    
    
    func saveRegionCode( _ code:String ) -> Void {
        
        let defaults = UserDefaults.standard
        defaults.setValue(code, forKey: KEY_REGION_CODE)
        
    }
    
    func getRegionCode() -> String? {
        
        let defaults = UserDefaults.standard
        return defaults.value( forKey: KEY_REGION_CODE ) as? String
    }
    
    
    
    
    func saveAuthToken( _ code:String ) -> Void {
        
        let defaults = UserDefaults.standard
        defaults.setValue(code, forKey: KEY_AUTH_TOKEN)
        
    }
    
    func getAuthToken() -> String? {
        
        let defaults = UserDefaults.standard
        return defaults.value( forKey: KEY_AUTH_TOKEN ) as? String
    }
    
    
    
}
