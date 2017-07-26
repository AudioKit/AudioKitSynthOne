//
//  TouchPadView.swift
//  AudioKit Synth One
//
//  Created by Matthew Fecher on 3/3/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import UIKit

protocol TouchPadViewDelegate {
    func touchPadTouchesBegan()
    func touchPadValueDidChange(_ touchX: CGFloat, touchY: CGFloat, percentX: Double, percentY: Double, tag: Int)
    func touchPadTouchesEnded()
    func touchPadDidCenter()
}

class TouchPadView: UIView {
    
    // touch properties
    var firstTouch: UITouch?
    
    var horizontalPercentage: CGFloat = 0.0
    var verticalPercentage: CGFloat = 0.0
    var lastX: CGFloat = 0
    var lastY: CGFloat = 0
    
    var minimum = 0.0
    var maximum = 1.0
    
    var xValue: Double = 0 {
        didSet {
            if xValue > maximum {
                xValue = maximum
            }
            if xValue < minimum {
                xValue = minimum
            }
        }
    }
    
    var yValue: Double = 0 {
        didSet {
            if yValue > maximum {
                yValue = maximum
            }
            if yValue < minimum {
                yValue = minimum
            }
        }
    }
    
    var touchImageView: UIImageView!
    var delegate: TouchPadViewDelegate?
    
    // *********************************************************
    // MARK: - Init
    // *********************************************************
    
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Setup Touch Visual Indicators
        touchImageView = UIImageView(frame: CGRect(x: -200, y: -200, width: 85, height: 85))
        touchImageView.image = UIImage(named: "touchpoint2")
        touchImageView.center = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        
        self.addSubview(touchImageView)
    }
    
    // *********************************************************
    // MARK: - Handle Touches
    // *********************************************************
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            lastX = touchPoint.x
            lastY = touchPoint.y
            setPercentagesWithTouchPoint(touchPoint)
            delegate?.touchPadTouchesBegan()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let touchPoint = touch.location(in: self)
            setPercentagesWithTouchPoint(touchPoint)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // return indicator to center of view
        delegate?.touchPadTouchesEnded()
    }
    
    func resetToCenter() {
        resetToPosition(0.5, newPercentY: 0.5)
    }
    
    func resetToPosition(_ newPercentX: Double, newPercentY: Double) {
        let centerPointX = self.bounds.size.width * CGFloat(newPercentX)
        let centerPointY = self.bounds.size.height * CGFloat((1 - newPercentY))
   
        UIView.animate(withDuration: 0.2,
           delay: 0.0,
           options: UIViewAnimationOptions(),
           animations: {
                self.touchImageView.center = CGPoint(x: centerPointX, y: centerPointY)
           },
           completion: { finished in
            self.xValue = Double(newPercentX)
            self.yValue = Double(newPercentY)
            
            self.delegate?.touchPadDidCenter()
        })
    }
    
    // *********************************************************
    // MARK: - Set percentages, call delegate
    // *********************************************************
    
    func setPercentagesWithTouchPoint(_ touchPoint: CGPoint) {
        horizontalPercentage = touchPoint.x / self.bounds.size.width
        verticalPercentage = 1 - touchPoint.y / self.bounds.size.height
        
        xValue = Double(horizontalPercentage)
        yValue = Double(verticalPercentage)
        updateIndicatorsAndDelegate(touchPoint, xValue: xValue, yValue: yValue)
    }
    
    func updateIndicatorsAndDelegate(_ touchPoint: CGPoint, xValue: Double, yValue: Double) {
        touchImageView.center = CGPoint(x: touchPoint.x, y: touchPoint.y)
        delegate?.touchPadValueDidChange(touchPoint.x, touchY: touchPoint.y, percentX: xValue, percentY: yValue, tag: self.tag)
    }
    
}
