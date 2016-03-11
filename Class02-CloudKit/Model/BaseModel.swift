//
//  BaseRecord.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/8/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import CloudKit

protocol BaseModelProtocol {
    func asCKRecord() -> CKRecord
}

typealias HVCKRecordsArrayBlock = ([CKRecord]?, NSError?) -> Void
typealias HVCKRecordBlock       = (CKRecord?, NSError?) -> Void
typealias HVCKRecordZoneBlock   = (CKRecordZoneID?, NSError?) -> Void

class BaseModel {
    
    var recordID:CKRecordID!
    
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
        return CKRecord(recordType: recordType, recordID: recordID)
    }
    
    func update() {
        let pokemonRecord = self.asCKRecord()
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: [pokemonRecord], recordIDsToDelete: nil)
        modifyOperation.savePolicy = .ChangedKeys
        Database.Public.addOperation(modifyOperation)
    }
    
}