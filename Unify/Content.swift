//
//  Content.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/26/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import SwiftyJSON

class Content : NSObject {
    
    //var label : String?
    var url : String?

    
    
    init( json: JSON ) {
        super.init()
        self.loadFromJSON( json )
    }
    
    fileprivate func loadFromJSON( _ json: JSON ) {
        
        //self.label = json["label"].string
        self.url = json["url"].string
    }
    
}
