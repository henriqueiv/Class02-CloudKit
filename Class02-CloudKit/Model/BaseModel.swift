//
//  BaseRecord.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/8/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import CloudKit

//protocol HVRecord {
//    var className:String { get }
//}
//
//typealias HVCompletionBlock = ((CKRecord?, NSError?) -> Void)
//
//extension HVRecord {
//    
//    func saveRecordWithBlock(block:HVCompletionBlock) {
//        let record = CKRecord(recordType: className)
//        let mirror = Mirror(reflecting: self)
//        var properties = [String]()
//        for child in mirror.children{
//            guard let property = child.label else{
//                assertionFailure("Error erroso")
//                break;
//            }
//            
//            if property == "super" { continue }
//            
////            if property.conformsTo(CKRecordValue){
////                record[property] = self.property
////            }
//        }
//        
//        CKContainer.defaultContainer().publicCloudDatabase.saveRecord(record, completionHandler: block)
//    }
//    
//}

class BaseModel {
    
    class func query(predicate:NSPredicate = NSPredicate(value: true)) -> CKQuery {
        let query = CKQuery(recordType: String(self), predicate: predicate)
        return query
    }
    
}
