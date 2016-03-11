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

public enum DataManagerError: ErrorType {
    enum LoadLocalData: ErrorType {
        case Error(String)
        case FileNotFound
        case ParseFileError
    }
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
                    print("Nenhum Pokemon no euNuvem!")
                }
            } else {
                print(error)
            }
        }
    }
    
    // MARK: Save methods
    func sendLocalToRemoteWithBlock(block:(NSError? -> Void)) {
        self.loadLocalDataWithBlock { (pokemons:[Pokemon]?, error:ErrorType?) in
            if pokemons != nil {
                //                let queue = NSOperationQueue()
                //                let insertOperation = NSBlockOperation()
                //                insertOperation.addExecutionBlock{
                //                    var pokemonsRecords = [CKRecord]()
                //                    for pokemon in pokemons! {
                //                        pokemonsRecords += [pokemon.asCKRecord()]
                //                    }
                //                    let recordsOperation = CKModifyRecordsOperation(recordsToSave: pokemonsRecords, recordIDsToDelete: nil)
                //                    recordsOperation.savePolicy = .AllKeys
                //                    recordsOperation.perRecordProgressBlock = { record, progress in
                //                        print(progress)
                //                    }
                //                    recordsOperation.perRecordCompletionBlock = { record, error in
                //                        if error == nil {
                //                            print("salvou")
                //                        } else {
                //                            queue.cancelAllOperations()
                //                            block(error)
                //                        }
                //                    }
                //                    recordsOperation.completionBlock = {
                //                        block(nil)
                //                    }
                //                }
                //                queue.addOperation(insertOperation)
                //
                //            }
                
                var successCount = 0
                let retrieveQueue = NSOperationQueue()
                var operations = [NSBlockOperation]()
                for pokemon in pokemons! {
                    let operation = NSBlockOperation()
                    operation.addExecutionBlock {
                        pokemon.saveWithCompletionBlock({ (record:CKRecord?, error:NSError?) in
                            if error == nil {
                                successCount += 1
                                if successCount == pokemons!.count{
                                    block(nil)
                                }
                            } else {
                                retrieveQueue.cancelAllOperations()
                                block(error)
                            }
                            
                        })
                    }
                    
                    if operations.count > 0 {
                        operations.last!.addDependency(operation)
                    }
                    operations += [operation]
                }
                retrieveQueue.addOperations(operations, waitUntilFinished: true)
            }
        }
    }
}

