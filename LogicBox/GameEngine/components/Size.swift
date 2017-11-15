//
//  Size.swift
//  LogicBox
//
//  Created by Jared Barnes on 11/14/17.
//  Copyright © 2017 Jared Barnes. All rights reserved.
//

import Foundation

public class Size: Component {
    public var width: Int = 0
    public var height: Int = 0
    public var isDirty: Bool = false
    
    override init(){
        super.init()
        self.type = "size"
    }
    
    convenience init (withWidth width: Int, withHeight height: Int){
        self.init()
        self.width = width
        self.height = height
    }
    
}
