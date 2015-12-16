//
//  GameScene.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/9/15.
//  Copyright (c) 2015 Villou. All rights reserved.
//

import SpriteKit

enum GameState {
    case GameMenu, GameRunning, GamePaused, GameOver
}

enum ScreenSide {
    case Left, Right
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // -------------- Instance variables -------------------//
    weak var viewController: UIViewController?
    private var contentCreated = false
    private let bannerHeight: CGFloat
    
    private var gameState: GameState = .GameMenu {
        didSet {
            updateShownLayers()
        }
    }
    
    // iAd
    private var showAds: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.ShowAds)
    }
    
    // music
    private var isMusicOn: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.MusicOn)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: UserDefaultsKey.MusicOn)
            // TODO: update music config
        }
    }
    
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
    
    // game menu
    private var mainTitleLabel: SKLabelNode?
    private var playButtonNode: SKSpriteNode?
    private var darkColorsButtonNode: SKSpriteNode?
    private var gravityNormalButtonNode: SKSpriteNode?
    private var musicOnButtonNode: SKSpriteNode?
    private var removeAdsButtonNode: SKSpriteNode?
    
    // pause
    private var pauseButtonNode: SKSpriteNode?
    private var pauseNode: PauseNode?
    
    // margin bars
    private var topBarHeight: CGFloat = 0
    private var bottomBarHeight: CGFloat = 0
    private var verticalMiddleBar: CGFloat = 0
    private var topBarNode: SKSpriteNode?
    private var bottomBarNode: SKSpriteNode?
    private var verticalMiddleBarNode: SKSpriteNode?
    
    // score
    private var scoreLabel: SKLabelNode?
    private var score: Int = 0 {
        didSet {
            // TODO: size or glow effect
            scoreLabel?.text = "\(score)"
        }
    }
    private var bestScoreLabel: SKLabelNode?
    private var bestScore: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey(UserDefaultsKey.BestScore)
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: UserDefaultsKey.BestScore)
            bestScoreLabel?.text = Text.BestScore + ": \(newValue)"
        }
    }
    
    // coins
    private var coinNode: BallNode?
    private var coinsLabel: SKLabelNode?
    private var coinsCount: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey(UserDefaultsKey.CoinsCount)
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: UserDefaultsKey.CoinsCount)
            coinsLabel?.text = "\(newValue)"
        }
    }
    private var coinNodeFlashAction: SKAction?
    private var coinsLabelFlashAction: SKAction?

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
    private let alwaysVisibleUILayer = SKNode()
    private let gameOnlyUILayer = SKNode()
    private let menuOnlyUILayer = SKNode()
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
        view.multipleTouchEnabled = true
        
        /* Setup your scene here */
        if !contentCreated {
            
            registerAppTransitionObservers()
            
            if Test.TestModeOn {
                print("Scene width: \(size.width), height: \(size.height)")
            }
            
            physicsWorld.contactDelegate = self
            
            playableRectSetup()
            barsSetup() // call after playableRectSetup()
            
            alwaysVisibleUISetup() // call after barsSetup()
            menuOnlyUISetup() // call after barsSetup()
            gameOnlyUISetup() // call after barsSetup()
            adjustLabelsSize()
            
            ringsSetup()
            
            contentCreated = true
        }
        
        updateShownLayers()
        updateGravity()
        updateColors()
        
        if let gameViewController = viewController as? GameViewController {
            gameViewController.requestInterstitialAdIfNeeded()
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
        topBarNode!.name = NodeName.Boundary
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
        bottomBarNode!.name = NodeName.Boundary
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
        verticalMiddleBarNode!.name = NodeName.Boundary
        barsLayer.addChild(verticalMiddleBarNode!)
    }
    
    private func menuOnlyUISetup() {
        menuOnlyUILayer.zPosition = ZPosition.MenuOnlyUILayer
        menuOnlyUILayer.position = CGPoint(
            x: playableRectOriginInScene.x + playableRect.width/2,
            y: playableRectOriginInScene.y + playableRect.height/2)
        addChild(menuOnlyUILayer)
        
        // main title label
        let mainTitleHeight = playableRect.height * Geometry.MainTitleRelativeHeight
        let mainTitleWidth = (playableRect.width - verticalMiddleBarNode!.size.width)/2 * Geometry.MainTitleRelativeWidth
        mainTitleLabel = SKLabelNode(text: Text.MainTitle)
        mainTitleLabel!.verticalAlignmentMode = .Center
        mainTitleLabel!.horizontalAlignmentMode = .Center
        mainTitleLabel!.fontName = FontName.MainTitle
        mainTitleLabel!.fontColor = darkColorsOn ? FontColor.MainTitleDark : FontColor.MainTitleLight
        adjustFontSizeForLabel(mainTitleLabel!, tofitSize: CGSize(width: mainTitleWidth, height: mainTitleHeight))
        mainTitleLabel!.position = CGPoint(
            x: -(playableRect.width - verticalMiddleBarNode!.size.width)/4 - verticalMiddleBarNode!.size.width/2,
            y: playableRect.height * Geometry.MainTitleRelativeYPosition - playableRect.height/2)
        mainTitleLabel!.name = NodeName.MainTitleLabel
        menuOnlyUILayer.addChild(mainTitleLabel!)
        
        // play button node
        playButtonNode = SKSpriteNode(imageNamed: ImageFilename.PlayButton)
        let playButtonRatio = playButtonNode!.size.width / playButtonNode!.size.height
        let playButtonHeight = playableRect.height * Geometry.PlayButtonRelativeHeight
        playButtonNode!.size = CGSize(
            width: playButtonHeight * playButtonRatio,
            height: playButtonHeight)
        let heightAvailableForPlayButton = playableRect.height/2 + mainTitleLabel!.position.y - mainTitleLabel!.frame.size.height/2
        playButtonNode!.position = CGPoint(
            x: mainTitleLabel!.position.x,
            y: -playableRect.height/2 + heightAvailableForPlayButton/2)
        playButtonNode!.name = NodeName.PlayButton
        playButtonNode!.color = darkColorsOn ? Color.PlayButtonDark : Color.PlayButtonLight
        playButtonNode!.colorBlendFactor = Color.PlayButtonBlendFactor
        menuOnlyUILayer.addChild(playButtonNode!)
        
        // best label
        let bestScoreLabelHeight = topBarHeight * Geometry.BestScoreLabelRelativeHeight
        let bestScoreLabelWidth = playableRect.width * Geometry.BestScoreLabelRelativeWidth
        bestScoreLabel = SKLabelNode(text: Text.BestScore + ": \(bestScore)")
        bestScoreLabel!.verticalAlignmentMode = .Center
        bestScoreLabel!.horizontalAlignmentMode = .Center
        bestScoreLabel!.fontName = FontName.BestScore
        bestScoreLabel!.fontColor = darkColorsOn ? FontColor.BestScoreDark : FontColor.BestScoreLight
        adjustFontSizeForLabel(bestScoreLabel!, tofitSize: CGSize(
            width: bestScoreLabelWidth,
            height: bestScoreLabelHeight))
        bestScoreLabel!.position = CGPoint(x: 0, y: +playableRect.height/2 + topBarHeight/2)
        bestScoreLabel!.name = NodeName.BestScoreLabel
        menuOnlyUILayer.addChild(bestScoreLabel!)
        
        let configButtonHeight = mainTitleLabel!.frame.size.height * Geometry.ConfigButtonRelativeHeight
        let configButtonY = mainTitleLabel!.position.y
        let configButtonSeparation = (playableRect.width - verticalMiddleBarNode!.size.width)/2 * 1/4
        let firstConfigButtonX = verticalMiddleBarNode!.size.width/2 + configButtonSeparation
        
        // dark colors button
        darkColorsButtonNode = SKSpriteNode(imageNamed: darkColorsOn ? ImageFilename.DarkColorsOn : ImageFilename.DarkColorsOff)
        let darkColorsButtonRatio = darkColorsButtonNode!.size.width / darkColorsButtonNode!.size.height
        darkColorsButtonNode!.size = CGSize(width: darkColorsButtonRatio * configButtonHeight, height: configButtonHeight)
        darkColorsButtonNode!.position = CGPoint(
            x: firstConfigButtonX,
            y: configButtonY)
        darkColorsButtonNode!.color = darkColorsOn ? Color.ConfigButtonDark : Color.ConfigButtonLight
        darkColorsButtonNode!.colorBlendFactor = Color.ConfigButtonBlendFactor
        darkColorsButtonNode!.name = NodeName.DarkColorsOnOffButton
        menuOnlyUILayer.addChild(darkColorsButtonNode!)
        
        // music on button
        musicOnButtonNode = SKSpriteNode(imageNamed: ImageFilename.MusicOnButton)
        let musicOnButtonRatio = musicOnButtonNode!.size.width / musicOnButtonNode!.size.height
        musicOnButtonNode!.size = CGSize(width: musicOnButtonRatio * configButtonHeight, height: configButtonHeight)
        musicOnButtonNode!.position = CGPoint(
            x: firstConfigButtonX + configButtonSeparation,
            y: configButtonY)
        musicOnButtonNode!.color = darkColorsOn ? Color.ConfigButtonDark : Color.ConfigButtonLight
        musicOnButtonNode!.colorBlendFactor = Color.ConfigButtonBlendFactor
        musicOnButtonNode!.name = NodeName.MusicOnOffButton
        menuOnlyUILayer.addChild(musicOnButtonNode!)
        
        // gravity normal button
        gravityNormalButtonNode = SKSpriteNode(imageNamed: gravityNormal ? ImageFilename.GravityNormalOn : ImageFilename.GravityNormalOff)
        let gravityNormalButtonRatio = gravityNormalButtonNode!.size.width / gravityNormalButtonNode!.size.height
        gravityNormalButtonNode!.size = CGSize(width: gravityNormalButtonRatio * configButtonHeight, height: configButtonHeight)
        gravityNormalButtonNode!.position = CGPoint(
            x: firstConfigButtonX + configButtonSeparation * 2,
            y: configButtonY)
        gravityNormalButtonNode!.color = darkColorsOn ? Color.ConfigButtonDark : Color.ConfigButtonLight
        gravityNormalButtonNode!.colorBlendFactor = Color.ConfigButtonBlendFactor
        gravityNormalButtonNode!.name = NodeName.GravityNormalOnOffButton
        menuOnlyUILayer.addChild(gravityNormalButtonNode!)
        
        // remove ads button
        if showAds {
            removeAdsButtonNode = SKSpriteNode(imageNamed: ImageFilename.RemoveAdsButton)
            let removeAdsButtonRatio = removeAdsButtonNode!.size.width / removeAdsButtonNode!.size.height
            removeAdsButtonNode!.size = CGSize(width: removeAdsButtonRatio * configButtonHeight, height: configButtonHeight)
            removeAdsButtonNode!.position = CGPoint(
                x: firstConfigButtonX,
                y: -configButtonY)
            removeAdsButtonNode!.color = darkColorsOn ? Color.ConfigButtonDark : Color.ConfigButtonLight
            removeAdsButtonNode!.colorBlendFactor = Color.ConfigButtonBlendFactor
            removeAdsButtonNode!.name = NodeName.RemoveAdsButton
            menuOnlyUILayer.addChild(removeAdsButtonNode!)
        }

    }
    
    private func gameOnlyUISetup() {
        gameOnlyUILayer.zPosition = ZPosition.GameOnlyUILayer
        gameOnlyUILayer.position = CGPoint(
            x: playableRectOriginInScene.x + playableRect.width/2,
            y: playableRectOriginInScene.y + playableRect.height/2)
        addChild(gameOnlyUILayer)
        
        // score label
        let scoreLabelHeight = topBarHeight * Geometry.ScoreLabelRelativeHeight
        let scoreLabelWidth = playableRect.width * Geometry.ScoreLabelRelativeWidth
        scoreLabel = SKLabelNode(text: "0")
        scoreLabel!.verticalAlignmentMode = .Center
        scoreLabel!.horizontalAlignmentMode = .Center
        scoreLabel!.fontName = FontName.Score
        scoreLabel!.fontColor = darkColorsOn ? FontColor.ScoreDark : FontColor.ScoreLight
        adjustFontSizeForLabel(scoreLabel!, tofitSize: CGSize(width: scoreLabelWidth, height: scoreLabelHeight))
        scoreLabel!.position = CGPoint(x: 0, y: +playableRect.height/2 + topBarHeight/2)
        gameOnlyUILayer.addChild(scoreLabel!)
        
        // pause button node
        pauseButtonNode = SKSpriteNode(imageNamed: ImageFilename.PauseButton)
        let pauseButtonRatio = pauseButtonNode!.size.width / pauseButtonNode!.size.height
        let pauseButtonHeight = topBarHeight * Geometry.PauseButtonRelativeHeight
        pauseButtonNode!.size = CGSize(width: pauseButtonHeight * pauseButtonRatio, height: pauseButtonHeight)
        pauseButtonNode!.position = CGPoint(
            x: -playableRect.width/2 + playableRect.width * Geometry.PauseButtonRelativeSideOffset + pauseButtonNode!.size.width/2,
            y: +playableRect.height/2 + topBarHeight / 2)
        pauseButtonNode!.name = NodeName.PauseButton
        pauseButtonNode!.color = darkColorsOn ? Color.PauseButtonDark : Color.PauseButtonLight
        pauseButtonNode!.colorBlendFactor = Color.PauseButtonBlendFactor
        gameOnlyUILayer.addChild(pauseButtonNode!)
    }
    
    private func alwaysVisibleUISetup() {
        alwaysVisibleUILayer.zPosition = ZPosition.AlwaysVisibleUILayer
        alwaysVisibleUILayer.position = CGPoint(
            x: playableRectOriginInScene.x + playableRect.width/2,
            y: playableRectOriginInScene.y + playableRect.height/2)
        addChild(alwaysVisibleUILayer)
        
        // coin node
        let coinNodeHeight = topBarHeight * Geometry.CoinNodeRelativeHeight
        coinNode = BallNode(texture: nil, height: coinNodeHeight, color: Color.BallSpecial)
        coinNode!.physicsBody?.dynamic = false
        coinNode!.position = CGPoint(
            x: playableRect.width/2 - coinNode!.size.width/2 - playableRect.width * Geometry.CoinNodeRelativeSideOffset,
            y: playableRect.height/2 + topBarHeight/2)
        alwaysVisibleUILayer.addChild(coinNode!)
        
        // coins label
        let coinsLabelHeight = topBarHeight * Geometry.CoinsLabelRelativeHeight
        let coinsLabelWidth = playableRect.width * Geometry.CoinsLabelRelativeWidth
        coinsLabel = SKLabelNode(text: "\(coinsCount)")
        coinsLabel!.fontColor = darkColorsOn ? FontColor.CoinsDark : FontColor.CoinsLight
        coinsLabel!.fontName = FontName.Coins
        adjustFontSizeForLabel(coinsLabel!, tofitSize: CGSize(width: coinsLabelWidth, height: coinsLabelHeight))
        coinsLabel!.verticalAlignmentMode = .Center
        coinsLabel!.horizontalAlignmentMode = .Right
        coinsLabel!.position = CGPoint(
            x: coinNode!.position.x - coinNode!.size.width/2 - coinNode!.size.width * Geometry.CoinsLabelRelativeSideOffset,
            y: playableRect.height/2 + topBarHeight/2)
        alwaysVisibleUILayer.addChild(coinsLabel!)
        
        let coinsLabelFlash = SKAction.scaleTo(Geometry.CoinsLabelFlashActionMaxScale, duration: Time.CoinsLabelFlashAction/2)
        let coinsLabelFlashReverse = SKAction.scaleTo(1.0, duration: Time.CoinsLabelFlashAction/2)
        coinsLabelFlashAction = SKAction.sequence([coinsLabelFlash, coinsLabelFlashReverse])
        let coinNodeFlash = SKAction.scaleTo(Geometry.CoinsLabelFlashActionMaxScale, duration: Time.CoinsLabelFlashAction/2)
        let coinNodeFlashReverse = SKAction.scaleTo(1.0, duration: Time.CoinsLabelFlashAction/2)
        coinNodeFlashAction = SKAction.sequence([coinNodeFlash, coinNodeFlashReverse])
    }
    
    private func ringsSetup() {
        ringsLayer.zPosition = ZPosition.RingsLayer
        ringsLayer.position = CGPoint(
            x: playableRectOriginInScene.x + playableRect.width/2,
            y: playableRectOriginInScene.y + playableRect.height/2)
        addChild(ringsLayer)
        
        let ringHeight = playableRect.height * Geometry.RingRelativeHeight
        let ringSize = CGSize(
            width: ringHeight * Geometry.RingRatio,
            height: ringHeight)
        let ringsSeparation = playableRect.width * Geometry.RingsRelativeSeparation
        let verticalRange = ringHeight * Geometry.RingRelativeFloatingVerticalRange
        
        let ringColor = darkColorsOn ? Color.RingDark : Color.RingLight
        
        // LEFT RING
        leftRing = RingNode(size: ringSize, color: ringColor, pointToRight: false)
        leftRing.position = CGPoint(x: -ringsSeparation/2 - abs(leftRing.size.width)/2, y: 0)
        leftRing.startFloatingAnimation(verticalRange, durationPerCycle: Time.RingFloatingCycle, startUpward: true)
        ringsLayer.addChild(leftRing)
        // left ring goal node
        let leftRingGoal = getRingGoalForRing(leftRing)
        leftRingGoal.position = CGPoint(x: -ballHeight * Geometry.RingGoalRelativeLengthToCountPoint, y: 0)
        leftRing.addChild(leftRingGoal)

        // left ring joint
        let leftRingJoint = SKPhysicsJointFixed.jointWithBodyA(leftRingGoal.physicsBody!, bodyB: leftRing.physicsBody!, anchor: self.convertPoint(leftRingGoal.position, fromNode: leftRingGoal))
        physicsWorld.addJoint(leftRingJoint)
        
        // RIGHT RING
        rightRing = RingNode(size: ringSize, color: ringColor, pointToRight: true)
        rightRing.position = CGPoint(x: +ringsSeparation/2 + abs(rightRing.size.width)/2, y: 0)
        rightRing.startFloatingAnimation(verticalRange, durationPerCycle: Time.RingFloatingCycle, startUpward: false)
        ringsLayer.addChild(rightRing)
        // right ring goal node
        let rightRingGoal = getRingGoalForRing(rightRing)
        rightRingGoal.position = CGPoint(x: -ballHeight * Geometry.RingGoalRelativeLengthToCountPoint, y: 0)
        rightRing.addChild(rightRingGoal)

        // right ring joint
        let rightRingJoint = SKPhysicsJointFixed.jointWithBodyA(rightRingGoal.physicsBody!, bodyB: rightRing.physicsBody!, anchor: self.convertPoint(rightRingGoal.position, fromNode: rightRingGoal))
        physicsWorld.addJoint(rightRingJoint)
    }
    
    private func generateBalls() {
        ballsLayer.position = playableRectOriginInScene
        ballsLayer.zPosition = ZPosition.BallsLayer
        addChild(ballsLayer)

        let waitAction = SKAction.waitForDuration(Time.BallsWait)
        
        let createBallsAction = SKAction.runBlock {
            self.createNewBall(.Left)
            self.createNewBall(.Right)
        }
        let sequenceAction = SKAction.sequence([createBallsAction, waitAction])
        runAction(SKAction.repeatActionForever(sequenceAction), withKey: ActionKey.BallsGeneration)
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
    
    private func updateShownLayers() {
        switch gameState {
        case .GameMenu:
            gameOnlyUILayer.hidden = true
            menuOnlyUILayer.hidden = false
            ballsLayer.hidden = false
            
        case .GameRunning:
            gameOnlyUILayer.hidden = false
            menuOnlyUILayer.hidden = true
            ballsLayer.hidden = false
            
        default:
            break
        }
    }
    
    private func updateColors() {
        let dark = darkColorsOn
        
        // ALWAYS SHOWN
        // background
        backgroundColor = dark ? Color.BackgroundDark : Color.BackgroundLight
        
        // bars
        topBarNode?.color = dark ? Color.TopBarDark : Color.TopBarLight
        bottomBarNode?.color = dark ? Color.BottomBarDark : Color.BottomBarLight
        verticalMiddleBarNode?.color = dark ? Color.VerticalMiddleBarDark : Color.VerticalMiddleBarLight
        
        // rings
        leftRing.color = dark ? Color.RingDark : Color.RingLight
        rightRing.color = dark ? Color.RingDark : Color.RingLight
        
        // coins label
        coinsLabel?.fontColor = dark ? FontColor.CoinsDark : FontColor.CoinsLight
        
        // balls
        ballsLayer.enumerateChildNodesWithName(NodeName.Ball) {
            node, stop in
            if let ballNode = node as? BallNode {
                if ballNode.isSpecial {
                    ballNode.ballColor = Color.BallSpecial
                } else {
                    ballNode.ballColor = dark ? Color.BallDark : Color.BallLight
                }
            }
        }
        
        // GAME MENU
        // main title
        mainTitleLabel?.fontColor = dark ? FontColor.MainTitleDark : FontColor.MainTitleLight
        
        // best score label
        bestScoreLabel?.fontColor = dark ? FontColor.BestScoreDark : FontColor.BestScoreLight
        
        // play button
        playButtonNode?.color = dark ? Color.PlayButtonDark : Color.PlayButtonLight
        
        // config buttons
        darkColorsButtonNode?.color = dark ? Color.ConfigButtonDark : Color.ConfigButtonLight
        musicOnButtonNode?.color = dark ? Color.ConfigButtonDark : Color.ConfigButtonLight
        gravityNormalButtonNode?.color = dark ? Color.ConfigButtonDark : Color.ConfigButtonLight
        removeAdsButtonNode?.color = dark ? Color.ConfigButtonDark : Color.ConfigButtonLight
        
        // GAME RUNNING
        // score label
        scoreLabel?.fontColor = dark ? FontColor.ScoreDark : FontColor.ScoreLight
        
        // pause button
        pauseButtonNode?.color = dark ? Color.PauseButtonDark : Color.PauseButtonLight
        
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
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if gameState == .GameMenu || gameState == .GamePaused {
            let touch = touches.first!
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
            
            if let nodeName = touchedNode.name {
                switch nodeName {
                    
                case NodeName.PlayButton:
                    startGame()
                    
                case NodeName.QuitButton:
                    startNewGame()
                    
                case NodeName.ContinueButton:
                    unpauseGame()
                    
                case NodeName.DarkColorsOnOffButton:
                    darkColorsOn = !darkColorsOn
                    if let darkColorsNode = touchedNode as? SKSpriteNode {
                        darkColorsNode.texture = SKTexture(imageNamed: darkColorsOn ? ImageFilename.DarkColorsOn : ImageFilename.DarkColorsOff)
                    }
                    
                case NodeName.GravityNormalOnOffButton:
                    gravityNormal = !gravityNormal
                    if let gravityNormalNode = touchedNode as? SKSpriteNode {
                        gravityNormalNode.texture = SKTexture(imageNamed: gravityNormal ? ImageFilename.GravityNormalOn : ImageFilename.GravityNormalOff)
                    }
                    
                case NodeName.MusicOnOffButton:
                    isMusicOn = !isMusicOn
                    if let musicOnOffNode = touchedNode as? SKSpriteNode {
                        musicOnOffNode.texture = SKTexture(imageNamed: isMusicOn ? ImageFilename.MusicOnButton : ImageFilename.MusicOffButton)
                    }
                    
                case NodeName.RemoveAdsButton:
                    removeAdsRequest()
                    
                default:
                    break
                }
            }
            
        } else if gameState == .GameRunning {
            for touch in touches {
                let location = touch.locationInNode(self)
                let touchedNode = self.nodeAtPoint(location)
                
                if let nodeName = touchedNode.name {
                    switch nodeName {
                        
                    case NodeName.PauseButton:
                        pauseGame()
                        
                    default:
                        applyRingImpulse(touchLocation: location)
                    }
                } else {
                    applyRingImpulse(touchLocation: location)
                }
            }
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
                } else if collision == PhysicsCategory.Ball | PhysicsCategory.RingGoal {
                    if ballNode.isSpecial {
                        coinsCount++
                        if coinNodeFlashAction != nil {
                            coinNode?.runAction(coinNodeFlashAction!)
                        }
                        if coinsLabelFlashAction != nil {
                            coinsLabel?.runAction(coinsLabelFlashAction!)
                        }
                    }
                    score++
                }
            }
        }
    }
    
    
    // MARK: Helper functions
    
    
      // ---------------------- //
     // -------- Ring -------- //
    // ---------------------- //
    
    private func applyRingImpulse(touchLocation location: CGPoint) {
        if location.x < size.width/2 {
            leftRing.physicsBody?.applyImpulse(getRingImpulse(leftRing))
        } else if location.x > size.width/2 {
            rightRing.physicsBody?.applyImpulse(getRingImpulse(rightRing))
        }
    }
    
    private func getRingImpulse(ringNode: RingNode) -> CGVector {
        let yNormalImpulse = ringNode.physicsBody!.mass * playableRect.height * Physics.RingImpulseMultiplier
        let impulse = CGVector(
            dx: 0,
            dy: gravityNormal ? yNormalImpulse : -yNormalImpulse)
        
        if GameOption.ResetVelocityBeforeImpulse {
            if let vel = ringNode.physicsBody?.velocity.dy {
                if  (gravityNormal && vel < 0) || (!gravityNormal && vel > 0) {
                    ringNode.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
                }
            }
        }

        return impulse
    }
    
    private func getRingGoalForRing(ring: RingNode) -> SKSpriteNode {
        let ringGoal = SKSpriteNode(texture: nil, color: SKColor.clearColor(), size: CGSize(
            width: 2,
            height: ring.size.height * Geometry.RingGoalRelativeHeight))
        ringGoal.physicsBody = SKPhysicsBody(rectangleOfSize: ringGoal.size)
        ringGoal.physicsBody!.categoryBitMask = PhysicsCategory.RingGoal
        ringGoal.physicsBody!.collisionBitMask = PhysicsCategory.None
        ringGoal.physicsBody!.contactTestBitMask = PhysicsCategory.Ball
        ringGoal.physicsBody!.affectedByGravity = false
        
        return ringGoal
    }
    
    
      // ---------------------- //
     // -------- Ball -------- //
    // ---------------------- //
    
    private func createNewBall(screenSide: ScreenSide) {
        let isSpecial = GameOption.SpecialBallsOn && arc4random_uniform(GameOption.SpecialBallsRatio) == 0
        
        // TODO: choose from available textures
        var ballTexture: SKTexture?
        let ballColor: SKColor
        if isSpecial {
            ballColor = Color.BallSpecial
        } else {
            ballTexture = SKTexture(imageNamed: "tennisBall")
            ballColor = darkColorsOn ? Color.BallDark : Color.BallLight
        }
        
        let ballNode = BallNode(texture: ballTexture, height: ballHeight, color: ballColor)
        ballNode.isSpecial = isSpecial
        ballNode.position = self.getBallRandomPosition(ballNode, screenSide: screenSide)
        ballsLayer.addChild(ballNode)
        ballNode.physicsBody?.velocity = getBallVelocity(ballNode, screenSide: screenSide)
        
        let rotateAction = SKAction.repeatActionForever(SKAction.rotateByAngle(2*π, duration: Time.BallRotate))
        ballNode.runAction(rotateAction, withKey: ActionKey.BallRotate)
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
            y: CGFloat(arc4random_uniform(maxY - minY) + minY))
    }
    
    
      // ------------------------ //
     // -------- Others -------- //
    // ------------------------ //
    
    private func adjustLabelsSize() {
        if mainTitleLabel != nil {
            let maxFontSize = mainTitleLabel!.fontSize
            if scoreLabel != nil {
                scoreLabel!.fontSize = min(scoreLabel!.fontSize, maxFontSize)
            }
            if bestScoreLabel != nil {
                bestScoreLabel!.fontSize = min(bestScoreLabel!.fontSize, maxFontSize)
            }
            if coinsLabel != nil {
                coinsLabel!.fontSize = min(coinsLabel!.fontSize, maxFontSize)
            }
            if pauseButtonNode != nil {
                let pauseButtonRatio = pauseButtonNode!.size.width / pauseButtonNode!.size.height
                let pauseButtonHeight = min(pauseButtonNode!.size.height, mainTitleLabel!.frame.size.height)
                pauseButtonNode!.size = CGSize(
                    width: pauseButtonHeight * pauseButtonRatio,
                    height: pauseButtonHeight)
            }
        }
    }
    
    private func adjustFontSizeForLabel(labelNode: SKLabelNode, tofitSize size: CGSize) {
        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(size.width / labelNode.frame.width, size.height / labelNode.frame.height)
        
        // Set fit font size
        labelNode.fontSize = labelNode.fontSize * scalingFactor
    }

    
    
      // ----------------------------- //
     // ------- MARK: Pausing ------- //
    // ----------------------------- //
    
    func pauseGame() {
        if gameState == .GameRunning {
            gameState = .GamePaused
            paused = true
//            if backgroundMusicPlayer.playing {
//                backgroundMusicPlayer.pause()
//            }
            
            // Display pause screen etc
            if pauseNode == nil {
                pauseButtonNode?.hidden = true
                //                let pauseNodeSize = CGSize(width: size.width, height: size.height - bannerHeight)
                //                let pauseNodePosition = CGPoint(x: size.width / 2.0, y: size.height / 2.0 + bannerHeight / 2.0)
                let pauseNodeSize = CGSize(width: size.width, height: size.height)
                let pauseNodePosition = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
                pauseNode = PauseNode(size: pauseNodeSize, musicOn: isMusicOn, darkColorsOn: darkColorsOn, gravityNormal: gravityNormal)
                pauseNode!.position = pauseNodePosition
                pauseNode!.zPosition = ZPosition.PauseNode
                addChild(pauseNode!)
            }
        }
    }
    
    func unpauseGame() {
        if gameState == .GamePaused
        {
            gameState = .GameRunning
            paused = false
            
//            if isMusicOn {
//                if !backgroundMusicPlayer.playing { backgroundMusicPlayer.play() }
//            }
            
            // Hide pause screen etc
            pauseNode?.removeFromParent()
            pauseNode = nil
            pauseButtonNode?.hidden = false
        }
    }
    
    
    private func registerAppTransitionObservers() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.addObserver(self, selector: "applicationWillResignActive", name:UIApplicationWillResignActiveNotification , object: nil)
        
        notificationCenter.addObserver(self, selector: "applicationDidBecomeActive", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: "applicationDidEnterBackground", name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: "applicationWillEnterForeground", name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
    func applicationWillResignActive() {
        if gameState == .GameRunning { // Pause the game if necessary
            pauseGame()
        }
    }
    
    func applicationDidBecomeActive() {
        self.view?.paused = false // Unpause SKView. This is safe to call even if the view is not paused.
        if gameState == .GamePaused {
            paused = true
        }
    }
    
    func applicationDidEnterBackground() {
//        backgroundMusicPlayer.stop()
        self.view?.paused = true
    }
    
    // Unpausing the view automatically unpauses the scene (and the physics simulation). Therefore, we must manually pause the scene again, if the game is supposed to be in a paused state.
    func applicationWillEnterForeground() {
        self.view?.paused = false //Unpause SKView. This is safe to call even if the view is not paused.
        if gameState == .GamePaused {
            paused = true
        }
    }
    
    // MARK: Deallocation
    
    override func willMoveFromView(view: SKView) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: Navigation
    
    private func startNewGame() {
        // Create and configure new scene
        let newGameScene = GameScene(size: size, bannerHeight: bannerHeight)
        newGameScene.scaleMode = scaleMode
        newGameScene.viewController = viewController
        view?.presentScene(newGameScene)
    }
    
    private func removeAdsRequest() {
        if let gameViewController = viewController as? GameViewController {
            if view != nil && removeAdsButtonNode != nil && removeAdsButtonNode!.parent != nil {
                let sourceOriginInScene = self.convertPoint(removeAdsButtonNode!.frame.origin, fromNode: removeAdsButtonNode!.parent!)
                let sourceOriginInView = self.convertPointToView(sourceOriginInScene)
                let sourceRect = CGRect(origin: sourceOriginInView, size: removeAdsButtonNode!.size)
                gameViewController.removeAdsButtonPressed(view!, sourceRect: sourceRect)
            }
        }
    }
    
    func removeRemoveAdsButton() {
        removeAdsButtonNode?.removeFromParent()
        removeAdsButtonNode = nil
    }
    
    

}
