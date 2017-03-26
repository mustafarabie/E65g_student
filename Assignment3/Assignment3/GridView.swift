//
//  GridView.swift
//  Assignment3
//
//  Created by Mustafa Rabie on 3/26/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable class GridView: UIView {

    @IBInspectable var size = 20 {
        didSet{
            grid = Grid(size,size)
        }
    }
    @IBInspectable var livingColor = UIColor.black
    @IBInspectable var emptyColor = UIColor.clear
    @IBInspectable var bornColor = UIColor.darkGray
    @IBInspectable var diedColor = UIColor.gray
    @IBInspectable var gridColor = UIColor.cyan
    @IBInspectable var gridWidth: CGFloat = 0.0
    
    var grid = Grid(20,20)
    
    
    
}
