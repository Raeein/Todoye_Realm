//
//  Category.swift
//  Todoey
//
//  Created by Raeein Bagheri on 2022-01-30.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
    
}

