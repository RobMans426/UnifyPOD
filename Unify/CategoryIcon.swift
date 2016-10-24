//
//  CategoryIcon.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 2/29/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import SwiftyJSON

class CategoryIcon : NSObject {
    
    var categoryId : String?
    var color : String?
    var label : String?
    var url : String?
    
    init( json: JSON ) {
        super.init()
        self.loadFromJSON( json )
    }
    
    private func loadFromJSON( json: JSON ) {
        
        self.categoryId = json["category_id"].string
        self.color = json["color"].string
        self.label = json["category_label"].string
        self.url = json["url"].string
    }
    
}
