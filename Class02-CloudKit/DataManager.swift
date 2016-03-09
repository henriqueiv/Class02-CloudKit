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
        CKContainer.defaultContainer().privateCloudDatabase.performQuery(query, inZoneWithID: nil) { (pokemonRecords:[CKRecord]?, error:NSError?) -> Void in
            if error == nil {
                if pokemonRecords?.count > 0 {
                    var pokemons = [Pokemon]()
                    for pokemonRecord in pokemonRecords! {
                        pokemons += [Pokemon(record: pokemonRecord)]
                    }
                    block(pokemons, nil)
                }
            } else {
                print(error)
            }
        }
    }
    
    // MARK: Save methods
    func saveLocalDataRemotely(pokemons:[Pokemon]) {
        
    }
    
}