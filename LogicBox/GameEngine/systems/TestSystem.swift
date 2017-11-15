//
//  TestSystem.swift
//  LogicBox
//
//  Created by Jared Barnes on 11/2/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import Foundation

public class TestSystem : System {
    public var invokedAddedEntityCount: Int = 0
    public var invokedRemovedEntityCount: Int = 0
    public var invokedAddedComponentCount: Int = 0
    public var invokedRemovedComponentCount: Int = 0
    public var invokedActivatedCount: Int = 0
    public var invokedDeactivatedCount: Int = 0
    public var invokedUpdatedCount: Int = 0
    public var name: String = "Test System"
    public var world: World?
    
    public init () {
        
    }
    
    public func activated(on world: World) {
        self.world = world
        invokedActivatedCount += 1
    }
    
    public func added(entity: Entity) {
        invokedAddedEntityCount += 1
    }
    
    public func added(component: Component, to entity: Entity) {
        invokedAddedComponentCount += 1
    }
    
    public func deactivated(on world: World) {
        invokedDeactivatedCount += 1
    }
    
    public func removed(entity: Entity) {
        invokedRemovedEntityCount += 1
    }
    
    public func removed(component: Component, from entity: Entity) {
        invokedRemovedComponentCount += 1
    }
    
    public func update(with time: Double) {
        invokedUpdatedCount += 1
    }
    
}
