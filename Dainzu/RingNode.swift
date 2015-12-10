//
//  RingNode.swift
//  Roger 360
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/7/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import SpriteKit

class RingNode: SKSpriteNode {
    
    // Designated Initializer
    init(height: CGFloat, pointToRight: Bool)
    {
        // left side
        let leftTexture = SKTexture(imageNamed: ImageFilename.RingLeft)
        let leftTextureRatio = leftTexture.size().width / leftTexture.size().height
        let leftNodeSize = CGSize(width: height * leftTextureRatio, height: height)
        let leftNode = SKSpriteNode(texture: leftTexture, color: SKColor.clearColor(), size: leftNodeSize)
        leftNode.anchorPoint = CGPoint(x: 1, y: 0.5)
        leftNode.zPosition = ZPosition.RingAbove // higher zPosition for 3D effect
        
        // right side
        let rightTexture = SKTexture(imageNamed: ImageFilename.RingRight)
        let rightTextureRatio = rightTexture.size().width / rightTexture.size().height
        let rightNodeSize = CGSize(width: height * rightTextureRatio, height: height)
        let rightNode = SKSpriteNode(texture: rightTexture, color: SKColor.clearColor(), size: rightNodeSize)
        rightNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        rightNode.zPosition = ZPosition.RingBelow // lower zPosition for 3D effect
        
        let ringSize = CGSize(width: leftNodeSize.width + rightNodeSize.width, height: height)
        
        // --------------------------------------------------------------------- //
        super.init(texture: nil, color: SKColor.clearColor(), size: ringSize)
        // --------------------------------------------------------------------- //
        
        // add both ring sides to parent sprite node
        addChild(leftNode)
        addChild(rightNode)
        
        // original texture is pointing right, rotate to point left
        zRotation = pointToRight ? 0 : π
        
        // physic bodies
        let bodyRadius = height * Geometry.RingPhysicsBodyRelativeHeight/2
        // left
        let lowerBodyCenter = CGPoint(x: 0, y: -height/2 + bodyRadius)
        let lowerBody = SKPhysicsBody(circleOfRadius: bodyRadius, center: lowerBodyCenter)
        // right
        let upperBodyCenter = CGPoint(x: 0, y: +height/2 - bodyRadius)
        let upperBody = SKPhysicsBody(circleOfRadius: bodyRadius, center: upperBodyCenter)
        
        physicsBody = SKPhysicsBody(bodies: [lowerBody, upperBody])
        physicsBody!.dynamic = false
        physicsBody!.allowsRotation = false
        physicsBody!.density = Physics.RingDensity
        physicsBody!.linearDamping = Physics.RingLinearDamping
        physicsBody!.categoryBitMask = PhysicsCategory.Ring
        physicsBody!.collisionBitMask = PhysicsCategory.Ball | PhysicsCategory.Boundary
        physicsBody!.contactTestBitMask = PhysicsCategory.Ball | PhysicsCategory.Boundary
    }
    
    func startFloatingAnimation(verticalRange: CGFloat, durationPerCycle: Double) {
        let moveUpAction = SKAction.moveByX(0, y: verticalRange/2, duration: durationPerCycle/4)
        let moveUpReverseAction = moveUpAction.reversedAction()
        let moveDownAction = SKAction.moveByX(0, y: verticalRange/2, duration: durationPerCycle/4)
        let moveDownReverseAction = moveDownAction.reversedAction()
        let moveSequenceAction = SKAction.sequence([moveUpAction, moveUpReverseAction, moveDownAction, moveDownReverseAction])
        runAction(SKAction.repeatActionForever(moveSequenceAction), withKey: ActionKey.RingFloatingAnimation)
    }
    
    func stopFloatingAnimation() {
        removeActionForKey(ActionKey.RingFloatingAnimation)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
