//
//  RingView.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/15/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import UIKit

class RingView: UIView {
    
    private let halfRing: Bool
    private let leftHalf: Bool
    
    var color: UIColor = UIColor.black { didSet { setNeedsDisplay() } }
    
    var lineWidth: CGFloat = 2 { didSet { setNeedsDisplay() } }
    
    init(frame: CGRect, halfRing: Bool, leftHalf: Bool) {
        
        self.halfRing = halfRing
        self.leftHalf = leftHalf
        
        super.init(frame: frame)
        
        isOpaque = false
        backgroundColor = UIColor.clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        if halfRing {
            let clipOrigin = CGPoint(x: leftHalf ? 0 : frame.size.width/2, y: 0)
            
            let clipPath = UIBezierPath(rect: CGRect(origin: clipOrigin, size: CGSize(
                width: frame.size.width/2,
                height: frame.size.height)))
            
            clipPath.addClip()
        }

        let ovalRect = self.bounds.insetBy(dx: lineWidth/2, dy: lineWidth/2)
        
        let ovalPath = UIBezierPath(ovalIn: ovalRect)
        ovalPath.lineWidth = lineWidth
        color.setStroke()
        
        ovalPath.stroke()
    }
}










