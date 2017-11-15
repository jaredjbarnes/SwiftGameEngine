//
//  Position.swift
//  LogicBox
//
//  Created by Jared Barnes on 11/5/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import Foundation

public class Position: Component {
    public var x: Int = 0
    public var y: Int = 0
    public var isDirty: Bool = false
    
    override init(){
        super.init()
        self.type = "position"
    }
    
    convenience init(withX x: Int, andY y: Int){
        self.init()
        self.x = x
        self.y = y
    }
}
