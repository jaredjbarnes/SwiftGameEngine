//
//  BroadPhaseCollisionSystem.swift
//  LogicBox
//
//  Created by Jared Barnes on 11/12/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import Foundation
import UIKit

public class CellPosition {
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
    private var dirtyCellPositions: Array<CellPosition> = Array()
    private let dependencies: Array<String> = ["position", "size", "broad-phase-collidable"]
    
    public var name: String
    public var cellSize: Int = 200
    
    
    private func add(entity: Entity, toCellPosition cellPosition: CellPosition){
        if grid[cellPosition.columnIndex] == nil {
            grid[cellPosition.columnIndex] = Dictionary<Int, Array<Entity>>()
        }

        if grid[cellPosition.columnIndex]?[cellPosition.rowIndex] == nil {
            grid[cellPosition.columnIndex]?[cellPosition.rowIndex] = Array<Entity>()
        }
        
        grid[cellPosition.columnIndex]?[cellPosition.rowIndex]?.append(entity)
    }
    
    private func add(cellPositions: Array<CellPosition>, to dirtyCellPositions: Array<CellPosition>){
        let filteredCellPositions = cellPositions.filter { (cellPosition) -> Bool in
            return !dirtyCellPositions.contains(where: { (dirtyCellPosition) -> Bool in
                return cellPosition.columnIndex == dirtyCellPosition.columnIndex &&
                    cellPosition.rowIndex == dirtyCellPosition.rowIndex
            })
        }
        
        self.dirtyCellPositions = dirtyCellPositions + filteredCellPositions
    }
    
    private func cleanCollisions(onEntity entity: Entity, forCellPosition: CellPosition){
        let collidable = entity.getComponent(withType: "broad-phase-collidable") as? BroadPhaseCollidable
        
        if (collidable != nil){
            collidable?.activeCollisions = (collidable?.activeCollisions.filter({ (collision) -> Bool in
                return collision.timestamp == currentTime ||
                    (collision.cellPosition?.columnIndex != forCellPosition.columnIndex &&
                    collision.cellPosition?.rowIndex != forCellPosition.rowIndex)
            }))!
        }
    }
    
    private func does(entity: Entity, intersectWith otherEntity: Entity) -> Bool {
        let positionA = entity.getComponent(withType: "position") as! Position
        let positionB = otherEntity.getComponent(withType: "position") as! Position
        let sizeA = entity.getComponent(withType: "size") as! Size
        let sizeB = otherEntity.getComponent(withType: "size") as! Size
        
        let top = max(positionA.y, positionB.y)
        let bottom = min(positionA.y + sizeA.height, positionB.y + sizeB.height)
        let left = max(positionA.x, positionB.x)
        let right = min(positionA.x + sizeA.width, positionB.x + sizeB.width)
        
        return top < bottom && left < right
        
    }
    
    private func findDirtyCells(){
        let dirtyEntries = entities.filter { (entry) -> Bool in
            let position = entry.value.getComponent(withType: "position") as! Position
            let size = entry.value.getComponent(withType: "size") as! Size
            
            return position.isDirty || size.isDirty
        }
        
        for dirtyEntry in dirtyEntries {
            let lastCellPositions = cellPositionsOfEntitiesById[dirtyEntry.value.id]
            let newCellPositions = getCellPositions(for: dirtyEntry.value)
            
            if (lastCellPositions != nil){
                add(cellPositions: lastCellPositions!, to: dirtyCellPositions)
            }
            
            add(cellPositions: newCellPositions, to: dirtyCellPositions)
            
            cellPositionsOfEntitiesById[dirtyEntry.value.id] = newCellPositions
        }
    }
    
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
    
    private func getCollision(of entity: Entity, onEntity otherEntity: Entity) -> BroadPhaseCollision? {
        let collidable = otherEntity.getComponent(withType: "broad-phase-collidable") as? BroadPhaseCollidable
        
        return collidable?.activeCollisions.filter( { (collision) -> Bool in
            return collision.entityId == entity.id
        }).first
    }
    
    private func remove(entity: Entity, fromCellPositions cellPositions: Array<CellPosition>){
        add(cellPositions: cellPositions, to: dirtyCellPositions)
        
        for cellPosition in cellPositions {
            var cell = grid[cellPosition.columnIndex]?[cellPosition.rowIndex]
            
            if (cell != nil){
                let index = cell!.index(where: { $0 === entity })
                
                if index != nil {
                    cell!.remove(at: index!)
                }
            }
        }
    }
    
    private func updateGridCells(at cellPositions: Array<CellPosition>){
        for cellPosition in cellPositions {
            let cell = grid[cellPosition.columnIndex]?[cellPosition.rowIndex]
            
            if (cell != nil){
                for entry in cell!.enumerated() {
                    
                    for otherEntity in cell![..<entry.offset]{
                        if does(entity: entry.element, intersectWith: otherEntity) {
                            
                            var collision = getCollision(of: otherEntity, onEntity: entry.element)
                            var otherCollision = getCollision(of: entry.element, onEntity: otherEntity)
                            
                            if collision == nil {
                                let collidable = otherEntity.getComponent(withType: "broad-phase-collidable") as? BroadPhaseCollidable
                                collision = BroadPhaseCollision(withEntityId: entry.element.id)
                                collision?.startTimestamp = currentTime
                                collision?.cellPosition = cellPosition
                                
                                collidable?.activeCollisions.append(collision!)
                            }
                            
                            if otherCollision == nil {
                                let collidable = entry.element.getComponent(withType: "broad-phase-collidable") as? BroadPhaseCollidable
                                otherCollision = BroadPhaseCollision(withEntityId: otherEntity.id)
                                otherCollision?.startTimestamp = currentTime
                                otherCollision?.cellPosition = cellPosition
                                
                                collidable?.activeCollisions.append(otherCollision!)
                            }
                            
                            collision?.timestamp = currentTime
                            otherCollision?.timestamp = currentTime
                            
                        }
                    }
                    
                    cleanCollisions(onEntity: entry.element, forCellPosition: cellPosition)
                }
            }
           
        }
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
            add(cellPositions: cellPositions, to: dirtyCellPositions)
            
            cellPositionsOfEntitiesById[entity.id] = cellPositions
            
            for cellPosition in cellPositions {
                add(entity: entity, toCellPosition: cellPosition)
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
            let cellPositions = cellPositionsOfEntitiesById[entity.id]
            
            if cellPositions != nil {
                remove(entity: entity, fromCellPositions: cellPositions!)
            }
            
            entities.removeValue(forKey: entity.id)
            cellPositionsOfEntitiesById.removeValue(forKey: entity.id)
        }
    }
    
    public func removed(component: Component, from entity: Entity) {
        if dependencies.contains(component.type) {
            removed(entity: entity)
        }
    }
    
    public func update(with currentTime: Double) {
        self.currentTime = currentTime
        findDirtyCells()
        updateGridCells(at: dirtyCellPositions)
        dirtyCellPositions = Array()
    }
}
