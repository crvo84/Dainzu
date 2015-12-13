//
//  RingNode.swift
//  Roger 360
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/7/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import SpriteKit

class RingNode: SKSpriteNode {
    
    private var leftNode: SKCropNode?
    private var rightNode: SKShapeNode?
    
    var ringColor: SKColor {
        didSet {
            ringPartsSetup(height: size.height, color: ringColor)
        }
    }
    
    var pointToRight: Bool {
        didSet {
            updateXScale()
        }
    }
    
    var gravityNormal: Bool = true {
        didSet {
            updateZRotation()
        }
    }
    
    
    // Designated Initializer
    init(height: CGFloat, ringColor: SKColor, pointToRight: Bool)
    {
        self.ringColor = ringColor
        self.pointToRight = pointToRight
        
        let ringSize = CGSize(width: height * Geometry.RingRatio, height: height)
        
        // --------------------------------------------------------------------- //
        super.init(texture: nil, color: SKColor.clearColor(), size: ringSize)
        // --------------------------------------------------------------------- //

        ringPartsSetup(height: height, color: color)
        
        // ring slope
        updateZRotation()
        
        // original texture is pointing right
        updateXScale()
        
        // PHYSIC BODY
        let bodyRadius = height * Geometry.RingRelativeStrokeWidth/2
        // left
        let lowerBodyCenter = CGPoint(x: 0, y: -height/2)
        let lowerBody = SKPhysicsBody(circleOfRadius: bodyRadius, center: lowerBodyCenter)
        // right
        let upperBodyCenter = CGPoint(x: 0, y: +height/2)
        let upperBody = SKPhysicsBody(circleOfRadius: bodyRadius, center: upperBodyCenter)
        
        physicsBody = SKPhysicsBody(bodies: [lowerBody, upperBody])
        physicsBody!.dynamic = false
        physicsBody!.allowsRotation = false
        physicsBody!.density = Physics.RingDensity
        physicsBody!.linearDamping = Physics.RingLinearDamping
        physicsBody!.categoryBitMask = PhysicsCategory.Ring
        physicsBody!.collisionBitMask = PhysicsCategory.Boundary
        physicsBody!.contactTestBitMask = PhysicsCategory.Ball | PhysicsCategory.Boundary
        
        name = NodeName.Ring
    }
    
    private func updateXScale() {
        xScale = pointToRight ? 1 : -1
    }
    
    private func updateZRotation() {
        if gravityNormal {
            zRotation = pointToRight ? +Geometry.RingAngle : -Geometry.RingAngle
        } else {
            zRotation = pointToRight ? -Geometry.RingAngle : +Geometry.RingAngle
        }
    }
    
    private func ringPartsSetup(height height: CGFloat, color: SKColor) {
        leftNode?.removeFromParent()
        rightNode?.removeFromParent()
        
        leftNode = nil
        rightNode = nil
        
        // LEFT PART (half ellipse)
        let ellipseNodeLeft = getEllipseNode(height, color: color)
        let leftMask = SKSpriteNode(texture: nil, color: SKColor.blackColor(), size: CGSize(
            width: ellipseNodeLeft.frame.size.width/2,
            height: ellipseNodeLeft.frame.size.height))
        leftMask.anchorPoint = CGPoint(x: 0, y: 0.5)
        leftMask.position = CGPoint(x: -ellipseNodeLeft.frame.size.width/2, y: 0)
        leftNode = SKCropNode()
        leftNode!.addChild(ellipseNodeLeft)
        leftNode!.maskNode = leftMask
        leftNode!.zPosition = ZPosition.RingAbove // for 3D effect
        leftNode!.position = CGPoint(x: -leftNode!.frame.size.width/4, y: 0)
        addChild(leftNode!)
        
        // RIGHT PART (complete ellipse)
        rightNode = getEllipseNode(height, color: color)
        rightNode!.position = CGPoint(x: 0, y: 0)
        addChild(rightNode!)
    }

    private func getEllipseNode(height: CGFloat, color: SKColor) -> SKShapeNode {
        let ellipseNode = SKShapeNode(ellipseOfSize: CGSize(
            width: height * Geometry.RingRatio,
            height: height))
        ellipseNode.strokeColor = color
        ellipseNode.lineWidth = height * Geometry.RingRelativeStrokeWidth
        ellipseNode.name = NodeName.RingPart
        return ellipseNode
    }
    
    func startFloatingAnimation(verticalRange: CGFloat, durationPerCycle: Double, startUpward: Bool) {
        stopFloatingAnimation()
        
        let moveUpAction = SKAction.moveByX(0, y: verticalRange/2, duration: durationPerCycle/4)
        let moveUpReverseAction = moveUpAction.reversedAction()
        let moveDownAction = SKAction.moveByX(0, y: -verticalRange/2, duration: durationPerCycle/4)
        let moveDownReverseAction = moveDownAction.reversedAction()
        
        let moveSequence: [SKAction]
        if startUpward {
            moveSequence = [moveUpAction, moveUpReverseAction, moveDownAction, moveDownReverseAction]
        } else {
            moveSequence = [moveDownAction, moveDownReverseAction, moveUpAction, moveUpReverseAction]
        }
        runAction(SKAction.repeatActionForever(SKAction.sequence(moveSequence)), withKey: ActionKey.RingFloatingAnimation)
    }
    
    func stopFloatingAnimation() {
        removeActionForKey(ActionKey.RingFloatingAnimation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
