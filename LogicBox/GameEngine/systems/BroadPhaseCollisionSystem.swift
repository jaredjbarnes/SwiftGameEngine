//
//  BroadPhaseCollisionSystem.swift
//  LogicBox
//
//  Created by Jared Barnes on 11/12/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import Foundation
import UIKit

class CellPosition {
    public var columnIndex: Int = 0
    public var rowIndex: Int = 0
    
    init(withColumn column: Int, andRow row: Int ){
        self.rowIndex = row
        self.columnIndex = column
    }
}

public class BroadPhaseCollisionSystem : System {
    private var entities: Dictionary<String, Entity> = Dictionary()
    private var cellPositionsOfEntitiesById: Dictionary<String, Array<CellPosition>> = Dictionary()
    private var world: World?
    private var currentTime: Double = 0
    private var grid: Dictionary<Int, Dictionary<Int, Array<Entity>>> = Dictionary()
    private let dependencies: Array<String> = ["position", "size", "collidable"]
    
    public var name: String
    public var cellSize: Int = 200
    
    private func getCellPositions(for entity: Entity) -> Array<CellPosition>{
        let position = entity.getComponent(withType: "position") as! Position
        let size = entity.getComponent(withType: "size") as! Size
        
        let top = position.y
        let left = position.x
        let right = left + size.width
        let bottom = top + size.height
        
        let topCell = Int(top / cellSize)
        let bottomCell = Int(bottom / cellSize)
        let leftCell = Int(left / cellSize)
        let rightCell = Int(right / cellSize)
        
        var row = topCell
        var column = leftCell
        
        var cellPositions = Array<CellPosition>()
        
        while row <= bottomCell {
            while column <= rightCell {
                cellPositions.append(CellPosition(withColumn: column, andRow: row))
                column += 1
            }
            column = leftCell
            row += 1
        }
        
        return cellPositions
    }
    
    private func getGridCell(for cellPosition: CellPosition) -> Array<Entity> {
        var column = grid[cellPosition.columnIndex]
        
        if column == nil {
            grid[cellPosition.columnIndex] = Dictionary<Int, Array<Entity>>()
            column = grid[cellPosition.columnIndex]
        }
        
        var cell = column?[cellPosition.rowIndex]
        
        if cell == nil {
            column?[cellPosition.rowIndex] = Array<Entity>()
            cell = column?[cellPosition.rowIndex]
        }
        
        return cell!
    }
    
    init(with cellSize: Int){
        self.cellSize = cellSize
        self.name = "Broad Phase Collision System"
    }
    
    public func activated(on world: World) {
        self.world = world
        
        for entry in world.getEntities() {
            added(entity: entry.value)
        }
    }
    
    public func added(entity: Entity) {
        if entity.hasComponents(withTypes: dependencies) {
            entities[entity.id] = entity
            
            let cellPositions = getCellPositions(for: entity)
            
            cellPositionsOfEntitiesById[entity.id] = cellPositions
            
            for cellPosition in cellPositions {
                var cell = getGridCell(for: cellPosition)
                cell.append(entity)
            }
        }
    }
    
    public func added(component: Component, to entity: Entity) {
        added(entity: entity)
    }
    
    public func deactivated(on world: World) {
       self.world = world
       entities = Dictionary<String, Entity>()
       cellPositionsOfEntitiesById = Dictionary()
       currentTime = 0
       grid = Dictionary()
    }
    
    public func removed(entity: Entity) {
        if entities[entity.id] != nil {
            entities.removeValue(forKey: entity.id)
        }
    }
    
    public func removed(component: Component, from entity: Entity) {
        if dependencies.contains(component.type) {
            removed(entity: entity)
        }
    }
    
    public func update(with currentTime: Double) {
        self.currentTime = currentTime
        
        
    }
}
