//
//  Chore.swift
//  IntelliKitchen
//
//  Created by sawsa on 6/6/20.
//  Copyright © 2020 Emily Xu. All rights reserved.
//

import Foundation
import UIKit

class Chore {
    var task: String
    var lastDone: String
    var timePeriod: String
    
    init(task: String, lastDone: String, timePeriod: String) {
        self.task = task
        self.lastDone = lastDone
        self.timePeriod = timePeriod
    }
}
