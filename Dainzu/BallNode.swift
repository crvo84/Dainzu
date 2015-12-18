//
//  BallNode.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/11/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import SpriteKit

class BallNode: SKSpriteNode {
    
    var isSpecial = false
    
    private var circleNode: SKShapeNode?
    
    var ballColor: SKColor? {
        didSet {
            if ballColor != nil {
                circleNode?.fillColor = ballColor!
            }
        }
    }
    
    var affectedByGravity = false {
        didSet {
            removeAllActions()
            physicsBody?.affectedByGravity = affectedByGravity
        }
    }

    init(texture: SKTexture?, height: CGFloat, color: SKColor?) {
        ballColor = color
        
        let nodeRatio = texture != nil ? texture!.size().width / texture!.size().height : 1.0
        let nodeSize = CGSize(width: height * nodeRatio, height: height)
        
        super.init(texture: texture, color: SKColor.clearColor(), size: nodeSize)
        
        // if no given texture, add circle node
        if texture == nil && color != nil {
            circleNode = SKShapeNode(circleOfRadius: height/2)
            circleNode!.fillColor = color!
            circleNode!.strokeColor = color!
            circleNode!.lineWidth = 0
            addChild(circleNode!)
        }
        
        // physics body
        let bodyRadius = height * Geometry.BallPhysicsBodyRelativeRadius
        physicsBody = SKPhysicsBody(circleOfRadius: bodyRadius)
        physicsBody!.affectedByGravity = affectedByGravity
        physicsBody!.allowsRotation = true 
        physicsBody!.density = Physics.BallDensity
        physicsBody!.restitution = Physics.BallBounciness
        physicsBody!.linearDamping = Physics.BallLinearDamping
        physicsBody!.categoryBitMask = PhysicsCategory.Ball
        physicsBody!.collisionBitMask = PhysicsCategory.Boundary | PhysicsCategory.MiddleBar | PhysicsCategory.Ring | PhysicsCategory.Ball
        physicsBody!.contactTestBitMask = PhysicsCategory.Boundary | PhysicsCategory.MiddleBar | PhysicsCategory.Ring | PhysicsCategory.RingGoal
        
        name = NodeName.Ball
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
