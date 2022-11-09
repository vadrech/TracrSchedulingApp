//
//  Classcool+CoreDataProperties.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 7/10/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//
//

import Foundation
import CoreData


extension Classcool {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Classcool> {
        return NSFetchRequest<Classcool>(entityName: "Classcool")
    }
    
    //@NSManaged public var isarchived: Bool
    @NSManaged public var name: String
    @NSManaged public var tolerance: Int64
    @NSManaged public var assignmentnumber: Int64
    @NSManaged public var color: String
    @NSManaged public var originalname: String
    @NSManaged public var isTrash: Bool
    @NSManaged public var gradingscheme: String
    @NSManaged public var googleclassroomid: String
}
