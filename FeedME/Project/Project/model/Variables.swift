//
//  Variables.swift
//  Project
//
//  Created by Deepak Chandwani on 12/8/18.
//  Copyright © 2018 Deepak Chandwani. All rights reserved.
//

import Foundation
class Variables{
    static var bucketName: String?
    static var s3Url: URL!
    
    init(bucketName: String, s3Url: URL) {
        Variables.bucketName = "/mybucket10771/"
        Variables.s3Url = s3Url
    }
}
