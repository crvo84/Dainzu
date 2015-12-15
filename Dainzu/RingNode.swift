//
//  RingNode.swift
//  Roger 360
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/7/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import SpriteKit

class RingNode: SKNode {
//    private var leftNode: SKCropNode?
    private var leftNode: SKSpriteNode?
    private var rightNode: SKSpriteNode?
    
    let size: CGSize
    
    let pointToRight: Bool
    
    var color: SKColor {
        didSet {
            ringPartsSetup()
        }
    }
    
    var gravityNormal: Bool = true {
        didSet {
            updateZRotation()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Designated Initializer
    init(size: CGSize, color: SKColor, pointToRight: Bool)
    {
        self.size = size
        self.pointToRight = pointToRight
        self.color = color
        
        // --------------------------------------------------------------------- //
        super.init()
        // --------------------------------------------------------------------- //
        
        ringPartsSetup()
        
        // ring slope
        updateZRotation()
        
        // original texture is pointing right
        updateXScale()
        
        // PHYSIC BODY
        let bodyRadius = size.height * Geometry.RingRelativeStrokeWidth/2
        // left
        let lowerBodyCenter = CGPoint(x: 0, y: -size.height/2 + bodyRadius)
        let lowerBody = SKPhysicsBody(circleOfRadius: bodyRadius, center: lowerBodyCenter)
        // right
        let upperBodyCenter = CGPoint(x: 0, y: +size.height/2 - bodyRadius)
        let upperBody = SKPhysicsBody(circleOfRadius: bodyRadius, center: upperBodyCenter)
        
        physicsBody = SKPhysicsBody(bodies: [lowerBody, upperBody])
        physicsBody!.dynamic = false
        physicsBody!.allowsRotation = false
        physicsBody!.density = Physics.RingDensity
        physicsBody!.restitution = Physics.RingBounciness
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
    
    private func ringPartsSetup() {
        leftNode?.removeFromParent()
        rightNode?.removeFromParent()
        
        leftNode = nil
        rightNode = nil
        
        // TODO: crop node is very expensive
        // LEFT PART
        leftNode = getOvalNode(leftHalfOnly: true)
        if leftNode != nil {
            leftNode!.zPosition = ZPosition.RingAbove // for 3D effect
            addChild(leftNode!)
        }
        
        // RIGHT PART
        rightNode = getOvalNode(leftHalfOnly: false)
        if rightNode != nil {
            addChild(rightNode!)
        }
    }
    
    private func getOvalNode(leftHalfOnly leftHalfOnly: Bool) -> SKSpriteNode?
    {
        let ovalRect = CGRect(origin: CGPoint(x: -size.width/2, y: -size.height/2), size: size)

        let halfRingView = RingView(frame: ovalRect, halfRing: leftHalfOnly, leftHalf: true)
        halfRingView.lineWidth = size.height * Geometry.RingRelativeStrokeWidth
        halfRingView.color = color
        
        var ovalNode: SKSpriteNode?
        if let halfRingImage = getImageWithView(halfRingView) {
            let halfRingTexture = SKTexture(image: halfRingImage)
            ovalNode = SKSpriteNode(texture: halfRingTexture)
            ovalNode?.name = NodeName.RingPart
        }
        
        return ovalNode
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
    
    // MARK: Helper methods
    
    private func getImageWithView(view: UIView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
        
        var img: UIImage?
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.renderInContext(context)
            img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext()
        }

        return img
    }
    
    
    
}
