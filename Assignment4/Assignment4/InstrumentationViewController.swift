//
//  FirstViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController {

    
    
    @IBOutlet weak var rowsText: UITextField!
    @IBOutlet weak var colsText: UITextField!
    @IBOutlet weak var rowsStepper: UIStepper!
    @IBOutlet weak var colsStepper: UIStepper!
    @IBOutlet weak var updateSlider: UISlider!
    @IBOutlet weak var autoSimulateSwitch: UISwitch!
    
    
    var engine : StandardEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        engine = StandardEngine.gridEngine
        rowsText.text = String(engine.rows)
        colsText.text = String(engine.cols)
        rowsStepper.value = Double(engine.rows)
        colsStepper.value = Double(engine.cols)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onoffSwitch(_ sender: UISwitch) {
        if (sender.isOn){
            engine.refreshRate = Double(updateSlider.value)
        }
        else {
            engine.refreshRate = 0.0
        }
    }
    
    @IBAction func changeGridCols(_ sender: UIStepper) {
        updateRowColSteppers(sender.value)
        updateRowColText(Int(sender.value))
        engine.updateGridSize(Int(sender.value))
    }
    
    @IBAction func changeGridRows(_ sender: UIStepper) {
        updateRowColSteppers(sender.value)
        updateRowColText(Int(sender.value))
        engine.updateGridSize(Int(sender.value))
    }
    
    @IBAction func refreshRateSlider(_ sender: UISlider) {
        if (autoSimulateSwitch.isOn) {
            engine.refreshRate = 0.0
            engine.refreshRate = Double(sender.value)
        }
        else {
            engine.refreshRate = 0.0
        }
    }
    
    private func updateRowColSteppers(_ size: Double) {
        rowsStepper.value = size
        colsStepper.value = size
    }
    
    private func updateRowColText(_ size: Int) {
        rowsText.text = String(size)
        colsText.text = String(size)
    }
    
    /*private func updateGrid(_ size: Int) {
        engine.rows = size
        engine.cols = size
        engine = StandardEngine(rows: size, cols: size)
    }*/

}

