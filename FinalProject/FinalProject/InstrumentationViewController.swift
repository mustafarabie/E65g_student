//
//  FirstViewController.swift
//  Final Project
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

var sectionHeaders = [
    "One", "Two", "Three", "Four", "Five", "Six"
]

var data = [
    [
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date"
    ],
    [
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana"
    ],
    [
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry"
    ],
    [
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Apple",
        "Banana",
        "Cherry",
        "Date",
        "Kiwi",
        "Blueberry"
    ]
]


class InstrumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var updateSlider: UISlider!
    @IBOutlet weak var gridRowLabel: UILabel!
    @IBOutlet weak var gridColLabel: UILabel!
    @IBOutlet weak var gridRowStepper: UIStepper!
    @IBOutlet weak var gridColStepper: UIStepper!
    @IBOutlet weak var gamesTableView: UITableView!
    
    var engine : StandardEngine!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        engine = StandardEngine.gridEngine
        gridRowLabel.text = String(engine.rows)
        gridColLabel.text = String(engine.cols)
        gridRowStepper.value = Double(engine.rows)
        gridColStepper.value = Double(engine.cols)
        engine.tempRefreshRate = Double(1/updateSlider.value)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func changeGridSize(_ sender: UIStepper) {
        if(sender.value >= 10) {
        updateGridSizeSteppers(sender.value)
        updateGridSizeText(Int(sender.value))
        engine.updateGridSize(Int(sender.value))
        }
        else {
            alertMessageOk(title: "oops ... Sorry!",message: "minmun Grid Size is 10x10")
            updateGridSizeSteppers(10.0)
            updateGridSizeText(10)
            engine.updateGridSize(10)
        }
    }
    
    @IBAction func refreshRateSlider(_ sender: UISlider) {
        engine.tempRefreshRate = Double(1/sender.value)
    }
    
    
    @IBAction func addNewGameButtonAction(_ sender: UIButton) {
        data[0] = ["New Game"] + data[0]
        self.gamesTableView.reloadData()
    }
    
    
    
    //updates rows and cols steppers values
    private func updateGridSizeSteppers(_ size: Double) {
        gridRowStepper.value = size
        gridColStepper.value = size
    }
    
    //updates rows and cols text fields
    private func updateGridSizeText(_ size: Int) {
        gridRowLabel.text = String(size)
        gridColLabel.text = String(size)
    }
    
    
    //MARK: TableView DataSource and Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "basic"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        label.text = data[indexPath.section][indexPath.item]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var newData = data[indexPath.section]
            newData.remove(at: indexPath.row)
            data[indexPath.section] = newData
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
    }
    
   /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = gamesTableView.indexPathForSelectedRow
        if let indexPath = indexPath {
            let fruitValue = data[indexPath.section][indexPath.row]
            if let vc = segue.destination as? GridEditorViewController {
                vc.fruitValue = fruitValue
                vc.saveClosure = { newValue in
                    data[indexPath.section][indexPath.row] = newValue
                    self.tableView.reloadData()
                }
            }
        }
    } */
    
    //MARK: AlertController Handling
    func alertMessageOk(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

