//
//  EntityTests.swift
//  LogicBoxTests
//
//  Created by Jared Barnes on 11/15/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import XCTest
@testable import LogicBox

class EntityTests: XCTestCase {
    
    func testHasComponents(){
        let entity = Entity(withType: "test")
        let size = Size()
        let position = Position()
        
        entity.add(component: position)
        entity.add(component: size)
        
        XCTAssert(entity.hasComponents(withTypes: ["position", "size"]))
        
        entity.remove(component: position)
        
        XCTAssert(!entity.hasComponents(withTypes: ["position", "size"]))
    }
    
    func testAddAndGetComnponent(){
        let entity = Entity(withType: "test")
        entity.add(component: Position(withX: 0, andY: 1))
        
        let position = entity.getComponent(withType: "position") as? Position
        
        XCTAssert(position?.x == 0)
        XCTAssert(position?.y == 1)
    }
    
    func testAddAndRemoveComnponent(){
        let entity = Entity(withType: "test")
        entity.add(component: Position(withX: 0, andY: 1))
        
        let position = entity.getComponent(withType: "position") as? Position
        
        XCTAssert(position?.x == 0)
        XCTAssert(position?.y == 1)
        
        entity.remove(component: position!)
        
        XCTAssert(entity.getComponents().count == 0)
        
    }
}
