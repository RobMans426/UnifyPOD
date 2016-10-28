//
//  PageViews+CoreDataProperties.swift
//  
//
//  Created by Josh Robinson on 10/11/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PageViews {

    @nonobjc class func fetchRequest() -> NSFetchRequest<PageViews> {
        return NSFetchRequest<PageViews>(entityName: "PageViews");
    }
    
    @NSManaged var id: NSNumber?
    @NSManaged var documentName: String?
    @NSManaged var documentURL: String?
    @NSManaged var branchId: String?

}
