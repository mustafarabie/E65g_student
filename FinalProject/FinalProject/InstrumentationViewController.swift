//
//  FirstViewController.swift
//  Final Project
//
//  Created by Van Simmons on 1/15/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

class InstrumentationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var updateSlider: UISlider!
    @IBOutlet weak var gridRowLabel: UILabel!
    @IBOutlet weak var gridColLabel: UILabel!
    @IBOutlet weak var gridRowStepper: UIStepper!
    @IBOutlet weak var gridColStepper: UIStepper!
    @IBOutlet weak var gamesTableView: UITableView!
    
    var engine : StandardEngine!
    var gameCellsData = [JsonLoadedGrid]()
    
    //Spinner code from https://github.com/angeldev/iOSDev/tree/master/activityIndicatorOverUITableView
    /// View which contains the loading text and the spinner
    let loadingView = UIView()
    
    /// Spinner shown during load the TableView
    let spinner = UIActivityIndicatorView()
    
    /// Text shown during load the TableView
    let loadingLabel = UILabel()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        engine = StandardEngine.gridEngine
        updateGridSizeSteppers(engine.rows)
        updateGridSizeText(engine.rows)
        engine.tempRefreshRate = Double(1/updateSlider.value)
        //show spinner
        setLoadingScreen()
        fetchDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: Actions
    @IBAction func changeGridSize(_ sender: UIStepper) {
        if(sender.value >= 10) {
            updateGridSizeSteppers(Int(sender.value))
            updateGridSizeText(Int(sender.value))
            engine.updateGridSize(Int(sender.value))
        }
        else {
            alertMessageOk(title: "oops ... Sorry!",message: "minmun Grid Size is 10x10")
            updateGridSizeSteppers(10)
            updateGridSizeText(10)
            engine.updateGridSize(10)
        }
    }
    
    @IBAction func refreshRateSlider(_ sender: UISlider) {
        engine.tempRefreshRate = Double(1/sender.value)
    }
    
    
    @IBAction func addNewGameButtonAction(_ sender: UIButton) {
        gameCellsData.insert(JsonLoadedGrid(gridSize: Int(gridColStepper.value), title: "New Game", content: [] ), at: gameCellsData.startIndex)
        self.gamesTableView.reloadData()
    }
    
    //updates rows and cols steppers values
    private func updateGridSizeSteppers(_ size: Int) {
        gridRowStepper.value = Double(size)
        gridColStepper.value = Double(size)
    }
    
    //updates rows and cols text fields
    private func updateGridSizeText(_ size: Int) {
        gridRowLabel.text = String(size)
        gridColLabel.text = String(size)
    }
    
    
    //MARK: TableView DataSource and Delegate
    func numberOfSections(in gamesTableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ gamesTableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameCellsData.count
    }
    
    func tableView(_ gamesTableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "basic"
        let cell = gamesTableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        let label = cell.contentView.subviews.first as! UILabel
        label.text = gameCellsData[indexPath.item].title//gameTitlesData[indexPath.section][indexPath.item]
        return cell
    }
    
    func tableView(_ gamesTableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            gameCellsData.remove(at: indexPath.row)
            gamesTableView.deleteRows(at: [indexPath], with: .automatic)
            gamesTableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let indexPath = gamesTableView.indexPathForSelectedRow
        if let indexPath = indexPath {
            let jsonLoadedGridData = gameCellsData[indexPath.item]
            if let vc = segue.destination as? GridEditorViewController {
                vc.passedGridData = jsonLoadedGridData
                vc.saveClosure = { updateData in
                    self.gameCellsData[indexPath.item] = updateData
                    self.gamesTableView.reloadData()
                    self.updateGridSizeSteppers(updateData.gridSize)
                    self.updateGridSizeText(updateData.gridSize)
                }
            }
        }
    }
    
    func fetchDate() {
        let fetcher = Fetcher()
        let finalProjectURL = "https://dl.dropboxusercontent.com/u/7544475/S65g.json"
        
        fetcher.fetchJSON(url: URL(string:finalProjectURL)!) { (json: Any?, message: String?) in
            guard message == nil else {
                print(message ?? "nil")
                return
            }
            guard let json = json else {
                print("no json")
                return
            }
            
            let jsonArray = json as! NSArray
            
            (0..<jsonArray.count).forEach { i in
                let jsonDictionary = jsonArray[i] as! NSDictionary
                let jsonTitle = jsonDictionary["title"] as! String
                var tempLoadedGridData = JsonLoadedGrid()
                tempLoadedGridData.title = jsonTitle
                let jsonContents = jsonDictionary["contents"] as! [[Int]]
                (0..<jsonContents.count).forEach { tempLoadedGridData.content.append([jsonContents[$0].first!, jsonContents[$0].last!]) }
                
                tempLoadedGridData.gridSize = self.getGridSize(tempLoadedGridData.content)
                self.gameCellsData.append(tempLoadedGridData)
            }
            
            OperationQueue.main.addOperation {
                self.gamesTableView.reloadData()
                self.removeLoadingScreen()
            }
        }
    }
    
    //gets the new gridSize
    func getGridSize (_ gridCells: [[Int]]) -> Int {
        let flatArray = gridCells.joined()
        let maxValue = flatArray.max()! * 2
        //return the gridSize rounded up to the 10th interval
        return Int(10 * (Double(maxValue)/10.0).rounded(.up))
    }
    
    //MARK: AlertController Handling
    func alertMessageOk(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // Set the activity indicator into the main view
    fileprivate func setLoadingScreen() {
        
        // Sets the view which contains the loading text and the spinner
        let width: CGFloat = 120
        let height: CGFloat = 30
        let x = (self.gamesTableView.frame.width / 2) - (width / 2)
        let y = (self.gamesTableView.frame.height / 2) - (height / 2) - (self.navigationController?.navigationBar.frame.height)!
        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
        
        // Sets loading text
        self.loadingLabel.textColor = UIColor.gray
        self.loadingLabel.textAlignment = NSTextAlignment.center
        self.loadingLabel.text = "Fetching Data..."
        self.loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        
        // Sets spinner
        self.spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        self.spinner.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.spinner.startAnimating()
        
        // Adds text and spinner to the view
        loadingView.addSubview(self.spinner)
        loadingView.addSubview(self.loadingLabel)
        
        self.gamesTableView.addSubview(loadingView)
        
    }
    
    // Remove the activity indicator from the main view
    fileprivate func removeLoadingScreen() {
        
        // Hides and stops the text and the spinner
        self.spinner.stopAnimating()
        self.loadingLabel.isHidden = true
        
    }
}

