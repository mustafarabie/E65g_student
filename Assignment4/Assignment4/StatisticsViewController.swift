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
 
    var engine = StandardEngine.gridEngine
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        var totalAlive = 0
        var totalBorn = 0
        var totalEmpty = 0
        var totalDied = 0
        
        (0 ..< engine.rows).forEach { i in
            (0 ..< engine.cols).forEach { j in
                
                    switch engine.grid[(i, j)] {
                    case .alive: totalAlive += 1
                    case .born: totalBorn += 1
                    case .empty: totalEmpty += 1
                    case .died: totalDied += 1
                    }
                
            }
        }
        aliveLabel.text = String(totalAlive)
        bornLabel.text = String(totalBorn)
        deadLabel.text = String(totalDied)
        emptyLabel.text = String(totalEmpty)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

