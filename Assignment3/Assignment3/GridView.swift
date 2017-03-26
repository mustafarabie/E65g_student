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
    
    public var grid = Grid(20,20)
    
    override func draw(_ rect: CGRect) {
        
        let size = CGSize(
            width: rect.size.width / CGFloat(self.size),
            height: rect.size.height / CGFloat(self.size)
        )

        //draw circles
        let base = rect.origin
        
        (0...self.size).forEach{ i in
            (0...self.size).forEach{ j in
                let origin = CGPoint(
                    x: base.x + (CGFloat(j) * size.width),
                    y: base.y + (CGFloat(i) * size.height)
                )
                let subRect = CGRect(
                    origin: origin,
                    size: size
                )
                //draw live circles
                if (grid[(i,j)].isAlive){
                    let path = UIBezierPath(ovalIn: subRect)
                    livingColor.setFill()
                    path.fill()
                }
            }
        }
        
        //converting size from Int to CGFloats
        let _gridSize = CGFloat(self.size)
        
        //draw lines
        //included the total size in order to draw the outter boundries of the grid
        (0...self.size).forEach{
            //draw vertical lines
            drawLine(
                start: CGPoint(x: CGFloat($0)/_gridSize * rect.size.width, y: 0.0),
                end:   CGPoint(x: CGFloat($0)/_gridSize * rect.size.width, y: rect.size.height)
            )
            
            //draw horizontal lines
           drawLine(
                start: CGPoint(x: 0.0, y: CGFloat($0)/_gridSize * rect.size.height ),
                end: CGPoint(x: rect.size.width, y: CGFloat($0)/_gridSize * rect.size.height)
            )
        }

        
    }
    
    /* 
       name   : drawLine
       input  : CGPoint start
                CGPoint end
       summary: draws a line between the 2, using the color specified by gridColor
    */
    func drawLine(start:CGPoint, end: CGPoint) {
        let path = UIBezierPath()
        
        //set the path's line width to the height of the stroke
        path.lineWidth = gridWidth
        
        //move the initial point of the path
        //to the start of the horizontal stroke
        path.move(to: start)
        
        //add a point to the path at the end of the stroke
        path.addLine(to: end)
        
        //draw the stroke
        gridColor.setStroke()
        path.stroke()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = process(touches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchedPosition = nil
    }
   
    // Updated since class
    typealias Position = (row: Int, col: Int)
    var lastTouchedPosition: Position?
    
    func process(touches: Set<UITouch>) -> Position? {
        guard touches.count == 1 else { return nil }
        let pos = convert(touch: touches.first!)
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        
        grid[pos] = grid[pos].toggle(value: grid[pos])
        setNeedsDisplay()
        return pos
    }
    
    func convert(touch: UITouch) -> Position {
        let touchY = touch.location(in: self).y
        let gridHeight = frame.size.height
        let row = touchY / gridHeight * CGFloat(size)
        let touchX = touch.location(in: self).x
        let gridWidth = frame.size.width
        let col = touchX / gridWidth * CGFloat(size)
        let position = (row: Int(row), col: Int(col))
        return position
    }

    
}
