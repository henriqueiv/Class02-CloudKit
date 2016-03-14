//
//  DataManager.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/8/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import CloudKit
import Foundation
import SwiftyJSON
import SVProgressHUD

public enum DataManagerError: ErrorType {
    enum LoadLocalData: ErrorType {
        case Error(String)
        case FileNotFound
        case ParseFileError
    }
    
    case NoPokemons
}

struct Database {
    static let Public = CKContainer.defaultContainer().publicCloudDatabase
    static let Private = CKContainer.defaultContainer().privateCloudDatabase
}

typealias HVDataResultBlock = (([Pokemon]?, ErrorType?) -> Void)

class DataManager {
    
    static let sharedInstance = DataManager()
    
    // MARK: Load methods
    func loadLocalDataWithBlock(block:HVDataResultBlock) {
        do {
            guard let path = NSBundle.mainBundle().pathForResource("pokemons", ofType: "json"), let jsonData = NSData(contentsOfFile: path) else {
                block(nil, DataManagerError.LoadLocalData.FileNotFound)
                return
            }
            
            let jsonObjectArray = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers) as! [[String:AnyObject]]
            
            var pokemons = [Pokemon]()
            for jsonObject in jsonObjectArray {
                let pokemon = Pokemon(json: JSON(jsonObject))
                pokemons += [pokemon]
            }
            
            block(pokemons, nil)
        } catch let error {
            print(error)
            block(nil, DataManagerError.LoadLocalData.FileNotFound)
        }
    }
    
    func loadRemoteDataWithBlock(block:HVDataResultBlock) {
        Pokemon.performQueryWithPredicate(NSPredicate(value: true)) { (pokemonRecords:[CKRecord]?, error:NSError?) in
            if error == nil {
                if pokemonRecords?.count > 0 {
                    var pokemons = [Pokemon]()
                    for pokemonRecord in pokemonRecords! {
                        pokemons += [Pokemon(record: pokemonRecord)]
                    }
                    block(pokemons, nil)
                } else {
                    block(nil, DataManagerError.NoPokemons)
                }
            } else {
                block(nil, error)
            }
        }
    }
    
    // MARK: Save methods
    func sendLocalToRemote(progressBlock:((CKRecord?, Float) -> Void), completionBlock: ((NSError?) -> Void)) {
        self.loadLocalDataWithBlock { (pokemons:[Pokemon]?, error:ErrorType?) in
            if pokemons != nil {
                var successCount = 0
                let records = pokemons!.flatMap({ self.generateRecordsWithPokemon($0) })
                let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
                operation.perRecordProgressBlock = { (record, progress) in
                    let total = Float(records.count)
                    
                    let fullProgress:Float = (Float(progress)/total)+(total/Float(successCount))
                    progressBlock(record, fullProgress)
                }
                
                operation.perRecordCompletionBlock = { (record: CKRecord?, error: NSError?) in
                    if error == nil {
                        successCount += 1
                        if records.count == successCount {
                            completionBlock(nil)
                        }
                    } else {
                        completionBlock(error)
                    }
                }
                Database.Public.addOperation(operation)
            }
        }
    }
    
    private func generateRecordsWithPokemon(pokemon:Pokemon) -> [CKRecord] {
        var records = [CKRecord]()
        
        records += [pokemon.asCKRecord()]
        if pokemon.status != nil {
            records += [pokemon.status!.asCKRecord()]
        }
        
        if pokemon.skills?.count > 0 {
            records += pokemon.skills!.map { $0.asCKRecord() }
        }
        
        return records
    }
}

