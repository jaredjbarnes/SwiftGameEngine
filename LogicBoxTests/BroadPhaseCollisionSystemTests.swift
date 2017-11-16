//
//  BroadPhaseCollisionSystem.swift
//  LogicBoxTests
//
//  Created by Jared Barnes on 11/16/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import XCTest
@testable import LogicBox

class BroadPhaseCollisionSystemTests: XCTestCase {
    
    func createEntity() -> Entity {
        let entity = Entity(withType: "rect")
        let position = Position()
        let size = Size()
        let broadPhaseCollidable = BroadPhaseCollidable()
        
        size.width = 100
        size.height = 100
        
        entity.add(component: position)
        entity.add(component: size)
        entity.add(component: broadPhaseCollidable)
        
        return entity
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let broadPhaseCollisionSystem = BroadPhaseCollisionSystem(with: 200)
        
        let entityA = createEntity()
        let entityB = createEntity()
        
        broadPhaseCollisionSystem.added(entity: entityA)
        broadPhaseCollisionSystem.added(entity: entityB)
        
        broadPhaseCollisionSystem.update(with: 16)
        
        let position = entityA.getComponent(withType: "position") as? Position
        
        position?.isDirty = true
        position?.y = 200
        
        broadPhaseCollisionSystem.update(with: 32)
        
        position?.isDirty = true
        position?.y = 0
        
        broadPhaseCollisionSystem.update(with: 48)
    }
    
}
