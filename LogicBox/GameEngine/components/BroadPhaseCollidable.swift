//
//  Position.swift
//  LogicBox
//
//  Created by Jared Barnes on 11/5/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import Foundation

public class BroadPhaseCollision {
    public var entityId: String
    public var startTimestamp: Double = 0
    public var endTimestamp: Double = 0
    public var timestamp: Double = 0
    
    init (withEntityId: String){
        entityId = withEntityId
    }
}

public class BroadPhaseCollidable: Component {
    public var activeCollisions: Array<BroadPhaseCollision> = Array()
    
    override init(){
        super.init()
        self.type = "broad-phase-collidable"
    }

}

