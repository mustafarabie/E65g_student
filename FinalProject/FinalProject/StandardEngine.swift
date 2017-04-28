//
//  StandardEngine.swift
//  Final Project
//
//  Created by Mustafa Rabie on 4/22/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import Foundation

class StandardEngine: EngineProtocol {
    
    //Lazy Singleton
    static var gridEngine : StandardEngine = StandardEngine(rows: 10, cols: 10)

    var grid: GridProtocol
    var delegate: EngineDelegate?
    var refreshTimer: Timer?
    var rows: Int;
    var cols: Int;
    var totalAlive: Int;
    var totalBorn: Int;
    var totalDied: Int;
    var totalEmpty: Int;
    
    var refreshRate = 0.0 {
        didSet{
            if refreshRate > 0.0 {
                refreshTimer = Timer.scheduledTimer(
                    withTimeInterval: refreshRate,
                    repeats: true
                ) { (t: Timer) in
                    _ = self.step()
                }
            }
            else {
                refreshTimer?.invalidate()
                refreshTimer = nil
            }
        }
    }
    
       required init(rows: Int, cols: Int) {
        self.rows = rows
        self.cols = cols
        self.grid = Grid(rows, cols)
        totalAlive = 0
        totalBorn = 0
        totalDied = 0
        totalEmpty = 0
        delegate?.engineDidUpdate(withGrid: grid)
    }
    
    //updates Grid Size and refreshes the notifications
    func updateGridSize(_ size: Int) {
        self.rows = size
        self.cols = size
        grid = Grid(size, size)
        resetStats()
        delegate?.engineDidUpdate(withGrid: grid)
        updateNotification()
    }
    

    func step() -> GridProtocol {
        let nextGrid = grid.next()
        grid = nextGrid
        delegate?.engineDidUpdate(withGrid: grid)
        updateNotification()
        return grid
    }
    
    //notifications
    func updateNotification(){
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }
    
    //gets total counts for each state
    func getTotals(_ grid: GridProtocol){
        //resetStats() -- commented out to get running stats
        (0 ..< rows).forEach { row in
            (0 ..< cols).forEach { col in
                
                switch grid[(row, col)] {
                case .alive: totalAlive += 1
                case .born: totalBorn += 1
                case .empty: totalEmpty += 1
                case .died: totalDied += 1
                }
                
            }
        }
    }
    
    //reset stats
    func resetStats() {
        totalAlive = 0
        totalBorn = 0
        totalDied = 0
        totalEmpty = 0
    }
    
}

