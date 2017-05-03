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
    
    var saveClosure: ((String) -> Void)?
    var gameTitle: String?
    var passedGridValues = [[Int]]()
    
    var engine: StandardEngine = StandardEngine(rows: 10, cols: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        
        if let gameTitle = gameTitle {
            gameTitleText.text = gameTitle
        }
        
        //engine = StandardEngine.gridEngine
        engine.delegate = self
        gridView.grid = self
        gridView.gridSize = engine.cols
    }

    
    func engineDidUpdate(withGrid: GridProtocol) {
        self.gridView.setNeedsDisplay()
    }
    
    
    @IBAction func barButtonSave(_ sender: UIBarButtonItem) {
        if let newValue = gameTitleText.text,
            let saveClosure = saveClosure {
            saveClosure(newValue)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    public subscript (row: Int, col: Int) -> CellState {
        get { return engine.grid[row,col] }
        set { engine.grid[row,col] = newValue }
    }
    
}
