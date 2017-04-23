//
//  Engine.swift
//  Assignment4
//
//  Created by Mustafa Rabie on 4/22/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import Foundation

protocol EngineDelegate {
    func engineDidUpdate(withGrid: GridProtocol)
}

protocol EngineProtocol {
    //EngineProtocol Engine
    var delegate: EngineDelegate? {get set}
    var grid: GridProtocol {get}
    var refreshRate: Double {get set}
    var refreshTimer: Timer? {get set}
    var rows: Int {get set}
    init(rows:Int, cols:Int)
    func step() -> GridProtocol
}
