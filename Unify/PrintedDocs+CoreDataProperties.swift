//
//  PrintedDocs+CoreDataProperties.swift
//  
//
//  Created by Josh Robinson on 10/13/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension PrintedDocs {

    @nonobjc class func fetchRequest() -> NSFetchRequest<PrintedDocs> {
        return NSFetchRequest<PrintedDocs>(entityName: "PrintedDocs");
    }
    
    @NSManaged var id: NSNumber?
    @NSManaged var documentName: String?
    @NSManaged var documentURL: String?
    @NSManaged var branchId: String?

}
