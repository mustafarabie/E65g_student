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
    var engine: StandardEngine!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        engine = StandardEngine.gridEngine
        engine.delegate = self
        gridView.grid = self
        gridView.gridSize = engine.cols
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.gridView.gridSize = self.engine.cols
                self.gridView.setNeedsDisplay()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func engineDidUpdate(withGrid: GridProtocol) {
        self.gridView.setNeedsDisplay()
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnStep(_ sender: Any) {
        engine.grid = engine.step()
        gridView.setNeedsDisplay()
        
    }
    
}
