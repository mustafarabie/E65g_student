//
//  SimulationViewController.swift
//  Final Project
//
//  Created by Mustafa Rabie on 4/22/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class SimulationViewController: UIViewController, GridViewDataSource, EngineDelegate{
    
    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var horAutoSimulateButton: UISwitch!
    @IBOutlet weak var verAutoSimulateButton: UISwitch!
    
    var engine: StandardEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        engine = StandardEngine.gridEngine
        engine.delegate = self
        gridView.grid = self
        gridView.gridSize = engine.cols
        
        if engine.cols > 20 {
            gridView.gridWidth = 0.1
        }
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.gridView.gridSize = self.engine.cols
                self.gridView.setNeedsDisplay()
                self.autoSimulate()
                
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func stepButton(_ sender: UIButton) {
        engine.grid = engine.step()
        gridView.setNeedsDisplay()
    }
    
    func engineDidUpdate(withGrid: GridProtocol) {
        self.gridView.setNeedsDisplay()
    }
    @IBAction func saveStateButton(_ sender: UIButton) {
        engine.saveCurrnetGridState(engine.grid)
        engine.getAllAlive()
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func resetGrid(_ sender: UIButton) {
        engine.resetGrid()
        verAutoSimulateButton.isOn = false
        horAutoSimulateButton.isOn = false
    }
    
    @IBAction func autoSimulateAction(_ sender: UISwitch) {
        verAutoSimulateButton.isOn = sender.isOn
        horAutoSimulateButton.isOn = sender.isOn
        autoSimulate()
    }
    
    func autoSimulate() {
        if (horAutoSimulateButton.isOn || verAutoSimulateButton.isOn) {
            engine.refreshRate = 0.0
            engine.refreshRate = engine.tempRefreshRate
        }
        else {
            engine.refreshRate = 0.0
        }
    }
    
}
