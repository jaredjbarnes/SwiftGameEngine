//
//  World.swift
//  LogicBox
//
//  Created by Jared Barnes on 10/9/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import Foundation
import UIKit

public class World : EntityDelegate {
    private var entities: Dictionary<String, Entity> = Dictionary()
    private var timer: Timer?
    private var lastPlayTimestamp: Double = 0.0
    private var systems: Array<System> = Array()
    private var services: Array<Service> = Array()
    private var timespans: Array<Double> = Array()
    
    public var size: CGRect
    
    public init (with rect: CGRect){
        self.size = rect
    }
    
    public func add (entity: Entity) {
        if entities[entity.id] == nil {
            entities.updateValue(entity, forKey: entity.id)
            
            for system in systems {
                system.added(entity: entity)
                entity.delegate = self
            }
        }
    }
    
    public func add (service: Service) {
        if services.index(where:{ $0 === service } ) == nil {
            services.append(service)
        }
    }
    
    public func add (system: System) {
        if systems.index(where:{ $0 === system}) == nil {
            systems.append(system)
            system.activated(on: self)
        }
    }
    
    public func added (component: Component, to entity: Entity) {
        for system in systems {
            system.added(component: component, to: entity)
        }
    }
    
    public func getEntities () -> Dictionary<String, Entity> {
        return getEntities(with: {
            (_,_) in
            return true
        })
    }
    
    public func getEntities (with filter: (String, Entity) -> Bool ) -> Dictionary<String, Entity> {
        return entities.filter(filter)
    }
    
    public func getEntity(withId id: String) -> Entity? {
        return entities[id]
    }
    
    public func getTime () -> Double {
        return timespans.reduce(0, {
            (result, value) -> Double in
            return result+value
        })
    }
    
    public func pause () {
        if timer != nil {
            
            let currentTimestamp = CFAbsoluteTimeGetCurrent()
            let timespan = currentTimestamp - lastPlayTimestamp
            
            timespans.append(timespan)
            
            timer?.invalidate()
            timer = nil
            
        }
    }
    
    public func play () {
        if timer == nil {
            lastPlayTimestamp = CFAbsoluteTimeGetCurrent()
            timer = Timer(
                timeInterval: 0.16,
                target: self,
                selector: #selector(self.update),
                userInfo: nil,
                repeats: true
            )
        }
    }
    
    public func remove (entity: Entity) {
        entities.removeValue(forKey: entity.id)
        
        for system in systems {
            system.removed(entity: entity)
            entity.delegate = nil
        }
    }
    
    public func remove (system: System) {
        if let index = systems.index(where: { $0 === system}) {
            systems.remove(at: index)
            system.deactivated(on: self)
        }
    }
    
    public func remove (service: Service) {
        if let index = systems.index(where: { $0 === service}) {
            services.remove(at: index)
        }
    }
    
    public func removed (component: Component, from entity: Entity) {
        for system in systems {
            system.removed(component: component, from: entity)
        }
    }
    
    @objc
    public func update (){
        let currentTime = getTime()
        for system in systems {
            system.update(withTime: currentTime)
        }
    }
}
