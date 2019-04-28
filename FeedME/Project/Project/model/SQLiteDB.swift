//
//  SQLiteDB.swift
//  Project
//
//  Created by Deepak Chandwani on 12/11/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import Foundation
class SQLiteDB{
    static var fileURL: URL?
    init(ur: URL)
    {
        SQLiteDB.fileURL = ur
    }
}
