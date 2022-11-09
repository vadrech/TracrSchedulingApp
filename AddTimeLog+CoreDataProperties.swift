//
//  AddTimeLog+CoreDataProperties.swift
//  SchedulingApp
//
//  Created by Charan Vadrevu on 06.10.20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//
//

import Foundation
import CoreData


extension AddTimeLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AddTimeLog> {
        return NSFetchRequest<AddTimeLog>(entityName: "AddTimeLog")
    }

    @NSManaged public var name: String?
    @NSManaged public var length: Int64
    @NSManaged public var color: String?
    @NSManaged public var starttime: Date?
    @NSManaged public var endtime: Date?
    @NSManaged public var date: Date?
    @NSManaged public var completionpercentage: Double

}

extension AddTimeLog : Identifiable {

}
