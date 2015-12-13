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
    
    // colors
    private var darkColorsOn: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.DarkColorsOn)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: UserDefaultsKey.DarkColorsOn)
            updateColors()
        }
    }
    
    // gravity
    private var gravityNormal: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.GravityNormal)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: UserDefaultsKey.GravityNormal)
            updateGravity()
        }
    }
    
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
    
    // balls
    private var ballHeight: CGFloat {
        return playableRect.height * Geometry.BallRelativeHeight
    }
    
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
            
            if Test.TestModeOn {
                print("Scene width: \(size.width), height: \(size.height)")
            }
            
            physicsWorld.contactDelegate = self
            
            playableRectSetup()
            barsSetup() // must be called after playableRectSetup()
            ringsSetup()
            
            updateGravity()
            updateColors()
            
            testButtonSetup()
            
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
        bottomBarHeight += bannerHeight + availableHeightLeft/2 // banner height is now considered into bottomBarHeight
        
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
        
        // BOTTOM bar node
        let topBarColor = darkColorsOn ? Color.TopBarDark : Color.TopBarLight
        topBarNode = SKSpriteNode(texture: nil, color: topBarColor, size: CGSize(
            width: size.width,
            height: topBarHeight))
        topBarNode!.position = CGPoint(
            x: size.width/2,
            y: playableRectOriginInScene.y + playableRect.height + topBarHeight/2)
        // physics body
        topBarNode!.physicsBody = SKPhysicsBody(rectangleOfSize: topBarNode!.size)
        topBarNode!.physicsBody!.dynamic = false
        topBarNode!.physicsBody!.categoryBitMask = PhysicsCategory.Boundary
        barsLayer.addChild(topBarNode!)
        
        // TOP (add bannerHeight to size to show bar color while banner is not shown)
        let bottomBarColor = darkColorsOn ? Color.BottomBarDark : Color.BottomBarLight
        bottomBarNode = SKSpriteNode(texture: nil, color: bottomBarColor, size: CGSize(
            width: size.width,
            height: bottomBarHeight))
        bottomBarNode!.position = CGPoint(x: size.width/2, y: bottomBarHeight/2)
        // physics body
        bottomBarNode!.physicsBody = SKPhysicsBody(rectangleOfSize: bottomBarNode!.size)
        bottomBarNode!.physicsBody!.dynamic = false
        bottomBarNode!.physicsBody!.categoryBitMask = PhysicsCategory.Boundary
        barsLayer.addChild(bottomBarNode!)
        
        // VERTICAL MIDDLE
        let verticalMiddleBarColor = darkColorsOn ? Color.VerticalMiddleBarDark : Color.VerticalMiddleBarLight
        verticalMiddleBarNode = SKSpriteNode(texture: nil, color: verticalMiddleBarColor, size: CGSize(
            width: playableRect.width * Geometry.VerticalMiddleBarRelativeWidth,
            height: playableRect.height))
        verticalMiddleBarNode!.position = CGPoint(
            x: playableRect.width/2,
            y: bottomBarHeight + playableRect.height/2)
        // physics body
        verticalMiddleBarNode!.physicsBody = SKPhysicsBody(rectangleOfSize: verticalMiddleBarNode!.size)
        verticalMiddleBarNode!.physicsBody!.dynamic = false
        verticalMiddleBarNode!.physicsBody!.categoryBitMask = PhysicsCategory.MiddleBar
        barsLayer.addChild(verticalMiddleBarNode!)
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
        
        let ringColor = darkColorsOn ? Color.RingDark : Color.RingLight
        
        // LEFT RING
        leftRing = RingNode(height: ringHeight, ringColor: ringColor, pointToRight: false)
        leftRing.position = CGPoint(x: -ringsSeparation/2 - leftRing.size.width/2, y: 0)
        leftRing.startFloatingAnimation(verticalRange, durationPerCycle: Time.RingFloatingCycle, startUpward: true)
        ringsLayer.addChild(leftRing)
        
        // RIGHT RING
        rightRing = RingNode(height: ringHeight, ringColor: ringColor, pointToRight: true)
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
        let ballNode = BallNode(texture: nil, height: ballHeight, color: darkColorsOn ? Color.BallDark : Color.BallLight)
        ballNode.position = self.getBallRandomPosition(ballNode, screenSide: screenSide)
        ballsLayer.addChild(ballNode)
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
    
    // MARK: Update methods
    
    private func updateColors() {
        let dark = darkColorsOn
        // background
        backgroundColor = dark ? Color.BackgroundDark : Color.BackgroundLight
        // bars
        topBarNode?.color = dark ? Color.TopBarDark : Color.TopBarLight
        bottomBarNode?.color = dark ? Color.BottomBarDark : Color.BottomBarLight
        verticalMiddleBarNode?.color = dark ? Color.VerticalMiddleBarDark : Color.VerticalMiddleBarLight
        // rings
        leftRing.ringColor = dark ? Color.RingDark : Color.RingLight
        rightRing.ringColor = dark ? Color.RingDark : Color.RingLight
        // balls
        ballsLayer.enumerateChildNodesWithName(NodeName.Ball) {
            node, stop in
            if let ballNode = node as? BallNode {
                ballNode.ballColor = dark ? Color.BallDark : Color.BallLight
            }
        }
        // TODO: score and money labels
    }
    
    private func updateGravity() {
        if rightRing != nil {
            rightRing.gravityNormal = gravityNormal
        }
        
        if leftRing != nil {
            leftRing.gravityNormal = gravityNormal
        }
        
        let yGravity = gravityNormal ? gravityAdjustedForDevice : -gravityAdjustedForDevice
        physicsWorld.gravity = CGVector(dx: 0, dy: yGravity)
    }
    
    
    
    // MARK: User interaction
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let location = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location)
        
        if let nodeName = touchedNode.name {
            switch nodeName {
            case NodeName.TestButton:
                darkColorsOn = !darkColorsOn
                gravityNormal = !gravityNormal
            default:
                break
            }
        }
        
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
            
            if let ballNode = contact.bodyA.node as? BallNode ?? (contact.bodyB.node as? BallNode ?? nil) {
                
                if collision == PhysicsCategory.Ball | PhysicsCategory.Ring {
                    ballNode.affectedByGravity = true
                    
                } else if collision == PhysicsCategory.Ball | PhysicsCategory.MiddleBar {
                    ballNode.removeFromParent()
                    
                } else if collision == PhysicsCategory.Ball | PhysicsCategory.Boundary {
                    ballNode.runAction(SKAction.fadeOutWithDuration(Time.BallFadeOut)) {
                        ballNode.removeFromParent()
                    }
                }
            }
        }
    }
    
    // MARK: Helper functions
    
    private func getRingImpulse(ringNode: RingNode) -> CGVector {
        let yNormalImpulse = ringNode.physicsBody!.mass * playableRect.height * Physics.RingImpulseMultiplier
        let impulse = CGVector(
            dx: 0,
            dy: gravityNormal ? yNormalImpulse : -yNormalImpulse)
        
        if let vel = ringNode.physicsBody?.velocity.dy {
            if  (gravityNormal && vel < 0) || (!gravityNormal && vel > 0) {
                ringNode.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            }
        }

        return impulse
    }
    
    private func getBallVelocity(ballNode: BallNode, screenSide: ScreenSide) -> CGVector {
        let dx = playableRect.width * Physics.BallVelocityMultiplier
        return CGVector(
            dx: screenSide == .Left ? +dx : -dx,
            dy: 0)
    }

    private func getBallRandomPosition(ballNode: BallNode, screenSide: ScreenSide) -> CGPoint {
        let minY = UInt32(ballNode.size.height)
        let maxY = UInt32(playableRect.height - ballNode.size.height)

        return CGPoint(
            x: screenSide == .Left ? -ballNode.size.width/2 : playableRect.width + ballNode.size.width/2,
//            x: screenSide == .Left ? +ballNode.size.width/2 : playableRect.width - ballNode.size.width/2,
            y: CGFloat(arc4random_uniform(maxY - minY) + minY))
    }
    
    
    
    

    
    
    // MARK: TEST
    
    private func testButtonSetup() {
        let side = topBarHeight * 2
        let offset: CGFloat = 8
        let testButton = SKSpriteNode(texture: nil, color: SKColor.grayColor(), size: CGSize(
            width: side,
            height: side))
        testButton.zPosition = 1000
        testButton.anchorPoint = CGPoint(x: 0, y: 1)
        testButton.position = CGPoint(x: offset, y: size.height - offset)
        testButton.name = NodeName.TestButton
        addChild(testButton)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
