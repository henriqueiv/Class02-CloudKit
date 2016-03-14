//
//  ModelsTests.swift
//  Class02-CloudKit
//
//  Created by Henrique Valcanaia on 3/14/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import XCTest
@testable import Class02_CloudKit

class ModelsTests: XCTestCase {
    
    private var pokemon:Pokemon! = nil
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        DataManager.sharedInstance.loadLocalDataWithBlock { (pokemons:[Pokemon]?, error:ErrorType?) in
            if error == nil {
                self.pokemon = pokemons?.first!
            } else {
                
            }
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPokemon() {
        let p1 = pokemon
        let p2 = Pokemon(number: p1.number, name: "", icon: "", image: "", level: 1, type1: "", type2: nil, status: nil, skills: nil, isFavorite: true)
        let p3 = Pokemon(record: p1.asCKRecord())
        XCTAssertTrue(p1.number == p2.number && p2.number == p3.number)
    }
    
    func testSkill() {
        let s1 = Skill(name: pokemon.skills!.first!.name, type: "", damageCategory: "", power: 1, accuracy: 2, powerPoint: 3)
        let s2 = Skill(record: s1.asCKRecord())
        
        XCTAssertTrue(s1.name == s2.name)
    }
    
    func testStatus() {
        let s1 = Status(health: 1, attack: 2, defense: 3, spAttack: 4, spDefense: 5, speed: 6)
        let s2 = Status(record: s1.asCKRecord())
        
        XCTAssertTrue(s1.health == s2.health)
    }
    
}
