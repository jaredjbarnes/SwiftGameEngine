//
//  BroadPhaseCollisionSystem.swift
//  LogicBox
//
//  Created by Jared Barnes on 11/12/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import Foundation
import UIKit

public class BroadPhaseCollisionSystem : System {
    private var entities: Dictionary<String, Entity> = Dictionary()
    private var entitiesLastRegion: Dictionary<String, Entity> = Dictionary()
    private var world: World?
    private var currentTimestamp: Double = 0
    private var grid = Array<Array<Array<Entity>>>()
    private var gridWidth: Int = 0
    private var gridHeight: Int = 0
    private let dependencies: Array<String> = ["position", "size", "collidable"]
    
    public var name: String
    public var cellSize: Int = 200
    
    private func createGrid(){
        gridWidth = Int(world!.size.width / CGFloat(cellSize))
        gridHeight = Int(world!.size.height / CGFloat(cellSize))
        
        grid = Array<Array<Array<Entity>>>()
        
        var x = 0
        while (x < gridWidth){
            var y = 0
            var row = Array<Array<Entity>>()
            
            grid.append(row)
            while (y < gridHeight){
                let column = Array<Entity>()
                row.append(column)
                y+=1
            }
            x+=1
        }
    }
    
    init(with cellSize: Int){
        self.cellSize = cellSize
        self.name = "Broad Phase Collision System"
    }
    
    public func activated(on world: World) {
        self.world = world
        
        createGrid()
        
        for entry in world.getEntities() {
            added(entity: entry.value)
        }
    }
    
    public func added(entity: Entity) {
        
    }
    
    public func added(component: Component, to entity: Entity) {
        
    }
    
    public func deactivated(on world: World) {
        
    }
    
    public func removed(entity: Entity) {
        
    }
    
    public func removed(component: Component, from entity: Entity) {
        
    }
    
    public func update(withTime currentTime: Double) {
        
    }
}
