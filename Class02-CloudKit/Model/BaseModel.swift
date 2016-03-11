//
//  BaseRecord.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/8/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import CloudKit

typealias HVCKRecordsArrayBlock = ([CKRecord]?, NSError?) -> Void
typealias HVCKRecordBlock       = (CKRecord?, NSError?) -> Void
typealias HVCKRecordZoneBlock   = (CKRecordZoneID?, NSError?) -> Void

class BaseModel {
    
    var recordID:CKRecordID?
    
    class func getRecordWithReference(reference:CKReference, withCompletionBlock block:HVCKRecordsArrayBlock) {
        let predicate = NSPredicate(format: "recordID == %@", reference)
        self.performQueryWithPredicate(predicate, withCompletionBlock: block)
    }
    
    class func getRecordsWithReferences(references:[CKReference], withCompletionBlock block:HVCKRecordsArrayBlock) {
        let predicate = NSPredicate(format: "recordID in %@", references)
        self.performQueryWithPredicate(predicate, withCompletionBlock: block)
    }
    
    class func performQueryWithPredicate(predicate:NSPredicate, withCompletionBlock block:HVCKRecordsArrayBlock) {
        let query = self.query(predicate)
        Database.Public.performQuery(query, inZoneWithID: nil, completionHandler: block)
    }
    
    class func query(predicate:NSPredicate = NSPredicate(value: true)) -> CKQuery {
        let recordType = String(self)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        return query
    }
    
    class func deleteAllWithCompletionblock(block:HVCKRecordZoneBlock) {
        Database.Public.deleteRecordZoneWithID(CKRecordZone.defaultRecordZone().zoneID, completionHandler: block)
    }
    
    func saveWithCompletionBlock(block:HVCKRecordBlock) {
        let record = asCKRecord()
        Database.Public.saveRecord(record, completionHandler: block)
    }
    
    func asCKRecord() -> CKRecord {
        let recordType = String(self.dynamicType)
        if recordID == nil {
            return CKRecord(recordType: recordType)
        } else {
            return CKRecord(recordType: recordType, recordID: recordID!)
        }
    }
    
    func deleteWithCompletionBlock(completionBlock:((CKRecordID?, NSError?) -> Void)) {
        let record = self.asCKRecord()
        Database.Public.deleteRecordWithID(record.recordID, completionHandler: completionBlock)
    }
    
    func update(progressBlock:((CKRecord, Double)->Void)? = nil, completionBlock:((CKRecord?, NSError?) -> Void)? = nil) {
        let record = self.asCKRecord()
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .ChangedKeys
        modifyOperation.perRecordProgressBlock = progressBlock
        modifyOperation.perRecordCompletionBlock = completionBlock
        Database.Public.addOperation(modifyOperation)
    }
    
}