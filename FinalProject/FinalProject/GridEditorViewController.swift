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
    @IBOutlet weak var gameTitleTextField: UITextField!
    
    var saveClosure: ((JsonLoadedGrid) -> Void)?
    var passedGridData : JsonLoadedGrid?
    var grid : Grid!
    
    let row = 0
    let col = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        
        gameTitleTextField.text = passedGridData?.title
        grid = Grid((passedGridData!.gridSize), passedGridData!.gridSize)
        loadGrid(passedGridData!)
        gridView.grid = self
        gridView.gridSize = (passedGridData?.gridSize)!
    }
    
    
    func engineDidUpdate(withGrid: GridProtocol) {
        self.gridView.setNeedsDisplay()
    }
    
    func loadGrid(_ grid: JsonLoadedGrid) {
        
        (0..<grid.content.count).forEach { self.grid?[grid.content[$0].first!, grid.content[$0].last!] = .alive }
        
        //make the gridlines thin for better visibility if gridSize is > 20x20
        if grid.gridSize > 20 {
            gridView.gridWidth = 0.1
        }
        gridView.setNeedsDisplay()
    }
    
    @IBAction func barButtonSave(_ sender: UIBarButtonItem) {
        
        //set values to pass back
        passedGridData?.gridSize = (self.grid?.size.rows)!
        passedGridData?.content = (self.grid?.getAlivePositions())!
        passedGridData?.title = gameTitleTextField.text!
        
        //set current grid changes to the Engine's grid
        StandardEngine.gridEngine.updateGrid(grid!)
        
        if let updateData = passedGridData,
            let saveClosure = saveClosure {
            saveClosure(updateData)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return self.grid![row,col] }
        set { self.grid?[row,col] = newValue }
    }
    
}
