//
//  GridEditorViewController.swift
//  FinalProject
//
//  Created by Mustafa Rabie on 5/2/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class GridEditorViewController: UIViewController, GridViewDataSource, EngineDelegate {

    @IBOutlet weak var gridView: GridView!
    @IBOutlet weak var gameTitleText: UITextField!
    
    //var saveClosure: ((String) -> Void)?
    var saveClosure: ((JsonLoadedGrid) -> Void)?
    //var gameTitle: String?
    var passedGridData : JsonLoadedGrid?

    
    var engine : StandardEngine = StandardEngine(rows: 10, cols: 10)
    
    
    let row = 0
    let col = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        
        /*if (passedGridData?.Content.count != 0) {
            gameTitleText.text = passedGridData?.Title
            loadGrid(passedGridData!)
        }*/
        gameTitleText.text = passedGridData?.Title
        loadGrid(passedGridData!)
        engine.delegate = self
        gridView.grid = self
        gridView.gridSize = engine.cols
    }

    
    func engineDidUpdate(withGrid: GridProtocol) {
        self.gridView.setNeedsDisplay()
    }
    
    func loadGrid(_ grid: JsonLoadedGrid) {
        var maxValue = 0
        if grid.gridSize == 0 {
            maxValue = getMaxElement(grid.Content) * 2
        }
        else {
            maxValue = grid.gridSize
        }
            
        engine.updateGridSize(maxValue)
        gridView.gridSize = engine.cols
        
        (0..<grid.Content.count).forEach { element in
            let cell = grid.Content[element]
            engine.grid[cell[row], cell[col]] = .alive
        }
        gridView.gridWidth = 0.1
        gridView.setNeedsDisplay()
    }
    
    func getMaxElement (_ gridCells: [[Int]]) -> Int {
        let flatArray = gridCells.joined()
        return flatArray.max()!
    }
    
    @IBAction func barButtonSave(_ sender: UIBarButtonItem) {

        passedGridData?.gridSize = engine.cols
        passedGridData?.Content = engine.grid.getAlivePositions()
        passedGridData?.Title = gameTitleText.text!
        
        StandardEngine.gridEngine = engine
        
        if let updateData = passedGridData,
            let saveClosure = saveClosure {
            saveClosure(updateData)
            navigationController?.popViewController(animated: true)
        }
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    
}
