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

typealias HVDataResultBlock = (([Pokemon]?, ErrorType?) -> Void)

class DataManager {
    
    static let sharedInstance = DataManager()
    
    var higherHealth = 0
    var higherAttack = 0
    var higherDefense = 0
    
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
                checkHigherStatsWithPokemon(pokemon)
            }
            
            block(pokemons, nil)
        } catch let error {
            block(nil, DataManagerError.LoadLocalData.FileNotFound)
        }
    }
    
    private func checkHigherStatsWithPokemon(pokemon:Pokemon) {
        higherHealth = max(higherHealth, pokemon.status.health)
        higherAttack = max(higherAttack, pokemon.status.attack)
        higherDefense = max(higherDefense, pokemon.status.defense)
    }
    
    func loadRemoteDataWithBlock(block:HVDataResultBlock) {
        let query = Pokemon.query()
        CKContainer.defaultContainer().publicCloudDatabase.performQuery(query, inZoneWithID: nil) { (pokemonRecords:[CKRecord]?, error:NSError?) -> Void in
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
    func saveLocalDataRemotely(pokemons:[Pokemon]) {
        
    }
    
    func sendLocalToRemoteWithBlock(block:(NSError? -> Void)) {
        self.loadLocalDataWithBlock { (pokemons:[Pokemon]?, error:ErrorType?) in
            if pokemons != nil {
                var successCount = 0
                var previousOperation:NSOperation!
                let operationQueue = NSOperationQueue()
                for pokemon in pokemons! {
                    
//                    let skillsOperations = self.createSkillsOperationWithPokemon(pokemon)
                    let statusOperation = self.createStatusOperationWithPokemon(pokemon)
//                    skillsOperations.last!.addDependency(statusOperation)
                    
                    let operation = NSBlockOperation()
                    operation.addExecutionBlock({
                        let pokemonRecord = pokemon.asCKRecord()
                        CKContainer.defaultContainer().publicCloudDatabase.saveRecord(pokemonRecord, completionHandler: { (record:CKRecord?, error:NSError?) in
                            if error == nil {
//                                print("Foi: \(record)")
                                
                                successCount += 1
                                if successCount == pokemons!.count {
                                    block(nil)
                                }
                            } else {
                                operationQueue.cancelAllOperations()
                                block(error)
                            }
                        })
                    })
                    
                    operation.addDependency(statusOperation)
                    
                    if operationQueue.operationCount > 0 {
                        operation.addDependency(previousOperation)
                    }
                    previousOperation = operation
                    operationQueue.addOperation(operation)
                }
            }
        }
    }
    
    private func createSkillsOperationWithPokemon(pokemon:Pokemon) -> [NSBlockOperation] {
        var skillsOperations = [NSBlockOperation]()
        var successCount = 0
        var previousOperation:NSBlockOperation!
        for skill in pokemon.skills {
            
            let operation = NSBlockOperation()
            operation.addExecutionBlock{
                let skillRecord = skill.asCKRecord()
                CKContainer.defaultContainer().publicCloudDatabase.saveRecord(skillRecord, completionHandler: { (record:CKRecord?, error:NSError?) in
                    if error == nil {
//                        print("foi")
                        
                        successCount += 1
                        if successCount == pokemon.skills.count {
                            print("terminou")
                        }
                    } else {
                        print(error)
                    }
                })
                
                if skillsOperations.count > 0 {
                    operation.addDependency(previousOperation)
                }
                previousOperation = operation
            }
            
            skillsOperations += [operation]
        }
        
        return skillsOperations
    }
    
    private func createStatusOperationWithPokemon(pokemon:Pokemon) -> NSBlockOperation {
        let operation = NSBlockOperation()
        operation.addExecutionBlock {
            let statusRecord = pokemon.status.asCKRecord()
            CKContainer.defaultContainer().publicCloudDatabase.saveRecord(statusRecord, completionHandler: { (record:CKRecord?, error:NSError?) in
                if error == nil {
                    print("foi")
                } else {
                    print(error)
                }
            })
            
        }
        
        return operation
    }
    
}