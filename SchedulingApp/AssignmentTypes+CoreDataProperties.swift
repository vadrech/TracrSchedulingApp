//
//  AssignmentTypes+CoreDataProperties.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 8/7/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//
//

import Foundation
import CoreData


extension AssignmentTypes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AssignmentTypes> {
        return NSFetchRequest<AssignmentTypes>(entityName: "AssignmentTypes")
    }

    @NSManaged public var type: String
    @NSManaged public var rangemin: Int64
    @NSManaged public var rangemax: Int64

}
