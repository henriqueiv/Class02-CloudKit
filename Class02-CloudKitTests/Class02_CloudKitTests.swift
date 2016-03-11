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
    
    func testLocalDataLoad() {
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
    
}
