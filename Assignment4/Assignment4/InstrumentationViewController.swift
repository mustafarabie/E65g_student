//
//  FirstViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController {

    
    @IBOutlet weak var refreshRateSlider: UISlider!
    @IBOutlet weak var rowsTxt: UITextField!
    @IBOutlet weak var colsTxt: UITextField!
    @IBOutlet weak var rowStepper: UIStepper!
    @IBOutlet weak var colStepper: UIStepper!
    
    var engine = StandardEngine.gridEngine
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rowsTxt.text = String(engine.rows)
        colsTxt.text = String(engine.cols)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onoffSwitch(_ sender: UISwitch) {
        if (sender.isOn){
            engine.refreshRate = Double(10)
        }
        else {
            engine.refreshRate = 0.0
        }
    }
    @IBAction func changeGridCols(_ sender: UIStepper) {
        
        colsTxt.text = String(sender.value)
        engine.cols = Int(sender.value)
        
        
    }
    @IBAction func changeGridRows(_ sender: UIStepper) {
        rowsTxt.text = String(sender.value)
        engine.rows = Int(sender.value)
    }


}

