//
//  StandardEngine.swift
//  Final Project
//
//  Created by Mustafa Rabie on 4/22/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import Foundation

//typealias to the save the current gird state
public typealias GridCurrentState = [String : [[Int]]]

public struct JsonLoadedGrid {
    var gridSize = 0
    var title = String()
    var content = [[Int]]()
}

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
    var tempRefreshRate = 1/5.0
    //Bool variable to indicate weather the statistics data was loaded from saved data, in order not to update on 1st load
    var isJustLoaded : Bool = false
    
    var currentGridState : GridCurrentState
    
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
        currentGridState = [
            "statistics" : [],
            "gridSize"   : [],
            "alive"      : [],
            "born"       : [],
            "died"       : []
        ]
    }
    
    //updates Grid Size and refreshes the notifications
    func updateGridSize(_ size: Int) {
        self.rows = size
        self.cols = size
        grid = Grid(size, size)
        resetStats()
        updateNotification()
    }
    
    func updateGrid(_ updatedGrid: GridProtocol) {
        self.rows = updatedGrid.size.rows
        self.cols = updatedGrid.size.cols
        self.grid = updatedGrid
        resetStats()
        updateNotification()
    }
    
    //reset Grid
    func resetGrid() {
        grid = Grid(self.rows, self.cols)
        resetStats()
        updateNotification()
    }
    
    //gets the next step in the game
    func step() -> GridProtocol {
        let nextGrid = grid.next()
        grid = nextGrid
        updateNotification()
        return grid
    }
    
    //send a notification when an update to the Grid happens
    func updateNotification(){
        delegate?.engineDidUpdate(withGrid: grid)
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        let n = Notification(name: name,
                             object: nil,
                             userInfo: ["engine" : self])
        nc.post(n)
    }
    
    //gets RUNNING total for each state
    func getTotals(_ grid: GridProtocol) {
        if (!isJustLoaded){
            totalAlive = totalAlive + grid.aliveCount
            totalBorn  = totalBorn  + grid.bornCount
            totalDied  = totalDied  + grid.diedCount
            totalEmpty = totalEmpty + grid.emptyCount
        }
        else {
            isJustLoaded = false
        }
    }
    
    //reset statistics
    func resetStats() {
        totalAlive = 0
        totalBorn  = 0
        totalDied  = 0
        totalEmpty = 0
    }
    
    //save current state
    func saveCurrnetGridState(_ grid: GridProtocol) {
        grid.setConfiguration(currentStatistics: [totalAlive, totalDied, totalBorn, totalEmpty])
    }
    
    //load saved grid state
    func loadSavedGridState(_ loadedGridData: GridCurrentState) {
        //extract statistics from loadedGridData
        let statisticsData = loadedGridData["statistics"]
        //extract gridSize from loadedGridData
        let gridSizeData = loadedGridData["gridSize"]
        //extract alive cells array from loadedGridData
        let aliveData = loadedGridData["alive"]
        //extract born cells array from loadedGridData
        let bornData = loadedGridData["born"]
        //extract died cells array from loadedGridData
        let diedData = loadedGridData["died"]
        
        //set statistics of loaded Grid State
        totalAlive = statisticsData![0][0]
        totalDied  = statisticsData![0][1]
        totalBorn  = statisticsData![0][2]
        totalEmpty = statisticsData![0][3]
        
        //set isJustLoaded to True to load correct statistics data
        isJustLoaded = true
        
        //set gridSize to loaded GridSize
        grid = Grid(gridSizeData![0][0], gridSizeData![0][1])
        
        //set engine rows to the loaded gridSize rows
        StandardEngine.gridEngine.rows = grid.size.rows
        
        //set engine cols to the loaded gridSize cols
        StandardEngine.gridEngine.cols = grid.size.cols
        
        //loop through the alive cells and set state to the grid
        (0..<aliveData!.count).forEach { grid[aliveData![$0].first!, aliveData![$0].last!] = .alive }
        
        //loop through the born cells and set state to the grid
        (0..<bornData!.count).forEach { grid[bornData![$0].first!, bornData![$0].last!] = .born }
        
        //loop through the died cells and set state to the grid
        (0..<diedData!.count).forEach { grid[diedData![$0].first!, diedData![$0].last!] = .died }
    }
}
