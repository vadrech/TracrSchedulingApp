//
//  Assignment+CoreDataProperties.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 7/10/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//
//

import Foundation
import CoreData


extension Assignment {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assignment> {
        return NSFetchRequest<Assignment>(entityName: "Assignment")
    }

    @NSManaged public var duedate: Date
    @NSManaged public var name: String
    @NSManaged public var progress: Int64
    @NSManaged public var subject: String
    @NSManaged public var timeleft: Int64
    @NSManaged public var totaltime: Int64
    @NSManaged public var color: String
    @NSManaged public var grade: Int64
    @NSManaged public var completed: Bool
    @NSManaged public var type: String
    
}

