//
//  BallNode.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/11/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import SpriteKit

class BallNode: SKSpriteNode {
    
    var affectedByGravity = false {
        didSet {
            physicsBody?.affectedByGravity = affectedByGravity
        }
    }

    init(texture: SKTexture?, height: CGFloat, color: SKColor) {
        let nodeRatio = texture != nil ? texture!.size().width / texture!.size().height : 1.0
        let nodeSize = CGSize(width: height * nodeRatio, height: height)
        
        super.init(texture: texture, color: SKColor.clearColor(), size: nodeSize)
        
        // if no given texture, add circle node
        if texture == nil {
            let circleNode = SKShapeNode(circleOfRadius: height/2)
            circleNode.fillColor = color
            addChild(circleNode)
        }
        
        // physics body
        let bodyRadius = height * Geometry.BallPhysicsBodyRelativeRadius
        physicsBody = SKPhysicsBody(circleOfRadius: bodyRadius)
        physicsBody!.affectedByGravity = affectedByGravity
        physicsBody!.allowsRotation = true
        physicsBody!.density = Physics.BallDensity
        physicsBody!.linearDamping = Physics.BallLinearDamping
        physicsBody!.categoryBitMask = PhysicsCategory.Ball
        physicsBody!.collisionBitMask = PhysicsCategory.Boundary | PhysicsCategory.MiddleBar | PhysicsCategory.Ring
        physicsBody!.contactTestBitMask = PhysicsCategory.Boundary | PhysicsCategory.MiddleBar | PhysicsCategory.Ring | PhysicsCategory.RingGoal
        
        name = NodeName.Ball
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
