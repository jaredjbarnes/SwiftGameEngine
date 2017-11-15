//
//  Entity.swift
//  LogicBox
//
//  Created by Jared Barnes on 10/9/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import Foundation

public class Entity {
    private var components: Array<Component>
    
    public var id: String
    public var type : String
    public var delegate: EntityDelegate?
    
    public init (withType type: String){
        self.components = Array<Component>()
        self.type = type
        self.id = UUID().uuidString
    }
    
    public func add (component: Component){
        self.components.append(component);
        delegate?.added(component: component, to: self)
    }
    
    public func getComponents () -> Array<Component> {
        return self.components.map{$0};
    }
    
    public func getComponent(withType type: String) -> Component? {
        for component in self.components {
            if component.type == type  {
                return component
            }
        }
        
        return nil;
    }
    
    public func hasComponents(withTypes types: Array<String>) -> Bool {
        for type in types {
            var isIn = false;
            
            for component in components {
                if component.type == type {
                    isIn = true
                    break
                }
            }
            
            if !isIn {
                return false
            }
        }
        
        return true;
    }
    
    public func remove (component: Component) {
        let index = self.components.index(where: {(localComponent: Component) -> Bool in
            return component === localComponent;
        })
        
        if index != nil {
            self.components.remove(at: index!);
            delegate?.removed(component: component, from: self)
        }
    }
    
}
