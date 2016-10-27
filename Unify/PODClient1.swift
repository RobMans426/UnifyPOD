//
//  PODClient1.swift
//  UnifyPOD
//
//  Created by mobile on 10/27/16.
//  Copyright © 2016 Adrenaline. All rights reserved.
//

import UIKit

class PODClient1: NSObject {

    static let instance = PODClient1()
    
    var apiKey : String = ""
    var apiBase : String = "https://unify.adrenalineamp.com/api"
    var mandrillKey : String = ""
    
    var ENVIRONMENT : String = "PROD"
    
    var categories : Array<Category> = Array()
    var categoryIcons : Array<CategoryIcon> = Array()
    
}
