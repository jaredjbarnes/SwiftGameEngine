//
//  EntityDelegate.swift
//  LogicBox
//
//  Created by Jared Barnes on 10/9/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import Foundation

public protocol EntityDelegate {
    func added (component: Component, to entity: Entity)
    func removed (component: Component, from entity: Entity)
}
