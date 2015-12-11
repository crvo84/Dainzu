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
    
    // margin bars
    private var topBarHeight: CGFloat = 0
    private var bottomBarHeight: CGFloat = 0
    private var verticalMiddleBar: CGFloat = 0
    private var topBarNode: SKSpriteNode?
    private var bottomBarNode: SKSpriteNode?
    private var verticalMiddleBarNode: SKSpriteNode?

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
    private let barsLayer = SKNode()
    private let initialUI = SKNode()
    private let ringsLayer = SKNode()
    private let ballsLayer = SKNode()
    
    // physics
    private var gravityAdjustedForDevice: CGFloat {
        return Physics.GravityBaseY * (playableRect.height / Geometry.DeviceBaseHeight)
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
            
            playableRectSetup()
            barsSetup() // must be called after playableRectSetup()
            
            if Test.TestModeOn {
                print("Scene width: \(size.width), height: \(size.height)")
            }
            
            backgroundSetup()
            worldSetup()
            ringsSetup()
            
            contentCreated = true
        }
        
    }
    
    private func playableRectSetup() {
        // playableRect uses all scene width, with a constant ratio to define height
        let playableRectSize = CGSize(width: size.width, height: size.width / Geometry.PlayableRectRatio)
        
        // height left after playableRect and bannerHeight is left for top and bottom bars
        var availableHeightLeft = size.height - bannerHeight - playableRectSize.height
        
        // top bar is given part (or all) of height left until reaching a limit (rel to playableRect height)
        let topBarHeightLimit = playableRectSize.height * Geometry.TopRelativeHeightAssignedBeforeBottomBar
        topBarHeight = min(availableHeightLeft, topBarHeightLimit)
        
        // the available height left to this point, is divided between top and bottom parts evenly
        availableHeightLeft -= topBarHeight
        topBarHeight += availableHeightLeft/2
        bottomBarHeight += availableHeightLeft/2
        
        // UIView coord system ((0,0) is top left)
        playableRect = CGRect(
            origin: CGPoint(x: 0, y: topBarHeight),
            size: playableRectSize)
    }
    
    // must be called after playableRectSetup()
    private func barsSetup() {
        barsLayer.position = CGPoint(x: 0, y: 0) // bottom-left of screen
        barsLayer.zPosition = ZPosition.BarsLayer
        addChild(barsLayer)
        
        topBarNode = nil
        bottomBarNode = nil
        verticalMiddleBarNode = nil
        
        // bottom bar node
        topBarNode = SKSpriteNode(texture: nil, color: Color.TopBar, size: CGSize(
            width: size.width,
            height: topBarHeight))
        topBarNode!.anchorPoint = CGPoint(x: 0, y: 0)
        topBarNode!.position = CGPoint(x: 0, y: playableRectOriginInScene.y + playableRect.height)
        barsLayer.addChild(topBarNode!)
        
        // top (add bannerHeight to size to show bar color while banner is not shown)
        bottomBarNode = SKSpriteNode(texture: nil, color: Color.BottomBar, size: CGSize(
            width: size.width,
            height: bottomBarHeight + bannerHeight))
        bottomBarNode!.anchorPoint = CGPoint(x: 0, y: 0)
        bottomBarNode!.position = CGPoint(x: 0, y: 0)
        barsLayer.addChild(bottomBarNode!)
        
        // vertical middle
        verticalMiddleBarNode = SKSpriteNode(texture: nil, color: Color.VerticalMiddleBar, size: CGSize(
            width: playableRect.width * Geometry.VerticalMiddleBarRelativeWidth,
            height: playableRect.height))
        verticalMiddleBarNode!.anchorPoint = CGPoint(x: 0.5, y: 0)
        verticalMiddleBarNode!.position = CGPoint(x: playableRect.width/2, y: bannerHeight + bottomBarHeight)
        barsLayer.addChild(verticalMiddleBarNode!)
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
        let verticalRange = ringHeight * Geometry.RingRelativeFloatingVerticalRange
        
        // left ring
        leftRing = RingNode(height: ringHeight, pointToRight: false)
        leftRing.position = CGPoint(x: -ringsSeparation/2 - leftRing.size.width/2, y: 0)
        leftRing.startFloatingAnimation(verticalRange, durationPerCycle: Time.RingFloatingCycle, startUpward: true)
        ringsLayer.addChild(leftRing)
        
        rightRing = RingNode(height: ringHeight, pointToRight: true)
        rightRing.position = CGPoint(x: +ringsSeparation/2 + rightRing.size.width/2, y: 0)
        rightRing.startFloatingAnimation(verticalRange, durationPerCycle: Time.RingFloatingCycle, startUpward: false)
        ringsLayer.addChild(rightRing)
    }
    
    private func generateBalls() {
        ballsLayer.position = playableRectOriginInScene
        ballsLayer.zPosition = ZPosition.BallsLayer
        addChild(ballsLayer)

        let waitAction = SKAction.waitForDuration(Time.BallsWait)
        let createLeftBallAction = SKAction.runBlock {
            self.createNewBall(.Left)
        }
        let createRightBallAction = SKAction.runBlock {
            self.createNewBall(.Right)
        }
        
        let sequenceAction = SKAction.sequence([waitAction, createLeftBallAction, waitAction, createRightBallAction])
        runAction(SKAction.repeatActionForever(sequenceAction))
    }
    
    private func createNewBall(screenSide: ScreenSide) {
        let ballHeight = playableRect.height * Geometry.BallRelativeHeight
        let ballNode = BallNode(texture: nil, height: ballHeight, color: SKColor.whiteColor())
        ballNode.position = self.getBallRandomPosition(ballNode, screenSide: screenSide)
        self.ballsLayer.addChild(ballNode)
        ballNode.physicsBody?.velocity = getBallVelocity(ballNode, screenSide: screenSide)
    }

    private func startGame() {
        gameState = .GameRunning
        leftRing.stopFloatingAnimation()
        rightRing.stopFloatingAnimation()
        leftRing.physicsBody!.dynamic = true
        rightRing.physicsBody!.dynamic = true
        
        generateBalls()
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
            leftRing.physicsBody?.applyImpulse(getRingImpulse(leftRing))
        } else if location.x > size.width/2 {
            rightRing.physicsBody?.applyImpulse(getRingImpulse(rightRing))
        }
    }
    
    // MARK: SKPhysicsContact Delegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        if gameState == .GameRunning {
            let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
            
            if collision == PhysicsCategory.Ball | PhysicsCategory.Ring {
                let ballNode = contact.bodyA.node as? BallNode ?? contact.bodyB.node as! BallNode
                ballNode.affectedByGravity = true
            }
            
            if collision == PhysicsCategory.Ball | PhysicsCategory.Boundary {
                let ballNode = contact.bodyA.node as? BallNode ?? contact.bodyB.node as! BallNode
                ballNode.affectedByGravity = true
            }
        }
    }
    
    // MARK: Helper functions
    
    private func getRingImpulse(ringNode: RingNode) -> CGVector {
        let impulse = CGVector(
            dx: 0,
            dy: ringNode.physicsBody!.mass * playableRect.height * Physics.RingImpulseMultiplier)
        
        if ringNode.physicsBody!.velocity.dy < 0 {
            ringNode.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        }
        return impulse
    }
    
    private func getBallVelocity(ballNode: BallNode, screenSide: ScreenSide) -> CGVector {
        let dx = playableRect.width * Physics.BallImpulseMultiplier
        return CGVector(
            dx: screenSide == .Left ? +dx : -dx,
            dy: 0)
    }

    private func getBallRandomPosition(ballNode: BallNode, screenSide: ScreenSide) -> CGPoint {
        let minY = UInt32(ballNode.size.height/2)
        let maxY = UInt32(playableRect.height - ballNode.size.height/2)

        return CGPoint(
//            x: screenSide == .Left ? -ballNode.size.width/2 : playableRect.width + ballNode.size.width/2,
            x: screenSide == .Left ? +ballNode.size.width/2 : playableRect.width - ballNode.size.width/2,
            y: CGFloat(arc4random_uniform(maxY - minY) + minY))
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
