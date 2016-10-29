//
//  Category.swift
//  UnifyPOD
//
//  Created by Shawn Henck on 1/26/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import Foundation
import SwiftyJSON

class Category : NSObject {
    
    var id : String?
    var label : String?
    var url : String?
    
    var categories : Array<Category>?
    //var content : Array<Content>?
    var content : Content?
    var parent : Category?
    
    init( json: JSON ) {
        super.init()
        self.loadFromJSON( json )
    }
    
    fileprivate func loadFromJSON( _ json: JSON ) {
        
        self.label = json["label"].string
        self.id = json["id"].string
        self.url = json["content"]["url"].string
        
        if let catArray = json["children"].array {
            
            self.categories = Array<Category>()
            
            for cat in catArray {
                if let _ = cat.null {
                    debugPrint("Category is null")
                } else {
                    let category = Category(json: cat)
                    self.categories?.append( category )
                    category.parent = self
                }
                
            }
        }
        
        debugPrint( "Check Content for: \(self.label!)")
        
        if let _ = json["content"].dictionary {
            
            debugPrint( "Have Content for: \(self.label!)")
            let content = Content(json: json["content"])
            self.content = content 
        }
        
        /*
        if let contentArray = json["content"].array {
            
            self.content = Array<Content>()
            
            debugPrint( "Have Content for: \(self.label!) \(contentArray.count)")
            for con in contentArray {
                if let _ = con.null {
                    debugPrint("Content is null")
                } else {
                    let content = Content(json: con)
                    self.content?.append( content )
                }
                
            }
        }
*/
    }
    
}
