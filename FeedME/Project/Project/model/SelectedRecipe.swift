//
//  SelectedRecipe.swift
//  Project
//
//  Created by Deepak Chandwani on 12/8/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import Foundation
class SelectedRecipe{
    static var recipe: Recipes?
    init(r: Recipes) {
        SelectedRecipe.recipe = r
    }
}
