//
//  GridView.swift
//  Final Project
//
//  Created by Mustafa Rabie on 3/26/17.
//  Copyright © 2017 Harvard Division of Continuing Education. All rights reserved.
//

import UIKit

@IBDesignable class GridView: UIView {
    
    @IBInspectable var gridSize = 10
    
    @IBInspectable var livingColor = UIColor.black
    @IBInspectable var emptyColor = UIColor.clear
    @IBInspectable var bornColor = UIColor.darkGray
    @IBInspectable var diedColor = UIColor.gray
    @IBInspectable var gridColor = UIColor.cyan
    @IBInspectable var gridWidth: CGFloat = 0.0
    
    var grid : GridViewDataSource?
    
    
    override func draw(_ rect: CGRect) {
        drawOvals(rect)
        drawGrid(rect)
    }
    
    
    func drawGrid(_ rect: CGRect){
        let _gridSize = CGFloat(self.gridSize)
        
        //draw lines
        //included the total size in order to draw the outter boundries of the grid
        (0...self.gridSize).forEach{
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
    
    func drawOvals(_ rect: CGRect) {
        let size = CGSize(
            width: rect.size.width / CGFloat(self.gridSize),
            height: rect.size.height / CGFloat(self.gridSize)
        )
        
        //draw circles
        let base = rect.origin
        
        (0...self.gridSize).forEach{ i in
            (0...self.gridSize).forEach{ j in
                let ovalOrigin = CGPoint(
                    x: base.x + (CGFloat(j) * size.width + 2.0),
                    y: base.y + (CGFloat(i) * size.height + 2.0)
                )
                
                // Make the oval draw 2 points short of the right and bottom edges
                let ovalSize = CGSize(
                    width: size.width - 4.0,
                    height: size.height - 4.0
                )
                
                
                let ovalRect = CGRect( origin: ovalOrigin, size: ovalSize )
                if let grid = self.grid {
                    switch grid[(i,j)]
                    {
                    //draw live circles
                    case .alive: drawOval(ovalRect, livingColor)
                    //draw born circles
                    case .born: drawOval(ovalRect, bornColor)
                    //draw died circles
                    case .died: drawOval(ovalRect, diedColor)
                    //draw empty circles
                    case .empty: drawOval(ovalRect, emptyColor)
                    }
                }
            }
        }
    }
    
    func drawOval(_ ovalRect: CGRect,_ fillColor : UIColor) {
        let path = UIBezierPath(ovalIn: ovalRect)
        fillColor.setFill()
        path.fill()
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
    var lastTouchedPosition: GridPosition?
    
    func process(touches: Set<UITouch>) -> GridPosition? {
        let touchY = touches.first!.location(in: self.superview).y
        let touchX = touches.first!.location(in: self.superview).x
        guard touchX > frame.origin.x && touchX < (frame.origin.x + frame.size.width) else { return nil }
        guard touchY > frame.origin.y && touchY < (frame.origin.y + frame.size.height) else { return nil }
        
        guard touches.count == 1 else { return nil }
        let pos = convert(touch: touches.first!)
        
        //************* IMPORTANT ****************
        guard lastTouchedPosition?.row != pos.row
            || lastTouchedPosition?.col != pos.col
            else { return pos }
        //****************************************
        
        if grid != nil {
            grid![pos.row, pos.col] = grid![pos.row, pos.col].isAlive ? .empty : .alive
            setNeedsDisplay()
        }
        return pos
    }
    
    func convert(touch: UITouch) -> GridPosition {
        let touchY = touch.location(in: self).y
        let gridHeight = frame.size.height
        let row = touchY / gridHeight * CGFloat(gridSize)
        
        let touchX = touch.location(in: self).x
        let gridWidth = frame.size.width
        let col = touchX / gridWidth * CGFloat(gridSize)
        
        return GridPosition(row: Int(row), col: Int(col))
    }
}
