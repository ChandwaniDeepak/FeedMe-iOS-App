//
//  Users.swift
//  MySampleApp
//
//
// Copyright 2018 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.21
//

import Foundation
import UIKit
import AWSDynamoDB

@objcMembers
class Users: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _deviceId: String?
    var _firstName: String?
    var _imageKey: String?
    var _lastName: String?
    var _password: String?
    
    class func dynamoDBTableName() -> String {
        
        return "project-mobilehub-2093181805-Users"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_deviceId" : "deviceId",
            "_firstName" : "firstName",
            "_imageKey" : "imageKey",
            "_lastName" : "lastName",
            "_password" : "password",
        ]
    }
}
