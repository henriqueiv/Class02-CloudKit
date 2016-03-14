//
//  Class02_CloudKitTests.swift
//  Class02-CloudKitTests
//
//  Created by Henrique Valcanaia on 3/11/16.
//  Copyright © 2016 Henrique Valcanaia. All rights reserved.
//

import XCTest
@testable import Class02_CloudKit

class Class02_CloudKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPokemonCount() {
        let expectation = expectationWithDescription("Ready")
        DataManager.sharedInstance.loadLocalDataWithBlock { (pokemons:[Pokemon]?, error:ErrorType?) in
            expectation.fulfill()
            if error == nil {
                XCTAssertTrue(pokemons!.count == 6)
            } else {
                XCTAssertNotNil(error)
            }
        }
        
        waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    //    func testPokemonCell() {
    //        let cell = PokemonCell()
    //        let pokemon = Pokemon(number: 1, name: "", icon: "", image: "", level: 1, type1: "", type2: nil, status: nil, skills: nil, isFavorite: true)
    //        cell.configureCellWithPokemon(pokemon)
    //
    //        let validURL = (cell.pokemonImage.imageURL == NSURL(string: pokemon.image))
    //
    //        XCTAssertTrue(validURL && cell.pokemonLabel.text == pokemon.name)
    //    }
    
}
