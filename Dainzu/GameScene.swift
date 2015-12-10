//
//  GameScene.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/9/15.
//  Copyright (c) 2015 Villou. All rights reserved.
//

import SpriteKit

enum GameState {
    case GameWaitingToStart, GameRunning, GamePaused, GameOver, GamePreview
}

enum ScreenSide {
    case Left, Right
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // -------------- Instance variables -------------------//
    private var contentCreated = false
    private let bannerHeight: CGFloat
    
    private var gameState: GameState = .GameWaitingToStart
    
    // playableRect
    private var playableRect: CGRect!
    private var playableRectOriginInScene: CGPoint {
        // TODO: check again
        return CGPoint(
            x: playableRect.origin.x,
            y: size.height - playableRect.origin.y - playableRect.height)
    }
    
    // rings
    private var leftRing: RingNode!
    private var rightRing: RingNode!
    
    // layers
    private let ringsLayer = SKNode()
    
    // physics
    private var gravityAdjustedForDevice: CGFloat {
        return Physics.GravityBaseY * (playableRect.height / Geometry.PlayableRectBaseHeight)
    }
    
    // -----------------------------------------------------//
    
    
    // MARK: Initialization
    init(size: CGSize, bannerHeight: CGFloat)
    {
        self.bannerHeight = bannerHeight
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Game Setup
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        if !contentCreated {
            
            playableRect = CGRect(
                origin: CGPoint(x: 0, y: 0), // origin on UIView coord system (0, 0) is top left
                size: CGSize(width: size.width, height: size.height - bannerHeight))
            
            if Test.TestModeOn {
                print("Scene width: \(size.width), height: \(size.height)")
            }
            
            backgroundSetup()
            worldSetup()
            ringsSetup()
            
            contentCreated = true
        }
        
    }
    
    private func backgroundSetup() {
        // TODO: add background image instead
        backgroundColor = SKColor(red: 0.0, green: 0.0, blue: 0.2, alpha: 1.0)
    }
    
    private func worldSetup()
    {
        physicsWorld.contactDelegate = self
        
        physicsWorld.gravity = CGVector(dx: 0, dy: gravityAdjustedForDevice)
        
        // playableRect translated to scene coord system
        let edgeRect = CGRect(
            x: playableRectOriginInScene.x,
            y: playableRectOriginInScene.y,
            width: playableRect.width,
            height: playableRect.height)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: edgeRect)
        physicsBody!.categoryBitMask = PhysicsCategory.Boundary
        physicsBody!.contactTestBitMask = PhysicsCategory.Ring
        physicsBody!.collisionBitMask = PhysicsCategory.Ring
    }
    
    private func ringsSetup() {
        ringsLayer.zPosition = ZPosition.RingsLayer
        ringsLayer.position = CGPoint(
            x: playableRectOriginInScene.x + playableRect.width/2,
            y: playableRectOriginInScene.y + playableRect.height/2)
        addChild(ringsLayer)
        
        let ringHeight = playableRect.height * Geometry.RingRelativeHeight
        let ringsSeparation = playableRect.width * Geometry.RingsRelativeSeparation
        let floatingVerticalRange = ringHeight * Geometry.RingRelativeFloatingVerticalRange
        
        // left ring
        leftRing = RingNode(height: ringHeight, pointToRight: false)
        leftRing.position = CGPoint(x: -ringsSeparation/2 - leftRing.size.width/2, y: 0)
        leftRing.startFloatingAnimation(floatingVerticalRange, durationPerCycle: Time.RingFloatingCycle)
        ringsLayer.addChild(leftRing)
        
        rightRing = RingNode(height: ringHeight, pointToRight: true)
        rightRing.position = CGPoint(x: +ringsSeparation/2 + rightRing.size.width/2, y: 0)
        rightRing.startFloatingAnimation(floatingVerticalRange, durationPerCycle: Time.RingFloatingCycle)
        ringsLayer.addChild(rightRing)
        
    }

    private func startGame() {
        gameState = .GameRunning
        leftRing.stopFloatingAnimation()
        rightRing.stopFloatingAnimation()
        leftRing.physicsBody!.dynamic = true
        rightRing.physicsBody!.dynamic = true
    }
    
    // MARK: User interaction
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInNode(self)
//        let touchedNode = self.nodeAtPoint(location)
        
        if gameState == .GameWaitingToStart {
            startGame()
        }

        if location.x < size.width/2 {
            applyImpulseToRing(leftRing)
        } else if location.x > size.width/2 {
            applyImpulseToRing(rightRing)
        }

    }
    
    // MARK: Helper functions
    
    private func applyImpulseToRing(ringNode: RingNode) {
//        var jumpHeight = Geometry.PlayerJumpRelHeight * playableRect.height
//        if !isjumpingWithRotation {
//            jumpHeight *= playerNode.physicsBody!.mass * Geometry.PlayerJumpAdjustingFactor
//        }
        let impulse = CGVector(
            dx: 0,
            dy: ringNode.physicsBody!.mass * playableRect.height * Physics.RingImpulseMultiplier)
        
        if ringNode.physicsBody!.velocity.dy < 0 {
            ringNode.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        }
        ringNode.physicsBody!.applyImpulse(impulse)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
