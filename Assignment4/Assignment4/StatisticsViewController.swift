//
//  SecondViewController.swift
//  Assignment4
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController {

    
    @IBOutlet weak var aliveLabel: UILabel!
    @IBOutlet weak var deadLabel: UILabel!
    @IBOutlet weak var bornLabel: UILabel!
    @IBOutlet weak var emptyLabel: UILabel!
 
    var engine : StandardEngine!
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        engine = StandardEngine.gridEngine
        
        updateStats()
        
        let nc = NotificationCenter.default
        let name = Notification.Name(rawValue: "EngineUpdate")
        nc.addObserver(
            forName: name,
            object: nil,
            queue: nil) { (n) in
                self.updateStats()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
   
    func updateStats(){
        engine.getTotals(engine.grid)
        aliveLabel.text = String(engine.totalAlive)
        bornLabel.text = String(engine.totalBorn)
        deadLabel.text = String(engine.totalDied)
        emptyLabel.text = String(engine.totalEmpty)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

