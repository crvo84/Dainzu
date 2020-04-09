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
    case left, right
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // -------------- Instance variables -------------------//
    weak var viewController: UIViewController? // TODO: comunicate VC via delegate instead
    var contentCreated = false
    private let bannerHeight: CGFloat
    
    var gameState: GameState = .GameMenu {
        didSet {
            updateShownLayers()
        }
    }
    
    // iAd
    private var showAds: Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKey.ShowAds)
    }
    
    // SOUND
    var isMusicOn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.MusicOn)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserDefaultsKey.MusicOn)
            defaults.synchronize()

            // TODO: update music config
            isSoundActivated = newValue
        }
    }
    // to avoid accessing user defaults every time a sound is played
    var isSoundActivated: Bool = true

    // sound actions
    var buttonLargeSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.ButtonLarge,
        waitForCompletion: false)
    var buttonSmallSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.ButtonSmall,
        waitForCompletion: false)
    var impulseSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.Impulse,
        waitForCompletion: false)
    var moneySound: SKAction = SKAction.playSoundFileNamed(SoundFilename.Money,
        waitForCompletion: true)
    var ballCatchSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.BallCatch,
        waitForCompletion: false)
    var ballFailedSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.BallFailed,
        waitForCompletion: false)
    var gameOverSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.GameOver,
        waitForCompletion: false)
    var successSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.Success,
        waitForCompletion: false)
    var pauseSound: SKAction = SKAction.playSoundFileNamed(SoundFilename.Pause,
        waitForCompletion: false)
    
    // colors
    var darkColorsOn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.DarkColorsOn)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserDefaultsKey.DarkColorsOn)
            defaults.synchronize()
            updateColors()
        }
    }
    
    // gravity
    private var gravityNormal: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.GravityNormal)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserDefaultsKey.GravityNormal)
            defaults.synchronize()
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
    private var selectBallButtonNode: SKSpriteNode?
    private var menuBallLeftNode: BallNode?
    private var menuBallRightNode: BallNode?
    
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
                    run(successSound)
                    if scoreLabelFlashAction != nil {
                        scoreLabel?.run(scoreLabelFlashAction!)
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
            return UserDefaults.standard.integer(forKey: UserDefaultsKey.BestScore)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserDefaultsKey.BestScore)
            defaults.synchronize()
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
    var coinNode: BallNode?
    var coinsLabel: SKLabelNode?
    var coinsCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserDefaultsKey.CoinsCount)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.CoinsCount)
            coinsLabel?.text = "\(newValue)/\(GameOption.BallPrice)"
        }
    }
    var coinNodeFlashAction: SKAction?
    var coinsLabelFlashAction: SKAction?
    
    // instruction labels
    var instructionLeftLabel: SKLabelNode?
    var instructionRightLabel: SKLabelNode?

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
    var ballSelected: String {
        get {
            let userDefaults = UserDefaults.standard
            return userDefaults.string(forKey: UserDefaultsKey.BallSelected) ?? UserDefaultsInitialValues.BallSelected
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserDefaultsKey.BallSelected)
            defaults.synchronize()
        }
    }
    private var ballHeight: CGFloat {
        return playableRect.height * Geometry.BallRelativeHeight
    }
    
    // level
    private var round: Int = 0
    private var level: Int {
        return round / GameOption.RoundsPerLevel
    }
    private var timeBetweenBalls: Double {
        return max(Time.BallsWaitInitial - Time.BallsWaitDecrease * Double(level), Time.BallsWaitMinimum)
    }
    
    // layers
    private let barsLayer = SKNode()
    private let alwaysVisibleUILayer = SKNode()
    private let gameOnlyUILayer = SKNode()
    private let menuOnlyUILayer = SKNode()
    private let ringsLayer = SKNode()
    private let ballsLayer = SKNode()
    private let instructionsUILayer = SKNode()
    
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
        isSoundActivated = isMusicOn
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Game Setup
    override func didMove(to view: SKView) {
        view.isMultipleTouchEnabled = true
        
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
            
            coinsUISetup()
            menuOnlyUISetup()
            gameOnlyUISetup()
            ballsUISetup()
            ringsSetup()
            if UserDefaults.standard.bool(forKey: UserDefaultsKey.ShowInstructions) {
                instructionsUISetup()
            }
            
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
    
    // abstract method
    func updateUI() {
        // override in subclasses
    }
    
    func playableRectSetup() {
        // playableRect uses all scene width, with a constant ratio to define height
        let playableRectWidth = size.width
        let availableHeightAfterBanner = size.height - bannerHeight
        let minTopBarHeight = availableHeightAfterBanner * Geometry.TopRelativeHeightAssignedBeforeBottomBar
        let availablePlayableRectHeight = availableHeightAfterBanner - minTopBarHeight
        let playableRectHeight = min(availablePlayableRectHeight, size.width / Geometry.PlayableRectRatio)
        
        // the available height left to this point, is divided between top and bottom parts evenly
        let availableHeightLeft = availablePlayableRectHeight - playableRectHeight
        topBarHeight = minTopBarHeight + availableHeightLeft / 2.0
        bottomBarHeight = bannerHeight + availableHeightLeft / 2.0 // banner height is now considered into bottomBarHeight
        
        // UIView coord system ((0,0) is top left)
        playableRect = CGRect(
            origin: CGPoint(x: 0, y: topBarHeight),
            size: .init(width: playableRectWidth, height: playableRectHeight))
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
        topBarNode!.physicsBody = SKPhysicsBody(rectangleOf: topBarNode!.size)
        topBarNode!.physicsBody!.isDynamic = false
        topBarNode!.physicsBody!.categoryBitMask = PhysicsCategory.Boundary
        topBarNode!.name = NodeName.Boundary
        barsLayer.addChild(topBarNode!)
        
        // TOP (add bannerHeight to size to show bar color while banner is not shown)
        bottomBarNode = SKSpriteNode(texture: nil, color: barColor, size: CGSize(
            width: size.width,
            height: bottomBarHeight))
        bottomBarNode!.position = CGPoint(x: size.width/2, y: bottomBarHeight/2)
        // physics body
        bottomBarNode!.physicsBody = SKPhysicsBody(rectangleOf: bottomBarNode!.size)
        bottomBarNode!.physicsBody!.isDynamic = false
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
        verticalMiddleBarNode!.physicsBody = SKPhysicsBody(rectangleOf: verticalMiddleBarNode!.size)
        verticalMiddleBarNode!.physicsBody!.isDynamic = false
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
        gameTitleLabel!.verticalAlignmentMode = .center
        gameTitleLabel!.horizontalAlignmentMode = .center
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
        playButtonNode!.colorBlendFactor = Color.BlendFactor
        if let playButtonTexture = playButtonNode!.texture {
            playButtonNode!.physicsBody = SKPhysicsBody(texture: playButtonTexture, size: playButtonNode!.size)
            playButtonNode!.physicsBody?.categoryBitMask = PhysicsCategory.MenuBoundary
            playButtonNode!.physicsBody?.isDynamic = false
        }
        menuOnlyUILayer.addChild(playButtonNode!)
        
        // best label
        let bestScoreLabelHeight = topBarHeight * Geometry.BestScoreLabelRelativeHeight
        let bestScoreLabelWidth = playableRect.width * Geometry.BestScoreLabelRelativeWidth
        bestScoreLabel = SKLabelNode(text: Text.BestScore + ": \(bestScore)")
        bestScoreLabel!.verticalAlignmentMode = .center
        bestScoreLabel!.horizontalAlignmentMode = .center
        bestScoreLabel!.fontName = FontName.BestScore
        bestScoreLabel!.fontColor = darkColorsOn ? FontColor.BestScoreDark : FontColor.BestScoreLight
        adjustFontSizeForLabel(bestScoreLabel!, tofitSize: CGSize(
            width: bestScoreLabelWidth,
            height: bestScoreLabelHeight))
        bestScoreLabel!.position = CGPoint(x: 0, y: +playableRect.height/2 + topBarHeight/2)
        bestScoreLabel!.name = NodeName.BestScoreLabel
        menuOnlyUILayer.addChild(bestScoreLabel!)
        
        // ------------------- //
        // CONFIG BUTTON NODES //
        // ------------------- //
        let configButtonHeight = gameTitleLabel!.frame.size.height * Geometry.ConfigButtonRelativeHeight
        let configButtonColor = darkColorsOn ? Color.ConfigButtonDark : Color.ConfigButtonLight
        let configButtonSeparation = playableRect.width * Geometry.ConfigButtonRelativeSeparation
        let configButtonSideOffset = playableRect.width * Geometry.ConfigButtonRelativeHorizontalOffset
        
        // SELECT BALL BUTTON NODE
        // select ball button
        selectBallButtonNode = SKSpriteNode(imageNamed: ImageFilename.SelectBallButton)
        let selectBallButtonRatio = selectBallButtonNode!.size.width / selectBallButtonNode!.size.height
        let selectBallButtonHeight = playableRect.height * Geometry.ConfigSelectBallButtonRelativeHeight
        selectBallButtonNode!.size = CGSize(
            width: selectBallButtonRatio * selectBallButtonHeight,
            height: selectBallButtonHeight)
        selectBallButtonNode!.position = CGPoint(
            x: -playButtonNode!.position.x,
            y: +playButtonNode!.position.y)
        selectBallButtonNode!.color = configButtonColor
        selectBallButtonNode!.colorBlendFactor = Color.BlendFactor
        selectBallButtonNode!.name = NodeName.SelectBallButton
        menuOnlyUILayer.addChild(selectBallButtonNode!)
        
        // TOP RIGHT
        let topConfigButtonY = playableRect.height/2 - (playableRect.height * Geometry.ConfigButtonRelativeVerticalOffset) - configButtonHeight/2
        
        // music on button
        musicOnButtonNode = SKSpriteNode(imageNamed: isMusicOn ? ImageFilename.MusicOnButton : ImageFilename.MusicOffButton)
        let musicOnButtonRatio = musicOnButtonNode!.size.width / musicOnButtonNode!.size.height
        musicOnButtonNode!.size = CGSize(width: musicOnButtonRatio * configButtonHeight, height: configButtonHeight)
        musicOnButtonNode!.position = CGPoint(
            x: playableRect.width/2 - configButtonSideOffset,
            y: topConfigButtonY)
        musicOnButtonNode!.color = configButtonColor
        musicOnButtonNode!.colorBlendFactor = Color.BlendFactor
        musicOnButtonNode!.name = NodeName.MusicOnOffButton
        menuOnlyUILayer.addChild(musicOnButtonNode!)
        
        // dark colors button
        darkColorsButtonNode = SKSpriteNode(imageNamed: darkColorsOn ? ImageFilename.DarkColorsOn : ImageFilename.DarkColorsOff)
        let darkColorsButtonRatio = darkColorsButtonNode!.size.width / darkColorsButtonNode!.size.height
        darkColorsButtonNode!.size = CGSize(width: darkColorsButtonRatio * configButtonHeight, height: configButtonHeight)
        darkColorsButtonNode!.position = CGPoint(
            x: musicOnButtonNode!.position.x - configButtonSeparation,
            y: topConfigButtonY)
        darkColorsButtonNode!.color = configButtonColor
        darkColorsButtonNode!.colorBlendFactor = Color.BlendFactor
        darkColorsButtonNode!.name = NodeName.DarkColorsOnOffButton
        menuOnlyUILayer.addChild(darkColorsButtonNode!)
        
        // gravity normal button
        gravityNormalButtonNode = SKSpriteNode(imageNamed: gravityNormal ? ImageFilename.GravityNormalOn : ImageFilename.GravityNormalOff)
        let gravityNormalButtonRatio = gravityNormalButtonNode!.size.width / gravityNormalButtonNode!.size.height
        gravityNormalButtonNode!.size = CGSize(width: gravityNormalButtonRatio * configButtonHeight, height: configButtonHeight)
        gravityNormalButtonNode!.position = CGPoint(
            x: darkColorsButtonNode!.position.x - configButtonSeparation,
            y: topConfigButtonY)
        gravityNormalButtonNode!.color = configButtonColor
        gravityNormalButtonNode!.colorBlendFactor = Color.BlendFactor
        gravityNormalButtonNode!.name = NodeName.GravityNormalOnOffButton
        menuOnlyUILayer.addChild(gravityNormalButtonNode!)
        
        // game center button
        gameCenterButtonNode = SKSpriteNode(imageNamed: ImageFilename.GameCenterButton)
        let gameCenterButtonRatio = gameCenterButtonNode!.size.width / gameCenterButtonNode!.size.height
        gameCenterButtonNode!.size = CGSize(width: gameCenterButtonRatio * configButtonHeight, height: configButtonHeight)
        gameCenterButtonNode!.position = CGPoint(
            x: gravityNormalButtonNode!.position.x - configButtonSeparation,
            y: topConfigButtonY)
        gameCenterButtonNode!.color = configButtonColor
        gameCenterButtonNode!.colorBlendFactor = Color.BlendFactor
        gameCenterButtonNode!.name = NodeName.GameCenterButton
        menuOnlyUILayer.addChild(gameCenterButtonNode!)
        
        
        // BOTTOM RIGHT
        let bottomConfigButtonY = -topConfigButtonY
        // more games button
        moreGamesButtonNode = SKSpriteNode(imageNamed: ImageFilename.MoreGamesButton)
        let moreGamesButtonRatio = moreGamesButtonNode!.size.width / moreGamesButtonNode!.size.height
        moreGamesButtonNode!.size = CGSize(width: moreGamesButtonRatio * configButtonHeight, height: configButtonHeight)
        moreGamesButtonNode!.position = CGPoint(
            x: playableRect.width/2 - configButtonSideOffset,
            y: bottomConfigButtonY)
        moreGamesButtonNode!.color = configButtonColor
        moreGamesButtonNode!.colorBlendFactor = Color.BlendFactor
        moreGamesButtonNode!.name = NodeName.MoreGamesButton
        menuOnlyUILayer.addChild(moreGamesButtonNode!)
        
        // remove ads button
        if showAds {
            removeAdsButtonNode = SKSpriteNode(imageNamed: ImageFilename.RemoveAdsButton)
            let removeAdsButtonRatio = removeAdsButtonNode!.size.width / removeAdsButtonNode!.size.height
            removeAdsButtonNode!.size = CGSize(width: removeAdsButtonRatio * configButtonHeight, height: configButtonHeight)
            removeAdsButtonNode!.position = CGPoint(
                x: moreGamesButtonNode!.position.x - configButtonSeparation,
                y: bottomConfigButtonY)
            removeAdsButtonNode!.color = configButtonColor
            removeAdsButtonNode!.colorBlendFactor = Color.BlendFactor
            removeAdsButtonNode!.name = NodeName.RemoveAdsButton
            menuOnlyUILayer.addChild(removeAdsButtonNode!)
        }

        
        // menu ball node
        createNewBallForMenu()
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
        scoreLabel!.verticalAlignmentMode = .center
        scoreLabel!.horizontalAlignmentMode = .center
        scoreLabel!.fontName = FontName.Score
        scoreLabel!.fontColor = darkColorsOn ? FontColor.ScoreDark : FontColor.ScoreLight
        adjustFontSizeForLabel(scoreLabel!, tofitSize: CGSize(width: scoreLabelWidth, height: scoreLabelHeight))
        scoreLabel!.position = CGPoint(x: 0, y: +playableRect.height/2 + topBarHeight/2)
        gameOnlyUILayer.addChild(scoreLabel!)
        
        // score label flash action setup
        let scoreLabelFlash = SKAction.scale(to: Geometry.ScoreLabelFlashActionMaxScale, duration: Time.ScoreLabelFlashAction/2)
        let scoreLabelFlashReverse = SKAction.scale(to: 1.0, duration: Time.ScoreLabelFlashAction/2)
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
        pauseButtonNode!.colorBlendFactor = Color.BlendFactor
        gameOnlyUILayer.addChild(pauseButtonNode!)
        
        // live left nodes
        updateLiveLeftNodes()
    }
    
    func coinsUISetup() {
        alwaysVisibleUILayer.zPosition = ZPosition.AlwaysVisibleUILayer
        alwaysVisibleUILayer.position = CGPoint(
            x: playableRectOriginInScene.x + playableRect.width/2,
            y: playableRectOriginInScene.y + playableRect.height/2)
        addChild(alwaysVisibleUILayer)
        
        // coin node
        let coinNodeHeight = topBarHeight * Geometry.CoinNodeRelativeHeight
        coinNode = getNewBall(height: coinNodeHeight, isSpecial: true)
        coinNode!.physicsBody?.isDynamic = false
        coinNode!.position = CGPoint(
            x: playableRect.width/2 - coinNode!.size.width/2 - playableRect.width * Geometry.CoinNodeRelativeSideOffset,
            y: playableRect.height/2 + topBarHeight/2)
        alwaysVisibleUILayer.addChild(coinNode!)
        
        // coins label
        let coinsLabelHeight = topBarHeight * Geometry.CoinsLabelRelativeHeight
        let coinsLabelWidth = playableRect.width * Geometry.CoinsLabelRelativeWidth
        coinsLabel = SKLabelNode(text: "\(coinsCount)/\(GameOption.BallPrice)")
        coinsLabel!.fontColor = darkColorsOn ? FontColor.CoinsDark : FontColor.CoinsLight
        coinsLabel!.fontName = FontName.Coins
        adjustFontSizeForLabel(coinsLabel!, tofitSize: CGSize(width: coinsLabelWidth, height: coinsLabelHeight))
        coinsLabel!.verticalAlignmentMode = .center
        coinsLabel!.horizontalAlignmentMode = .right
        coinsLabel!.position = CGPoint(
            x: coinNode!.position.x - coinNode!.size.width/2 - coinNode!.size.width * Geometry.CoinsLabelRelativeSideOffset,
            y: playableRect.height/2 + topBarHeight/2)
        alwaysVisibleUILayer.addChild(coinsLabel!)
        
        let coinsLabelFlash = SKAction.scale(to: Geometry.CoinsLabelFlashActionMaxScale, duration: Time.CoinsLabelFlashAction/2)
        let coinsLabelFlashReverse = SKAction.scale(to: 1.0, duration: Time.CoinsLabelFlashAction/2)
        coinsLabelFlashAction = SKAction.sequence([coinsLabelFlash, coinsLabelFlashReverse])
        let coinNodeFlash = SKAction.scale(to: Geometry.CoinsLabelFlashActionMaxScale, duration: Time.CoinsLabelFlashAction/2)
        let coinNodeFlashReverse = SKAction.scale(to: 1.0, duration: Time.CoinsLabelFlashAction/2)
        coinNodeFlashAction = SKAction.sequence([coinNodeFlash, coinNodeFlashReverse])
    }
    
    private func ballsUISetup() {
        ballsLayer.position = playableRectOriginInScene
        ballsLayer.zPosition = ZPosition.BallsLayer
        addChild(ballsLayer)
        
        createNewBallForMenu()
    }
    
    private func instructionsUISetup() {
        instructionsUILayer.zPosition = ZPosition.InstructionsLayer
        instructionsUILayer.position = CGPoint(
            x: playableRectOriginInScene.x + playableRect.width/2,
            y: playableRectOriginInScene.y + playableRect.height/2)
        addChild(instructionsUILayer)
        
        let instructionLabelHeight = playableRect.height * Geometry.InstructionLabelRelativeWidth
        let instructionLabelWidth = (playableRect.width - verticalMiddleBarNode!.size.width)/2 * Geometry.GameTitleRelativeWidth
        let instructionColor = darkColorsOn ? FontColor.InstructionDark : FontColor.InstructionLight
        
        // left instruction
        instructionLeftLabel = SKLabelNode(text: Text.TapToJump)
        instructionLeftLabel!.verticalAlignmentMode = .center
        instructionLeftLabel!.horizontalAlignmentMode = .center
        instructionLeftLabel!.fontName = FontName.Instruction
        instructionLeftLabel!.fontColor = instructionColor
        adjustFontSizeForLabel(instructionLeftLabel!, tofitSize: CGSize(
            width: instructionLabelWidth,
            height: instructionLabelHeight))
        instructionLeftLabel!.position = CGPoint(
            x: -(playableRect.width - verticalMiddleBarNode!.size.width)/4 - verticalMiddleBarNode!.size.width/2,
            y: playableRect.height * Geometry.InstructionLabelRelativeYPosition - playableRect.height/2)
        instructionLeftLabel!.name = NodeName.InstructionLabel
        instructionsUILayer.addChild(instructionLeftLabel!)
        
        // right instruction
        instructionRightLabel = SKLabelNode(text: Text.TapToJump)
        instructionRightLabel!.verticalAlignmentMode = .center
        instructionRightLabel!.horizontalAlignmentMode = .center
        instructionRightLabel!.fontName = FontName.Instruction
        instructionRightLabel!.fontColor = instructionColor
        adjustFontSizeForLabel(instructionRightLabel!, tofitSize: CGSize(
            width: instructionLabelWidth,
            height: instructionLabelHeight))
        instructionRightLabel!.position = CGPoint(
            x: +(playableRect.width - verticalMiddleBarNode!.size.width)/4 + verticalMiddleBarNode!.size.width/2,
            y: playableRect.height * Geometry.InstructionLabelRelativeYPosition - playableRect.height/2)
        instructionRightLabel!.name = NodeName.InstructionLabel
        instructionsUILayer.addChild(instructionRightLabel!)
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
        leftRing.startFloatingAnimation(verticalRange: verticalRange, durationPerCycle: Time.RingFloatingCycle, startUpward: true)
        ringsLayer.addChild(leftRing)
        // left ring goal node
        let leftRingGoal = getRingGoalForRing(leftRing)
        leftRingGoal.position = CGPoint(x: -ballHeight * Geometry.RingGoalRelativeLengthToCountPoint, y: 0)
        leftRing.addChild(leftRingGoal)

        // left ring joint
        let leftRingJoint = SKPhysicsJointFixed.joint(withBodyA: leftRingGoal.physicsBody!, bodyB: leftRing.physicsBody!, anchor: self.convert(leftRingGoal.position, from: leftRingGoal))
        physicsWorld.add(leftRingJoint)
        
        // RIGHT RING
        rightRing = RingNode(size: ringSize, color: ringColor, pointToRight: true)
        rightRing.position = CGPoint(x: +ringsSeparation/2 + abs(rightRing.size.width)/2, y: 0)
        rightRing.startFloatingAnimation(verticalRange: verticalRange, durationPerCycle: Time.RingFloatingCycle, startUpward: false)
        ringsLayer.addChild(rightRing)
        // right ring goal node
        let rightRingGoal = getRingGoalForRing(rightRing)
        rightRingGoal.position = CGPoint(x: -ballHeight * Geometry.RingGoalRelativeLengthToCountPoint, y: 0)
        rightRing.addChild(rightRingGoal)

        // right ring joint
        let rightRingJoint = SKPhysicsJointFixed.joint(withBodyA: rightRingGoal.physicsBody!, bodyB: rightRing.physicsBody!, anchor: self.convert(rightRingGoal.position, from: rightRingGoal))
        physicsWorld.add(rightRingJoint)
    }

    
    private func generateBalls() {
        let createBallsAction = SKAction.run {
            self.createNewBallForGame(screenSide: .left)
            self.createNewBallForGame(screenSide: .right)
        }

        let waitAction = SKAction.wait(forDuration: timeBetweenBalls)
        let sequenceAction = SKAction.sequence([createBallsAction, waitAction])

        run(sequenceAction) {
            [unowned self] in
            self.round += 1
            self.generateBalls()
        }
    }

    private func startGame() {
        gameState = .GameRunning
        
        updateLiveLeftNodes()
        
        removeInstructionLabels()
        
        activateRingsPhysics(withRandomImpulse: false)
        
        generateBalls()
    }
    
    // MARK: Update methods
    
    private func updateShownLayers() {
        switch gameState {
        case .GameMenu:
            
            gameOnlyUILayer.isHidden = true
            menuOnlyUILayer.isHidden = false
            instructionsUILayer.isHidden = true
            
            ringsLayer.isHidden = false
            ballsLayer.isHidden = false
            
        case .GameRunning:
            menuBallLeftNode?.removeFromParent()
            menuBallRightNode?.removeFromParent()
            menuBallLeftNode = nil
            menuBallRightNode = nil
            
            menuOnlyUILayer.isHidden = true
            gameOnlyUILayer.isHidden = false
            instructionsUILayer.isHidden = false
            
            ringsLayer.isHidden = false
            ballsLayer.isHidden = false
            
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
        
        // config buttons
        let configButtonColor = dark ? Color.ConfigButtonDark : Color.ConfigButtonLight
        darkColorsButtonNode?.color = configButtonColor
        musicOnButtonNode?.color = configButtonColor
        gravityNormalButtonNode?.color = configButtonColor
        removeAdsButtonNode?.color = configButtonColor
        gameCenterButtonNode?.color = configButtonColor
        moreGamesButtonNode?.color = configButtonColor
        selectBallButtonNode?.color = configButtonColor
        
        // GAME RUNNING
        // score label
        scoreLabel?.fontColor = dark ? FontColor.ScoreDark : FontColor.ScoreLight
        
        // pause button
        pauseButtonNode?.color = dark ? Color.TopLeftButtonDark : Color.TopLeftButtonLight
        
        // live left nodes
        updateLiveLeftNodes()
        
        // instruction labels
        let instructionLabelColor = dark ? FontColor.InstructionDark : FontColor.InstructionLight
        instructionLeftLabel?.fontColor = instructionLabelColor
        instructionRightLabel?.fontColor = instructionLabelColor
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

        for _ in 0..<(livesLeft - 1) {
            let liveLeftNode = SKSpriteNode(imageNamed: ImageFilename.LiveLeft)
            liveLeftNode.name = NodeName.LiveLeftNode
            liveLeftNode.color = darkColorsOn ? Color.LiveLeftDark : Color.LiveLeftLight
            liveLeftNode.colorBlendFactor = Color.BlendFactor
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameState == .GameMenu || gameState == .GamePaused {
            let touch = touches.first!
            let location = touch.location(in: self)
            let touchedNode = self.atPoint(location)
            
            if let nodeName = touchedNode.name {
                switch nodeName {
            
                case NodeName.PlayButton:
                    if isSoundActivated { run(buttonLargeSound) }
                    startGame()
                    
                case NodeName.QuitButton:
                    startNewGame()
                    
                case NodeName.ContinueButton:
                    if isSoundActivated { run(buttonLargeSound) }
                    unpauseGame()
                    
                case NodeName.DarkColorsOnOffButton:
                    if isSoundActivated { run(buttonSmallSound) }
                    darkColorsOn = !darkColorsOn
                    if let darkColorsNode = touchedNode as? SKSpriteNode {
                        darkColorsNode.texture = SKTexture(imageNamed: darkColorsOn ? ImageFilename.DarkColorsOn : ImageFilename.DarkColorsOff)
                    }
                    
                case NodeName.GravityNormalOnOffButton:
                    if isSoundActivated { run(buttonSmallSound) }
                    gravityNormal = !gravityNormal
                    if let gravityNormalNode = touchedNode as? SKSpriteNode {
                        gravityNormalNode.texture = SKTexture(imageNamed: gravityNormal ? ImageFilename.GravityNormalOn : ImageFilename.GravityNormalOff)
                    }
                    activateRingsPhysics(withRandomImpulse: true)
                    
                case NodeName.MusicOnOffButton:
                    isMusicOn = !isMusicOn
                    if let musicOnOffNode = touchedNode as? SKSpriteNode {
                        musicOnOffNode.texture = SKTexture(imageNamed: isMusicOn ? ImageFilename.MusicOnButton : ImageFilename.MusicOffButton)
                    }
                    if isSoundActivated { run(buttonSmallSound) }
                    
                case NodeName.RemoveAdsButton:
                    if isSoundActivated { run(buttonSmallSound) }
                    removeAdsRequest()
                    
                case NodeName.GameCenterButton:
                    if isSoundActivated { run(buttonSmallSound) }
                    gameCenterRequest()
                    
                case NodeName.MoreGamesButton:
                    if isSoundActivated { run(buttonSmallSound) }
                    moreGamesRequest()
                    
                case NodeName.SelectBallButton:
                    if isSoundActivated {
                        run(buttonSmallSound) {
                            self.startBallSelection(withScreenIndex: 0)
                        }
                    } else {
                        startBallSelection(withScreenIndex: 0)
                    }
                    
                case NodeName.BackToMenuButton:
                    if isSoundActivated {
                        run(buttonSmallSound) {
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
                let location = touch.location(in: self)
                let touchedNode = self.atPoint(location)
                
                if let nodeName = touchedNode.name {
                    switch nodeName {
                        
                    case NodeName.PauseButton:
                        if isSoundActivated {
                            run(pauseSound) {
                                self.pauseGame()
                            }
                        } else {
                            pauseGame()
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
                run(impulseSound)
            }
        }
    }
    
    // MARK: SKPhysicsContact Delegate

    func didBegin(_ contact: SKPhysicsContact) {
        let collision: UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if let ballNode = contact.bodyA.node as? BallNode ?? (contact.bodyB.node as? BallNode ?? nil) {
            
            if gameState == .GameRunning {

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
                        coinsCount += 1
                        if coinNodeFlashAction != nil {
                            coinNode?.run(coinNodeFlashAction!)
                        }
                        if coinsLabelFlashAction != nil {
                            coinsLabel?.run(coinsLabelFlashAction!)
                        }
                        if isSoundActivated { run(moneySound) }
                        
                    } else {
                        if isSoundActivated { run(ballCatchSound) }
                    }
                    score += 1
                }
            } else if gameState == .GameMenu {
                if collision == PhysicsCategory.Ball | PhysicsCategory.Ring {
                    ballNode.affectedByGravity = true
                    
                } else if collision == PhysicsCategory.Ball | PhysicsCategory.MiddleBar
                    || collision == PhysicsCategory.Ball | PhysicsCategory.Boundary {
                        if isSoundActivated { run(ballFailedSound) }
                        createNewBallForMenu()
                    
                } else if collision == PhysicsCategory.Ball | PhysicsCategory.RingGoal {
                    if isSoundActivated { run(ballCatchSound) }
                    createNewBallForMenu()
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
            leftRing?.physicsBody?.applyImpulse(getRingImpulse(ringNode: leftRing))
        } else if location.x > size.width/2 {
            rightRing?.physicsBody?.applyImpulse(getRingImpulse(ringNode: rightRing))
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
    
    private func getRingGoalForRing(_ ring: RingNode) -> SKSpriteNode {
        let ringGoal = SKSpriteNode(texture: nil, color: SKColor.clear, size: CGSize(
            width: 2,
            height: ring.size.height * Geometry.RingGoalRelativeHeight))
        ringGoal.physicsBody = SKPhysicsBody(rectangleOf: ringGoal.size)
        ringGoal.physicsBody!.categoryBitMask = PhysicsCategory.RingGoal
        ringGoal.physicsBody!.collisionBitMask = PhysicsCategory.None
        ringGoal.physicsBody!.contactTestBitMask = PhysicsCategory.Ball
        ringGoal.physicsBody!.affectedByGravity = false
        
        return ringGoal
    }
    
    func activateRingsPhysics(withRandomImpulse randomImpulse: Bool) {
        rightRing?.activatePhysics()
        leftRing?.activatePhysics()
        if randomImpulse {
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
        let ballNode = getNewBall(height: ballHeight, isSpecial: isSpecial)
        ballNode.position = self.getBallRandomPosition(ballNode: ballNode, screenSide: screenSide)
        ballsLayer.addChild(ballNode)
        
        ballNode.physicsBody?.velocity = getBallVelocity(
            withMultiplier: Physics.BallVelocityMultiplier,
            screenSide: screenSide)

        ballNode.run(getBallRotationAction(screenSide: screenSide), withKey: ActionKey.BallRotate)
    }
    
    private func createNewBallForMenu() {
        menuBallLeftNode?.removeFromParent()
        menuBallRightNode?.removeFromParent()
        menuBallLeftNode = nil
        menuBallRightNode = nil
        
        // LEFT
        menuBallLeftNode = getNewBall(height: ballHeight, isSpecial: false)
        menuBallLeftNode!.position = CGPoint( // ballsLayer position is at playableRect origin
            x: -menuBallLeftNode!.size.width/2,
            y: +playableRect.height/2)
        ballsLayer.addChild(menuBallLeftNode!)
        
        menuBallLeftNode!.physicsBody?.velocity = getBallVelocity(
            withMultiplier: Physics.MenuBallVelocityMultiplier,
            screenSide: .left)
        
        // RIGHT
        menuBallRightNode = getNewBall(height: ballHeight, isSpecial: false)
        menuBallRightNode!.position = CGPoint( // ballsLayer position is at playableRect origin
            x: +menuBallRightNode!.size.width/2 + playableRect.width,
            y: +playableRect.height/2)
        ballsLayer.addChild(menuBallRightNode!)
        
        menuBallRightNode!.physicsBody?.velocity = getBallVelocity(
            withMultiplier: Physics.MenuBallVelocityMultiplier,
            screenSide: .right)
        
        menuBallLeftNode!.run(getBallRotationAction(screenSide: .left), withKey: ActionKey.BallRotate)
        menuBallRightNode!.run(getBallRotationAction(screenSide: .right), withKey: ActionKey.BallRotate)
    }
    
    private func getBallRotationAction(screenSide: ScreenSide) -> SKAction {
        let angle = screenSide == .right ? +2*CGFloat.pi : -2*CGFloat.pi
        return SKAction.repeatForever(SKAction.rotate(byAngle: angle, duration: Time.BallRotate))
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
    
    private func getBallVelocity(withMultiplier multiplier: CGFloat, screenSide: ScreenSide) -> CGVector {
        let dx = playableRect.width * multiplier
        return CGVector(
            dx: screenSide == .left ? +dx : -dx,
            dy: 0)
    }

    private func getBallRandomPosition(ballNode: BallNode, screenSide: ScreenSide) -> CGPoint {
        let minY = UInt32(ballNode.size.height)
        let maxY = UInt32(playableRect.height - ballNode.size.height)

        return CGPoint(
            x: screenSide == .left ? -ballNode.size.width/2 : playableRect.width + ballNode.size.width/2,
            y: CGFloat(arc4random_uniform(maxY - minY) + minY))
    }
    
    private func ballFailed() {
        guard gameState == .GameRunning else { return }

        livesLeft -= 1
        guard livesLeft > 0 else { return gameOver() }

        if isSoundActivated {
            run(ballFailedSound)
        }
    }
    
    
      // ------------------------ //
     // -------- Labels -------- //
    // ------------------------ //
    
    // adjust top bar nodes relative to game title height
    func adjustLabelsSize() {
        
        let maxFontSize = getGameTitleFontSize()
        let maxSize = getGameTitleSize()
        
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
            let pauseButtonHeight = min(pauseButtonNode!.size.height, maxSize.height)
            pauseButtonNode!.size = CGSize(
                width: pauseButtonHeight * pauseButtonRatio,
                height: pauseButtonHeight)
        }
        if homeButtonNode != nil {
            let homeButtonRatio = homeButtonNode!.size.width / homeButtonNode!.size.height
            let homeButtonHeight = min(homeButtonNode!.size.height, maxSize.height)
            homeButtonNode!.size = CGSize(width: homeButtonRatio * homeButtonHeight, height: homeButtonHeight)
        }
        if titleLabel != nil {
            titleLabel!.fontSize = min(titleLabel!.fontSize, maxFontSize * Geometry.TitleLabelMaxRelativeFontSize)
        }
        updateLiveLeftNodes()
    }
    
    // TODO: can do better
    private func getGameTitleFontSize() -> CGFloat {
        if gameTitleLabel != nil {
            return gameTitleLabel!.fontSize
        } else {
            let gameTitleHeight = playableRect.height * Geometry.GameTitleRelativeHeight
            let gameTitleWidth = (playableRect.width)/2 * Geometry.GameTitleRelativeWidth
            let labelNode = SKLabelNode(text: Text.GameTitle)
            labelNode.fontName = FontName.GameTitle
            adjustFontSizeForLabel(labelNode, tofitSize: CGSize(width: gameTitleWidth, height: gameTitleHeight))
            return labelNode.fontSize
        }
    }
    
    // TODO: can do better
    private func getGameTitleSize() -> CGSize {
        if gameTitleLabel != nil {
            return gameTitleLabel!.frame.size
        } else {
            let gameTitleHeight = playableRect.height * Geometry.GameTitleRelativeHeight
            let gameTitleWidth = (playableRect.width)/2 * Geometry.GameTitleRelativeWidth
            let labelNode = SKLabelNode(text: Text.GameTitle)
            labelNode.fontName = FontName.GameTitle
            adjustFontSizeForLabel(labelNode, tofitSize: CGSize(width: gameTitleWidth, height: gameTitleHeight))
            return labelNode.frame.size
        }
    }
    
    func adjustFontSizeForLabel(_ labelNode: SKLabelNode, tofitSize size: CGSize) {
        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(size.width / labelNode.frame.width, size.height / labelNode.frame.height)
        
        // Set fit font size
        labelNode.fontSize = labelNode.fontSize * scalingFactor
    }
    
    // ------------------------------ //
    // -------- Instructions -------- //
    // ------------------------------ //
    
    private func removeInstructionLabels() {
        let waitAction = SKAction.wait(forDuration: Time.InstructionLabelWait)
        let fadeOutAction = SKAction.fadeOut(withDuration: Time.InstructionLabelFadeOut)
        let removeAction = SKAction.removeFromParent()
        let sequenceAction = SKAction.sequence([waitAction, fadeOutAction, removeAction])
        
        instructionLeftLabel?.run(sequenceAction)
        instructionRightLabel?.run(sequenceAction) {
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: UserDefaultsKey.ShowInstructions)
            defaults.synchronize()
        }
    }
    
    
      // ----------------------------- //
     // ------- MARK: Pausing ------- //
    // ----------------------------- //
    
    func pauseGame() {
        if gameState == .GameRunning {
            gameState = .GamePaused
            isPaused = true
//            if backgroundMusicPlayer.playing {
//                backgroundMusicPlayer.pause()
//            }
            
            // Display pause screen etc
            if pauseNode == nil {
                pauseButtonNode?.isHidden = true
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
            isPaused = false
            
//            if isMusicOn {
//                if !backgroundMusicPlayer.playing { backgroundMusicPlayer.play() }
//            }
            
            // Hide pause screen etc
            pauseNode?.removeFromParent()
            pauseNode = nil
            pauseButtonNode?.isHidden = false
        }
    }
    
    
    func registerAppTransitionObservers() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(applicationWillResignActive), name:UIApplication.willResignActiveNotification , object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func applicationWillResignActive() {
        if gameState == .GameRunning { // Pause the game if necessary
            pauseGame()
        }
    }
    
    @objc func applicationDidBecomeActive() {
        self.view?.isPaused = false // Unpause SKView. This is safe to call even if the view is not paused.
        if gameState == .GamePaused {
            isPaused = true
        }
        updateUI()
    }
    
    @objc func applicationDidEnterBackground() {
//        backgroundMusicPlayer.stop()
        self.view?.isPaused = true
    }
    
    // Unpausing the view automatically unpauses the scene (and the physics simulation). Therefore, we must manually pause the scene again, if the game is supposed to be in a paused state.
    @objc func applicationWillEnterForeground() {
        self.view?.isPaused = false //Unpause SKView. This is safe to call even if the view is not paused.
        if gameState == .GamePaused {
            isPaused = true
        }
    }
    
    // MARK: Deallocation
    
    override func willMove(from view: SKView) {
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Navigation

    func startNewGame() {
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
            run(self.gameOverSound) { self.startNewGame() }
        } else {
            startNewGame()
        }
    }
    
    func startBallSelection(withScreenIndex screenIndex: Int) {
        let ballSelectionScene = BallSelectionScene(
            size: size,
            bannerHeight: bannerHeight,
            screenIndex: screenIndex)
        ballSelectionScene.scaleMode = scaleMode
        ballSelectionScene.viewController = viewController
        view?.presentScene(ballSelectionScene)
    }

    private func removeAdsRequest() {
        if let gameViewController = viewController as? GameViewController {
            if view != nil && removeAdsButtonNode != nil && removeAdsButtonNode!.parent != nil {
                let sourceOriginInScene = self.convert(removeAdsButtonNode!.frame.origin, from: removeAdsButtonNode!.parent!)
                let sourceOriginInView = self.convertPoint(toView: sourceOriginInScene)
                let sourceRect = CGRect(origin: sourceOriginInView, size: removeAdsButtonNode!.size)
                gameViewController.removeAdsButtonPressed(sourceView: view!, sourceRect: sourceRect)
            }
        }
    }
    
    
    private func gameCenterRequest() {
        if let gameViewController = viewController as? GameViewController {
            gameViewController.leaderboardButtonPressed(sender: self)
        }
    }
    
    private func moreGamesRequest() {
        if let gameViewController = viewController as? GameViewController {
            gameViewController.moreGamesButtonPressed()
        }
    }

}
