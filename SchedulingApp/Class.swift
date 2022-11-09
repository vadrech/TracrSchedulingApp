//
//  Class.swift
//  SchedulingApp
//
//  Created by Tejas Krishnan on 7/1/20.
//  Copyright © 2020 Tejas Krishnan. All rights reserved.
//

import UIKit

class Class: Identifiable {
    
    var name: String = ""
    var assignmentnumber: Int = 0
    var tolerance: Int = 0
    var attentionspan: Int = 0
    
    init(name: String = "", assignmentnumber: Int=0, tolerance: Int=5, attentionspan: Int=0)
    {
        self.name = name
        self.assignmentnumber = assignmentnumber
        self.tolerance = tolerance
        self.attentionspan = attentionspan
    }
    
    
}



