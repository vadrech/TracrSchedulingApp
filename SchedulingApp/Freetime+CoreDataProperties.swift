//
//  Freetime+CoreDataProperties.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 7/19/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//
//

import Foundation
import CoreData


extension Freetime {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Freetime> {
        return NSFetchRequest<Freetime>(entityName: "Freetime")
    }

    @NSManaged public var startdatetime: Date
    @NSManaged public var enddatetime: Date
    @NSManaged public var tempstartdatetime: Date
    @NSManaged public var tempenddatetime: Date
    @NSManaged public var monday: Bool
    @NSManaged public var tuesday: Bool
    @NSManaged public var wednesday: Bool
    @NSManaged public var thursday: Bool
    @NSManaged public var friday: Bool
    @NSManaged public var saturday: Bool
    @NSManaged public var sunday: Bool


}
