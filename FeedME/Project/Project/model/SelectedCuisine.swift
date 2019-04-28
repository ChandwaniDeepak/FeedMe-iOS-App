//
//  SelectedCuisine.swift
//  Project
//
//  Created by Deepak Chandwani on 12/8/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import Foundation
class SelectedCuisine{
    static var cuisine: Cuisine?
    init(c: Cuisine) {
        SelectedCuisine.cuisine = c
    }
}
