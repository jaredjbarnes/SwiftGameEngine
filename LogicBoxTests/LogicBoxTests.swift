//
//  LogicBoxTests.swift
//  LogicBoxTests
//
//  Created by Jared Barnes on 9/21/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import XCTest
@testable import LogicBox

class LogicBoxTests: XCTestCase {
    var world: World?
    
    override func setUp() {
        super.setUp()
        
        world = World(with: CGRect())
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testActivated() {
        let system = TestSystem()
        world?.add(system: system)
    
        XCTAssert(system.invokedActivatedCount == 1)
    }
    
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
    
    func testDeactivated() {
        let system = TestSystem()
        world?.add(system: system)
        world?.remove(system: system)
        
        XCTAssert(system.invokedActivatedCount == 1)
        XCTAssert(system.invokedDeactivatedCount == 1)
    }
    
    func testEntityLifeCycle() {
        let system = TestSystem()
        let entity = Entity(withType: "test-entity")
        let position = Position()
        
        world?.add(system: system)
        world?.add(entity: entity)

        entity.add(component: position)
        entity.remove(component: position)
        
        world?.remove(entity: entity)
        world?.remove(system: system)
        
        XCTAssert(system.invokedActivatedCount == 1)
        XCTAssert(system.invokedDeactivatedCount == 1)
        XCTAssert(system.invokedAddedEntityCount == 1)
        XCTAssert(system.invokedRemovedEntityCount == 1)
        XCTAssert(system.invokedAddedComponentCount == 1)
        XCTAssert(system.invokedRemovedComponentCount == 1)
    }
    
    func testSystemLifeCycleAfterRemoval(){
        let system = TestSystem()
        let persistentSystem = TestSystem()
        let entity = Entity(withType: "test-entity")
        let position = Position()
        
        world?.add(system: persistentSystem)
        world?.add(system: system)
        world?.add(entity: entity)
        
        entity.add(component: position)
        entity.remove(component: position)
        
        world?.remove(entity: entity)
        world?.remove(system: system)
        
        world?.add(entity: entity)
        
        entity.add(component: position)
        entity.remove(component: position)
        
        world?.remove(entity: entity)
        
        XCTAssert(system.invokedActivatedCount == 1)
        XCTAssert(system.invokedDeactivatedCount == 1)
        XCTAssert(system.invokedAddedEntityCount == 1)
        XCTAssert(system.invokedRemovedEntityCount == 1)
        XCTAssert(system.invokedAddedComponentCount == 1)
        XCTAssert(system.invokedRemovedComponentCount == 1)
        
        XCTAssert(persistentSystem.invokedActivatedCount == 1)
        XCTAssert(persistentSystem.invokedDeactivatedCount == 0)
        XCTAssert(persistentSystem.invokedAddedEntityCount == 2)
        XCTAssert(persistentSystem.invokedRemovedEntityCount == 2)
        XCTAssert(persistentSystem.invokedAddedComponentCount == 2)
        XCTAssert(persistentSystem.invokedRemovedComponentCount == 2)
    }
    
}
