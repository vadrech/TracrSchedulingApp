//
//  Subassignmentnew+CoreDataProperties.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 7/15/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//
//

import Foundation
import CoreData


extension Subassignmentnew {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Subassignmentnew> {
        return NSFetchRequest<Subassignmentnew>(entityName: "Subassignmentnew")
    }

    @NSManaged public var assignmentname: String
    @NSManaged public var startdatetime: Date
    @NSManaged public var enddatetime: Date
    @NSManaged public var color: String
    @NSManaged public var assignmentduedate: Date

}
