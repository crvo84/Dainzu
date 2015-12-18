//
//  GameScene.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/9/15.
//  Copyright (c) 2015 Villou. All rights reserved.
//

import SpriteKit

enum GameState {
    case GameMenu, GameBallSelection, GameRunning, GamePaused, GameOver
}

enum ScreenSide {
    case Left, Right
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // -------------- Instance variables -------------------//
    weak var viewController: UIViewController?
    var contentCreated = false
    private let bannerHeight: CGFloat
    
    var gameState: GameState = .GameMenu {
        didSet {
            updateShownLayers()
        }
    }
    
    // iAd
    private var showAds: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.ShowAds)
    }
    
    // SOUND
    var isMusicOn: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.MusicOn)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: UserDefaultsKey.MusicOn)
            // TODO: update music config
            isSoundActivated = newValue
        }
    }
    // to avoid accessing user defaults every time a sound is played
    var isSoundActivated: Bool = true

    // sound actions
    private var buttonLargeSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.ButtonLarge,
        waitForCompletion: false)
    private var buttonSmallSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.ButtonSmall,
        waitForCompletion: false)
    private var impulseSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.Impulse,
        waitForCompletion: false)
    private var moneySound: SKAction = SKAction.playSoundFileNamed(SoundFilename.Money,
        waitForCompletion: false)
    private var ballCatchSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.BallCatch,
        waitForCompletion: false)
    private var ballFailedSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.BallFailed,
        waitForCompletion: false)
    private var gameOverSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.GameOver,
        waitForCompletion: false)
    private var successSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.Success,
        waitForCompletion: false)
    private var pauseSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.Pause,
        waitForCompletion: false)
    
    // colors
    var darkColorsOn: Bool {
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
    
    // game menu UI
    private var gameTitleLabel: SKLabelNode?
    private var playButtonNode: SKSpriteNode?
    private var darkColorsButtonNode: SKSpriteNode?
    private var gravityNormalButtonNode: SKSpriteNode?
    private var musicOnButtonNode: SKSpriteNode?
    private var removeAdsButtonNode: SKSpriteNode?
    private var gameCenterButtonNode: SKSpriteNode?
    private var moreGamesButtonNode: SKSpriteNode?
    private var menuBallNode: BallNode?
    private var tutorialButtonNode: SKSpriteNode?
    
    // for GameScene subclasses
    var homeButtonNode: SKSpriteNode?
    var titleLabel: SKLabelNode?
    
    // pause
    private var pauseButtonNode: SKSpriteNode?
    private var pauseNode: PauseNode?
    
    // margin bars
    var topBarHeight: CGFloat = 0
    var bottomBarHeight: CGFloat = 0
    var topBarNode: SKSpriteNode?
    var bottomBarNode: SKSpriteNode?
    var verticalMiddleBarNode: SKSpriteNode?
    
    // score
    private var scoreLabel: SKLabelNode?
    private var score: Int = 0 {
        didSet {
            let currentBest = bestScore
            if currentBest > 0 && score > currentBest {
                scoreLabel?.text = Text.BestScore + ": \(score)"
                if !beatScoreAlertPresented {
                    runAction(successSound)
                    if scoreLabelFlashAction != nil {
                        scoreLabel?.runAction(scoreLabelFlashAction!)
                    }
                    beatScoreAlertPresented = true
                }
            } else {
                scoreLabel?.text = "\(score)"
            }
        }
    }
    private var scoreLabelFlashAction: SKAction?
    private var beatScoreAlertPresented = false
    
    // best score
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
    
    // lives left
    private var livesLeft: Int = GameOption.LivesNum {
        didSet {
            updateLiveLeftNodes()
        }
    }
    private var liveLeftNodes: [SKSpriteNode] = []
    
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
    var playableRect: CGRect!
    var playableRectOriginInScene: CGPoint {
        // TODO: check again
        return CGPoint(
            x: playableRect.origin.x,
            y: size.height - playableRect.origin.y - playableRect.height)
    }
    
    // rings
    private var leftRing: RingNode!
    private var rightRing: RingNode!
    
    // balls
    private var ballSelected: String {
        get {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            return userDefaults.stringForKey(UserDefaultsKey.BallSelected) ?? UserDefaults.BallSelected
        }
        set {
            if BallImage.Balls.contains(newValue) {
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setObject(newValue, forKey: UserDefaultsKey.BallSelected)
            }
        }
    }
    private var ballHeight: CGFloat {
        return playableRect.height * Geometry.BallRelativeHeight
    }
    
    // layers
    private let barsLayer = SKNode()
    private let alwaysVisibleUILayer = SKNode()
    private let gameOnlyUILayer = SKNode()
    private let menuOnlyUILayer = SKNode()
    private let ballSelectionUILayer = SKNode()
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
        isSoundActivated = isMusicOn
        
        /* Setup your scene here */
        if !contentCreated {
            
            registerAppTransitionObservers()
            
            if Test.TestModeOn {
                print("Scene width: \(size.width), height: \(size.height)")
            }
            
            physicsWorld.contactDelegate = self
            
            playableRectSetup()
            barsSetup() // call after playableRectSetup()
            
            // ----- This methods must be called after barsSetup ----- //
            
            alwaysVisibleUISetup()
            menuOnlyUISetup()
            gameOnlyUISetup()
            ballSelectionUISetup()
            ringsSetup()
            
            adjustLabelsSize()
            
            contentCreated = true
        }
        
        updateShownLayers()
        updateGravity()
        updateColors()
        
        if let gameViewController = viewController as? GameViewController {
            gameViewController.requestInterstitialAdIfNeeded()
        }
    }
    
    func playableRectSetup() {
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
    func barsSetup() {
        barsLayer.position = CGPoint(x: 0, y: 0) // bottom-left of screen
        barsLayer.zPosition = ZPosition.BarsLayer
        addChild(barsLayer)
        
        topBarNode = nil
        bottomBarNode = nil
        verticalMiddleBarNode = nil
        
        let barColor = darkColorsOn ? Color.BarDark : Color.BarLight
        // BOTTOM bar node
        topBarNode = SKSpriteNode(texture: nil, color: barColor, size: CGSize(
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
        bottomBarNode = SKSpriteNode(texture: nil, color: barColor, size: CGSize(
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
        verticalMiddleBarNode = SKSpriteNode(texture: nil, color: barColor, size: CGSize(
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
        
        // game title label
        let gameTitleHeight = playableRect.height * Geometry.GameTitleRelativeHeight
        let gameTitleWidth = (playableRect.width - verticalMiddleBarNode!.size.width)/2 * Geometry.GameTitleRelativeWidth
        gameTitleLabel = SKLabelNode(text: Text.GameTitle)
        gameTitleLabel!.verticalAlignmentMode = .Center
        gameTitleLabel!.horizontalAlignmentMode = .Center
        gameTitleLabel!.fontName = FontName.GameTitle
        gameTitleLabel!.fontColor = darkColorsOn ? FontColor.GameTitleDark : FontColor.GameTitleLight
        adjustFontSizeForLabel(gameTitleLabel!, tofitSize: CGSize(width: gameTitleWidth, height: gameTitleHeight))
        gameTitleLabel!.position = CGPoint(
            x: -(playableRect.width - verticalMiddleBarNode!.size.width)/4 - verticalMiddleBarNode!.size.width/2,
            y: playableRect.height * Geometry.GameTitleRelativeYPosition - playableRect.height/2)
        gameTitleLabel!.name = NodeName.GameTitleLabel
        menuOnlyUILayer.addChild(gameTitleLabel!)
        
        // play button node
        playButtonNode = SKSpriteNode(imageNamed: ImageFilename.PlayButton)
        let playButtonRatio = playButtonNode!.size.width / playButtonNode!.size.height
        let playButtonHeight = playableRect.height * Geometry.PlayButtonRelativeHeight
        playButtonNode!.size = CGSize(
            width: playButtonHeight * playButtonRatio,
            height: playButtonHeight)
        let heightAvailableForPlayButton = playableRect.height/2 + gameTitleLabel!.position.y - gameTitleLabel!.frame.size.height/2
        playButtonNode!.position = CGPoint(
            x: gameTitleLabel!.position.x,
            y: -playableRect.height/2 + heightAvailableForPlayButton/2)
        playButtonNode!.name = NodeName.PlayButton
        playButtonNode!.color = darkColorsOn ? Color.PlayButtonDark : Color.PlayButtonLight
        playButtonNode!.colorBlendFactor = Color.PlayButtonBlendFactor
        if let playButtonTexture = playButtonNode!.texture {
            playButtonNode!.physicsBody = SKPhysicsBody(texture: playButtonTexture, size: playButtonNode!.size)
            playButtonNode!.physicsBody?.categoryBitMask = PhysicsCategory.MenuBoundary
            playButtonNode!.physicsBody?.dynamic = false
        }
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
        
        let configButtonHeight = gameTitleLabel!.frame.size.height * Geometry.ConfigButtonRelativeHeight
        let configButtonY = gameTitleLabel!.position.y
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
        
        // game center button
        gameCenterButtonNode = SKSpriteNode(imageNamed: ImageFilename.GameCenterButton)
        let gameCenterButtonRatio = gameCenterButtonNode!.size.width / gameCenterButtonNode!.size.height
        gameCenterButtonNode!.size = CGSize(width: gameCenterButtonRatio * configButtonHeight, height: configButtonHeight)
        gameCenterButtonNode!.position = CGPoint(
            x: firstConfigButtonX + configButtonSeparation,
            y: -configButtonY)
        gameCenterButtonNode!.color = darkColorsOn ? Color.ConfigButtonDark : Color.ConfigButtonLight
        gameCenterButtonNode!.colorBlendFactor = Color.ConfigButtonBlendFactor
        gameCenterButtonNode!.name = NodeName.GameCenterButton
        menuOnlyUILayer.addChild(gameCenterButtonNode!)
        
        // more games button
        moreGamesButtonNode = SKSpriteNode(imageNamed: ImageFilename.MoreGamesButton)
        let moreGamesButtonRatio = moreGamesButtonNode!.size.width / moreGamesButtonNode!.size.height
        moreGamesButtonNode!.size = CGSize(width: moreGamesButtonRatio * configButtonHeight, height: configButtonHeight)
        moreGamesButtonNode!.position = CGPoint(
            x: firstConfigButtonX + configButtonSeparation * 2,
            y: -configButtonY)
        moreGamesButtonNode!.color = darkColorsOn ? Color.ConfigButtonDark : Color.ConfigButtonLight
        moreGamesButtonNode!.colorBlendFactor = Color.ConfigButtonBlendFactor
        moreGamesButtonNode!.name = NodeName.MoreGamesButton
        menuOnlyUILayer.addChild(moreGamesButtonNode!)
        
        // menu ball
        let menuBallHeight = configButtonHeight * Geometry.MenuBallRelativeHeight
        menuBallNode = getNewBall(menuBallHeight, isSpecial: false)
        menuBallNode!.position = CGPoint(
            x: firstConfigButtonX + configButtonSeparation,
            y: 0)
        menuBallNode!.name = NodeName.MenuBall
        menuBallNode!.zPosition = ZPosition.MenuBall
        let scaleUpAction = SKAction.scaleTo(Geometry.MenuBallAnimationMaxScale, duration: Time.MenuBallSizeAnimation/2)
        let scaleDownAction = SKAction.scaleTo(Geometry.MenuBallAnimationMinScale, duration: Time.MenuBallSizeAnimation/2)
        let scaleAnimation = SKAction.repeatActionForever(SKAction.sequence([scaleUpAction, scaleDownAction]))
        menuBallNode!.runAction(scaleAnimation, withKey: ActionKey.MenuBallSizeAnimation)
        menuOnlyUILayer.addChild(menuBallNode!)
        
        // tutorial button
        let tutorialButtonHeight = topBarHeight * Geometry.TopLeftButtonRelativeHeight
        tutorialButtonNode = SKSpriteNode(imageNamed: ImageFilename.TutorialButton)
        let tutorialButtonRatio = tutorialButtonNode!.size.width / tutorialButtonNode!.size.height
        tutorialButtonNode!.size = CGSize(
            width: tutorialButtonRatio * tutorialButtonHeight,
            height: tutorialButtonHeight)
        tutorialButtonNode!.position = CGPoint(
            x: -playableRect.width/2 + playableRect.width * Geometry.TopLeftButtonRelativeSideOffset + tutorialButtonNode!.size.width/2,
            y: +playableRect.height/2 + topBarHeight / 2)
        tutorialButtonNode!.color = darkColorsOn ? Color.TopLeftButtonDark : Color.TopLeftButtonLight
        tutorialButtonNode!.colorBlendFactor = Color.TopLeftButtonBlendFactor
        tutorialButtonNode!.name = NodeName.TutorialButton
        menuOnlyUILayer.addChild(tutorialButtonNode!)
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
        
        // score label flash action setup
        let scoreLabelFlash = SKAction.scaleTo(Geometry.ScoreLabelFlashActionMaxScale, duration: Time.ScoreLabelFlashAction/2)
        let scoreLabelFlashReverse = SKAction.scaleTo(1.0, duration: Time.ScoreLabelFlashAction/2)
        scoreLabelFlashAction = SKAction.sequence([scoreLabelFlash, scoreLabelFlashReverse])
        
        // pause button node
        pauseButtonNode = SKSpriteNode(imageNamed: ImageFilename.PauseButton)
        let pauseButtonRatio = pauseButtonNode!.size.width / pauseButtonNode!.size.height
        let pauseButtonHeight = topBarHeight * Geometry.TopLeftButtonRelativeHeight
        pauseButtonNode!.size = CGSize(width: pauseButtonHeight * pauseButtonRatio, height: pauseButtonHeight)
        pauseButtonNode!.position = CGPoint(
            x: -playableRect.width/2 + playableRect.width * Geometry.TopLeftButtonRelativeSideOffset + pauseButtonNode!.size.width/2,
            y: +playableRect.height/2 + topBarHeight / 2)
        pauseButtonNode!.name = NodeName.PauseButton
        pauseButtonNode!.color = darkColorsOn ? Color.TopLeftButtonDark : Color.TopLeftButtonLight
        pauseButtonNode!.colorBlendFactor = Color.TopLeftButtonBlendFactor
        gameOnlyUILayer.addChild(pauseButtonNode!)
        
        // live left nodes
        updateLiveLeftNodes()
    }
    
    private func alwaysVisibleUISetup() {
        alwaysVisibleUILayer.zPosition = ZPosition.AlwaysVisibleUILayer
        alwaysVisibleUILayer.position = CGPoint(
            x: playableRectOriginInScene.x + playableRect.width/2,
            y: playableRectOriginInScene.y + playableRect.height/2)
        addChild(alwaysVisibleUILayer)
        
        // coin node
        let coinNodeHeight = topBarHeight * Geometry.CoinNodeRelativeHeight
        coinNode = getNewBall(coinNodeHeight, isSpecial: true)
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
    
    private func ballSelectionUISetup() {
        ballSelectionUILayer.zPosition = ZPosition.BallSelectionUILayer
        ballSelectionUILayer.position = CGPoint(
            x: playableRectOriginInScene.x + playableRect.width/2,
            y: playableRectOriginInScene.y + playableRect.height/2)
        addChild(ballSelectionUILayer)
        
        // home button
        homeButtonNode = SKSpriteNode(imageNamed: ImageFilename.HomeButton)
        let homeButtonRatio = homeButtonNode!.size.width / homeButtonNode!.size.height
        let homeButtonHeight = topBarHeight * Geometry.TopLeftButtonRelativeHeight
        homeButtonNode!.size = CGSize(width: homeButtonRatio * homeButtonHeight, height: homeButtonHeight)
        homeButtonNode!.position = CGPoint(
            x: -playableRect.width/2 + playableRect.width * Geometry.TopLeftButtonRelativeSideOffset + homeButtonNode!.size.width/2,
            y: +playableRect.height/2 + topBarHeight / 2)
        homeButtonNode!.name = NodeName.HomeButton
        homeButtonNode!.color = darkColorsOn ? Color.TopLeftButtonDark : Color.TopLeftButtonLight
        homeButtonNode!.colorBlendFactor = Color.TopLeftButtonBlendFactor
        ballSelectionUILayer.addChild(homeButtonNode!)
    }

    func ringsSetup() {
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
            self.createNewBallForGame(.Left)
            self.createNewBallForGame(.Right)
        }
        let sequenceAction = SKAction.sequence([createBallsAction, waitAction])
        runAction(SKAction.repeatActionForever(sequenceAction), withKey: ActionKey.BallsGeneration)
    }

    private func startGame() {
        gameState = .GameRunning
        
        updateLiveLeftNodes()
        
        activateRingsPhysics()
        
        generateBalls()
    }
    
    // MARK: Update methods
    
    private func updateShownLayers() {
        switch gameState {
        case .GameMenu:
            
            menuOnlyUILayer.hidden = false
            gameOnlyUILayer.hidden = true
            ballSelectionUILayer.hidden = true
            
            ringsLayer.hidden = false
            ballsLayer.hidden = true
            
        case .GameRunning:

            menuBallNode?.removeFromParent()
            menuBallNode =  nil
            
            gameOnlyUILayer.hidden = false
            menuOnlyUILayer.hidden = true
            ballSelectionUILayer.hidden = true
            
            ringsLayer.hidden = false
            ballsLayer.hidden = false
            
        case .GameBallSelection:
            
            ballSelectionUILayer.hidden = false
            gameOnlyUILayer.hidden = true
            menuOnlyUILayer.hidden = true
            
            ringsLayer.hidden = true
            ballsLayer.hidden = true
            
        default:
            break
        }
    }
    
    func updateColors() {
        let dark = darkColorsOn
        
        // ALWAYS SHOWN
        // background
        backgroundColor = dark ? Color.BackgroundDark : Color.BackgroundLight
        
        // bars
        let barColor = dark ? Color.BarDark : Color.BarLight
        topBarNode?.color = barColor
        bottomBarNode?.color = barColor
        verticalMiddleBarNode?.color = barColor
        
        // rings
        let ringColor = dark ? Color.RingDark : Color.RingLight
        leftRing?.color = ringColor
        rightRing?.color = ringColor
        
        // coins label
        coinsLabel?.fontColor = dark ? FontColor.CoinsDark : FontColor.CoinsLight
        
        // GAME MENU
        // main title
        gameTitleLabel?.fontColor = dark ? FontColor.GameTitleDark : FontColor.GameTitleLight
        
        // best score label
        bestScoreLabel?.fontColor = dark ? FontColor.BestScoreDark : FontColor.BestScoreLight
        
        // play button
        playButtonNode?.color = dark ? Color.PlayButtonDark : Color.PlayButtonLight
        
        // tutorial button
        tutorialButtonNode?.color = dark ? Color.TopLeftButtonDark : Color.TopLeftButtonLight
        
        // config buttons
        let configButtonColor = dark ? Color.ConfigButtonDark : Color.ConfigButtonLight
        darkColorsButtonNode?.color = configButtonColor
        musicOnButtonNode?.color = configButtonColor
        gravityNormalButtonNode?.color = configButtonColor
        removeAdsButtonNode?.color = configButtonColor
        gameCenterButtonNode?.color = configButtonColor
        moreGamesButtonNode?.color = configButtonColor
        
        // GAME RUNNING
        // score label
        scoreLabel?.fontColor = dark ? FontColor.ScoreDark : FontColor.ScoreLight
        
        // pause button
        pauseButtonNode?.color = dark ? Color.TopLeftButtonDark : Color.TopLeftButtonLight
        
        // live left nodes
        updateLiveLeftNodes()

        
    }
    
    func updateGravity() {
        if rightRing != nil {
            rightRing.gravityNormal = gravityNormal
        }
        
        if leftRing != nil {
            leftRing.gravityNormal = gravityNormal
        }
        
        let yGravity = gravityNormal ? gravityAdjustedForDevice : -gravityAdjustedForDevice
        physicsWorld.gravity = CGVector(dx: 0, dy: yGravity)
    }
    
    private func updateLiveLeftNodes() {
        if gameState != .GameRunning {
            return
        }
        // reset liveLeftNodes array
        for liveNode in liveLeftNodes {
            liveNode.removeFromParent()
        }
        liveLeftNodes = []
        
        for _ in 0..<livesLeft {
            let liveLeftNode = SKSpriteNode(imageNamed: ImageFilename.LiveLeft)
            liveLeftNode.name = NodeName.LiveLeftNode
            liveLeftNode.color = darkColorsOn ? Color.LiveLeftDark : Color.LiveLeftLight
            liveLeftNode.colorBlendFactor = Color.LiveLeftBlendFactor
            liveLeftNodes.append(liveLeftNode)
        }
        
        if liveLeftNodes.count > 0 {
            let nodeRatio = liveLeftNodes.first!.size.width / liveLeftNodes.first!.size.height
            var nodeHeight = topBarHeight * Geometry.LivesLeftNodeRelativeHeight
            if gameTitleLabel != nil {
                nodeHeight = min(nodeHeight, gameTitleLabel!.frame.size.height * Geometry.LivesLeftNodeMaxRelativeHeight)
            }
            let nodeWidth = nodeRatio * nodeHeight
            
            let nodeSeparation = playableRect.width * Geometry.LivesLeftNodeRelativeSeparation
            let yPos = playableRect.height/2 + topBarHeight/2
            let firstNodeX = -playableRect.width/4 - nodeWidth - nodeSeparation
            
            for i in 0..<liveLeftNodes.count {
                let liveLeftNode = liveLeftNodes[i]
                liveLeftNode.size = CGSize(width: nodeWidth, height: nodeHeight)
                liveLeftNode.position = CGPoint(
                    x: firstNodeX + (nodeWidth + nodeSeparation) * CGFloat(i),
                    y: yPos)
                gameOnlyUILayer.addChild(liveLeftNode)
            }
        }
    }
    
    
    
    // MARK: User interaction
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        if gameState == .GameMenu || gameState == .GamePaused || gameState == .GameBallSelection {
            let touch = touches.first!
            let location = touch.locationInNode(self)
            let touchedNode = self.nodeAtPoint(location)
            
            if let nodeName = touchedNode.name {
                switch nodeName {
            
                case NodeName.PlayButton:
                    if isSoundActivated { runAction(buttonLargeSound) }
                    startGame()
                    
                case NodeName.QuitButton:
                    startNewGame()
                    
                case NodeName.ContinueButton:
                    if isSoundActivated { runAction(buttonLargeSound) }
                    unpauseGame()
                    
                case NodeName.DarkColorsOnOffButton:
                    if isSoundActivated { runAction(buttonSmallSound) }
                    darkColorsOn = !darkColorsOn
                    if let darkColorsNode = touchedNode as? SKSpriteNode {
                        darkColorsNode.texture = SKTexture(imageNamed: darkColorsOn ? ImageFilename.DarkColorsOn : ImageFilename.DarkColorsOff)
                    }
                    
                case NodeName.GravityNormalOnOffButton:
                    if isSoundActivated { runAction(buttonSmallSound) }
                    gravityNormal = !gravityNormal
                    if let gravityNormalNode = touchedNode as? SKSpriteNode {
                        gravityNormalNode.texture = SKTexture(imageNamed: gravityNormal ? ImageFilename.GravityNormalOn : ImageFilename.GravityNormalOff)
                    }
//                    activateMenuBallPhysics()
                    activateRingsPhysics()
                    
                case NodeName.MusicOnOffButton:
                    isMusicOn = !isMusicOn
                    if let musicOnOffNode = touchedNode as? SKSpriteNode {
                        musicOnOffNode.texture = SKTexture(imageNamed: isMusicOn ? ImageFilename.MusicOnButton : ImageFilename.MusicOffButton)
                    }
//                    if isSoundActivated { runAction(buttonSmallSound) }
                    
                case NodeName.RemoveAdsButton:
                    if isSoundActivated { runAction(buttonSmallSound) }
                    removeAdsRequest()
                    
                case NodeName.GameCenterButton:
                    if isSoundActivated { runAction(buttonSmallSound) }
                    gameCenterRequest()
                    
                case NodeName.MoreGamesButton:
                    if isSoundActivated { runAction(buttonSmallSound) }
                    moreGamesRequest()
                    
                case NodeName.MenuBall:
                    if isSoundActivated { runAction(buttonSmallSound) }
                    selectBall()
                    
                case NodeName.TutorialButton:
                    if isSoundActivated {
                        runAction(buttonSmallSound) {
                            self.startTutorial()
                        }
                    } else {
                        startTutorial()
                    }
                    
                case NodeName.HomeButton:
                    if isSoundActivated {
                        runAction(buttonSmallSound) {
                            self.startNewGame()
                        }
                    } else {
                        startNewGame()
                    }
                    
                default:
                    break
                }

            }
            
        } else if gameState == .GameRunning {
            var shouldPlayImpulseSound = false // to avoid multiple actions on simultaneous touches
            for touch in touches {
                let location = touch.locationInNode(self)
                let touchedNode = self.nodeAtPoint(location)
                
                if let nodeName = touchedNode.name {
                    switch nodeName {
                        
                    case NodeName.PauseButton:
                        if isSoundActivated {
                            runAction(pauseSound) {
                                self.pauseGame()
                            }
                        } else {
                            pauseGame()
                        }
                        
                    case NodeName.ExitTutorialButton:
                        if isSoundActivated {
                            runAction(buttonSmallSound) {
                                self.startNewGame()
                            }
                        } else {
                            startNewGame()
                        }
                        
                    default:
                        applyRingImpulse(touchLocation: location)
                        shouldPlayImpulseSound = true
                    }
                } else {
                    applyRingImpulse(touchLocation: location)
                    shouldPlayImpulseSound = true
                }
            }
            if shouldPlayImpulseSound  && isSoundActivated {
                runAction(impulseSound)
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
                    ballFailed()
                    
                } else if collision == PhysicsCategory.Ball | PhysicsCategory.Boundary {
                    ballNode.removeFromParent()
                    ballFailed()
                } else if collision == PhysicsCategory.Ball | PhysicsCategory.RingGoal {
                    let isSpecial = ballNode.isSpecial
                    ballNode.removeFromParent()
                    if isSpecial {
                        coinsCount++
                        if coinNodeFlashAction != nil {
                            coinNode?.runAction(coinNodeFlashAction!)
                        }
                        if coinsLabelFlashAction != nil {
                            coinsLabel?.runAction(coinsLabelFlashAction!)
                        }
                        if isSoundActivated { runAction(moneySound) }
                        
                    } else {
                        if isSoundActivated { runAction(ballCatchSound) }
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
    
    func activateRingsPhysics() {
        if leftRing != nil && rightRing != nil {
            leftRing.stopFloatingAnimation()
            rightRing.stopFloatingAnimation()
            leftRing.physicsBody!.dynamic = true
            rightRing.physicsBody!.dynamic = true
            let leftRingImpulse = arc4random_uniform(UInt32(2)) == 0
            if leftRingImpulse {
                applyRingImpulse(touchLocation: CGPoint(x: size.width * 0.25, y: size.height/2))
            } else {
                applyRingImpulse(touchLocation: CGPoint(x: size.width * 0.75, y: size.height/2))
            }
        }
    }
    
      // ---------------------- //
     // -------- Ball -------- //
    // ---------------------- //
    
    private func createNewBallForGame(screenSide: ScreenSide) {
        let isSpecial = GameOption.SpecialBallsOn && arc4random_uniform(GameOption.SpecialBallsRatio) == 0
        let ballNode = getNewBall(ballHeight, isSpecial: isSpecial)
        ballNode.position = self.getBallRandomPosition(ballNode, screenSide: screenSide)
        ballsLayer.addChild(ballNode)
        
        ballNode.physicsBody?.velocity = getBallVelocity(ballNode, screenSide: screenSide)

        let rotateAction = SKAction.repeatActionForever(SKAction.rotateByAngle(2*π, duration: Time.BallRotate))
        ballNode.runAction(rotateAction, withKey: ActionKey.BallRotate)
    }
    
    // creates a new BallNode with the selected ball texture
    private func getNewBall(height: CGFloat, isSpecial: Bool) -> BallNode {
        var ballTexture: SKTexture?
        if isSpecial {
            ballTexture = SKTexture(imageNamed: BallImage.Ball_Special)
        } else {
            ballTexture = SKTexture(imageNamed: ballSelected)
        }
        let ballNode = BallNode(texture: ballTexture, height: height, color: nil)
        ballNode.isSpecial = isSpecial
        return ballNode
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
    
    private func activateMenuBallPhysics() {
        menuBallNode?.removeActionForKey(ActionKey.MenuBallSizeAnimation)
        menuBallNode?.xScale = 1
        menuBallNode?.yScale = 1
        menuBallNode?.physicsBody?.affectedByGravity = true
    }
    
    private func ballFailed() {
        if gameState != .GameRunning { return }
        if --livesLeft > 0 {
            if isSoundActivated { runAction(ballFailedSound) }
        } else {
            gameOver()
        }
    }
    
    
      // -------------------------------- //
     // -------- Ball Selection -------- //
    // -------------------------------- //
    
    private func selectBall() {
        if gameState == .GameMenu {
            gameState = .GameBallSelection
            
        }
    }
    
    
      // ------------------------ //
     // -------- Labels -------- //
    // ------------------------ //
    
    func adjustLabelsSize() {
        if gameTitleLabel != nil {
            let maxFontSize = gameTitleLabel!.fontSize
            if scoreLabel != nil {
                scoreLabel!.fontSize = min(scoreLabel!.fontSize, maxFontSize * Geometry.ScoreLabelMaxRelativeFontSize)
            }
            if bestScoreLabel != nil {
                bestScoreLabel!.fontSize = min(bestScoreLabel!.fontSize, maxFontSize * Geometry.ScoreLabelMaxRelativeFontSize)
            }
            if coinsLabel != nil {
                coinsLabel!.fontSize = min(coinsLabel!.fontSize, maxFontSize * Geometry.CoinsLabelMaxRelativeFontSize)
            }
            if pauseButtonNode != nil {
                let pauseButtonRatio = pauseButtonNode!.size.width / pauseButtonNode!.size.height
                let pauseButtonHeight = min(pauseButtonNode!.size.height, gameTitleLabel!.frame.size.height)
                pauseButtonNode!.size = CGSize(
                    width: pauseButtonHeight * pauseButtonRatio,
                    height: pauseButtonHeight)
            }
            if homeButtonNode != nil {
                let homeButtonRatio = homeButtonNode!.size.width / homeButtonNode!.size.height
                let homeButtonHeight = min(homeButtonNode!.size.height, gameTitleLabel!.frame.size.height)
                homeButtonNode!.size = CGSize(width: homeButtonRatio * homeButtonHeight, height: homeButtonHeight)
            }
            if titleLabel != nil {
                titleLabel!.fontSize = min(titleLabel!.fontSize, maxFontSize * Geometry.TitleLabelMaxRelativeFontSize)
            }
            updateLiveLeftNodes()
        }
    }
    
    func adjustFontSizeForLabel(labelNode: SKLabelNode, tofitSize size: CGSize) {
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
    
    private func gameOver() {
        gameState = .GameOver
        if let gameViewController = viewController as? GameViewController {
            gameViewController.reportScore(score)
        }
        if score > bestScore {
            bestScore = score
        }
        if isSoundActivated {
            runAction(self.gameOverSound) { self.startNewGame() }
        } else {
            startNewGame()
        }
    }
    
    private func startTutorial() {
        let tutorialGameScene = TutorialGameScene(size: size, bannerHeight: bannerHeight)
        tutorialGameScene.scaleMode = scaleMode
        view?.presentScene(tutorialGameScene)
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
    
    private func gameCenterRequest() {
        if let gameViewController = viewController as? GameViewController {
            gameViewController.leaderboardButtonPressed(self)
        }
    }
    
    private func moreGamesRequest() {
        if let gameViewController = viewController as? GameViewController {
            gameViewController.moreGamesButtonPressed()
        }
    }

}
