//
//  StandardEngine.swift
//  Final Project
//
//  Created by Mustafa Rabie on 4/22/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import Foundation

//typealias to the save the current gird state
public typealias GridCurrentState = [String : Array<Array<Int>>]

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
    var tempRefreshRate = 0.0
    
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
        delegate?.engineDidUpdate(withGrid: grid)
        updateNotification()
    }
    
    //reset Grid
    func resetGrid() {
        grid = Grid(self.rows, self.cols)
        resetStats()
        delegate?.engineDidUpdate(withGrid: grid)
        updateNotification()
    }
    
    //gets the next step in the game
    func step() -> GridProtocol {
        let nextGrid = grid.next()
        grid = nextGrid
        delegate?.engineDidUpdate(withGrid: grid)
        updateNotification()
        return grid
    }
    
    //send a notification when an update to the Grid happens
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
    
    //save current state
    func saveCurrnetGridState(_ grid: GridProtocol) {

        currentGridState["statistics"]!.append([totalAlive,totalDied,totalBorn,totalEmpty])
        currentGridState["gridSize"]!.append([rows,cols])
        
        //loop through grid and save the current state of the alive, born and died cells
        (0 ..< rows).forEach { row in
            (0 ..< cols).forEach { col in
                switch grid[(row, col)] {
                case .alive: currentGridState["alive"]!.append([row,col])
                case .born: currentGridState["born"]!.append([row,col])
                case .died: currentGridState["died"]!.append([row,col])
                default: break
                }
            }
        }
        //save current state to user defaults
        let defaults = UserDefaults.standard
        defaults.set(currentGridState, forKey: "savedSession")
    }
    
    //load saved grid State
    func loadSavedGridState(_ loadedGridData: GridCurrentState)
    {
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
        
        let row = 0
        let col = 1
        
        //set statistics of loaded Grid State
        totalAlive = statisticsData![0][0]
        totalDied = statisticsData![0][1]
        totalBorn = statisticsData![0][2]
        totalEmpty = statisticsData![0][3]
        
        //set gridSize to loaded GridSize
        grid = Grid(gridSizeData![0][0], gridSizeData![0][1])
        
        //set engine rows to the loaded gridSize rows
        StandardEngine.gridEngine.rows = grid.size.rows
        
        //set engine cols to the loaded gridSize cols
        StandardEngine.gridEngine.cols = grid.size.cols
        
        //loop through the alive cells and set state to the grid
        (0..<aliveData!.count).forEach { i in
            let cell = aliveData![i]
            grid[cell[row], cell[col]] = .alive
        }
        
        //loop through the born cells and set state to the grid
        (0..<bornData!.count).forEach { i in
            let cell = bornData![i]
            grid[cell[row], cell[col]] = .born
        }
        
        //loop through the died cells and set state to the grid
        (0..<diedData!.count).forEach { i in
            let cell = diedData![i]
            grid[cell[row], cell[col]] = .died
        }
        
    }
}
