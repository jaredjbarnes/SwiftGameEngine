//
//  System.swift
//  LogicBox
//
//  Created by Jared Barnes on 10/9/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import Foundation

public protocol System : class {
    var name: String { get }
    func activated(on world: World)
    func added(entity: Entity)
    func added(component: Component, to entity: Entity)
    func deactivated(on world: World)
    func removed(entity: Entity)
    func removed(component: Component, from entity: Entity)
    func update(with time: Double)
}
