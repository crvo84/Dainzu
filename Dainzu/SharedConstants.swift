//
//  SharedConstants.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/9/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import SpriteKit

struct Geometry {
    // rings
    static let RingsRelativeSeparation: CGFloat = 0.07 // total rings separation. Rel to playableRect width
    static let RingRelativeHeight: CGFloat = 0.25 // Rel to playableRect height
    static let RingRatio: CGFloat = 0.3 // ring width/height
    static let RingRelativeStrokeWidth: CGFloat = 0.1 // Relative to ring height
    static let RingAngle: CGFloat = 0 // π/32 // Angle added to original position
    static let RingRelativeFloatingVerticalRange: CGFloat = 0.1 // relative to ringNode height
    
    // ring goal
    static let RingGoalRelativeLengthToCountPoint: CGFloat = 0.5 // Rel to ballNode height
    static let RingGoalRelativeHeight: CGFloat = 0.7 // Rel to ringNode height
    
    // balls
    static let BallRelativeHeight: CGFloat = 0.11 // Rel to playableRect height
    static let BallPhysicsBodyRelativeRadius: CGFloat = 0.5 // Rel to ballNode height
    
    // device
    static let DeviceBaseHeight: CGFloat = 320 // iPhone 5s landscape height (base to calculate gravity)
    
    // playableRect
    static let PlayableRectRatio: CGFloat = 2.2
    
    // bars
    static let TopRelativeHeightAssignedBeforeBottomBar: CGFloat = 0.1 // relative to playableRect height
    static let VerticalMiddleBarRelativeWidth: CGFloat = 0.02 // relative to playableRect width
    
    // score label
    static let ScoreLabelRelativeHeight: CGFloat = 0.7 // relative to topBar height
    static let ScoreLabelRelativeWidth: CGFloat = 0.30 // relative to playableRect width
    static let ScoreLabelMaxRelativeFontSize: CGFloat = 0.8 // relative to gameTitle font size
    static let ScoreLabelFlashActionMaxScale: CGFloat = 1.3
    
//    // best score label
    static let BestScoreLabelRelativeHeight: CGFloat = 0.7 // relative to topBar height
    static let BestScoreLabelRelativeWidth: CGFloat = 0.5 // relative to playableRect width
    
    // title
    static let TitleLabelRelativeHeight: CGFloat = 0.7 // relative to topBar height
    static let TitleLabelRelativeWidth: CGFloat = 0.5 // relative to playableRect width
    static let TitleLabelMaxRelativeFontSize: CGFloat = 0.8 // relative to gameTitle font size
    
    // coins label
    static let CoinNodeRelativeHeight: CGFloat = 0.45 // relative to topBar height
    static let CoinNodeRelativeSideOffset: CGFloat = 0.02 // relative to playableRect width
    static let CoinsLabelMaxRelativeFontSize: CGFloat = 0.7 // relative to gameTitle font size
    static let CoinsLabelRelativeSideOffset: CGFloat = 0.25 // relative to coinNode width
    static let CoinsLabelRelativeHeight: CGFloat = 0.6 // relative to topBar height
    static let CoinsLabelRelativeWidth: CGFloat = 0.20 // relative to playableRect width
    static let CoinsLabelFlashActionMaxScale: CGFloat = 1.5
    
    // lives left nodes
    static let LivesLeftNodeRelativeHeight: CGFloat = 0.8 // relative to topBar height
    static let LivesLeftNodeMaxRelativeHeight: CGFloat = 0.7 // relative to gameTitle height
    static let LivesLeftNodeRelativeSeparation: CGFloat = 0.01 // relative to playableRect width

    // game title label
    static let GameTitleRelativeHeight: CGFloat = 0.25 // relative to playableRect height
    static let GameTitleRelativeWidth: CGFloat = 0.7 // relative to playableRect left side width
    static let GameTitleRelativeYPosition: CGFloat = 0.8 // relative to playableRect height
    
    // play button
    static let PlayButtonRelativeHeight: CGFloat = 0.28 // relative to playableRect height
    
    // config buttons
    static let ConfigButtonRelativeHeight: CGFloat = 0.7 // relative to gameTitleLabel height
    static let ConfigSelectBallButtonRelativeHeight: CGFloat = 1.3 // relative to regular config button height
    
    // top left buttons
    static let TopLeftButtonRelativeHeight: CGFloat = 0.95 // relative to topBar height
    static let TopLeftButtonRelativeSideOffset: CGFloat = 0.02 // relative to playableRect width

    // pause node
    static let PauseNodeSmallButtonRelativeHeight: CGFloat = 0.12 // relative to pauseNode height
    static let PauseNodeSmallButtonRelativeSideOffset: CGFloat = 0.04 // relative to pauseNode height
    static let PauseNodeSmallButtonRelativeVerticalOffset: CGFloat = 0.07
    static let PauseNodeLargeButtonRelativeHeight: CGFloat = 0.20 // relative to pauseNode height
    
    
    // about app buttons
    static let AboutAppButtonsRelativeCornerRadius: CGFloat = 0.2 // relative to button width
}

struct ZPosition {
    static let PauseNode: CGFloat = 300
    static let AlwaysVisibleUILayer: CGFloat = 250
    static let BallSelectionUILayer: CGFloat = 200
    static let GameOnlyUILayer: CGFloat = 200
    static let MenuOnlyUILayer: CGFloat = 200
    static let RingAbove: CGFloat = 110
    static let BallsLayer: CGFloat = 100
    static let RingsLayer: CGFloat = 90
    static let BarsLayer: CGFloat = 80
}

struct SoundFilename {
    static let Impulse = "impulse.wav"
    static let Money = "Shine Collect.wav"
    static let BallCatch = "menuSelectionClick.wav"
    static let ButtonLarge = "largeButton.wav"
    static let ButtonSmall = "manutsClick.wav"
    static let BallFailed = "Button Click.wav"
    static let Pause = "landHint.wav"
    static let Success = "success7.mp3"
    static let GameOver = "gameOverDainzu.wav"
}

struct ImageFilename {
    static let PlayButton = "play"
    static let PauseButton = "pause"
    static let QuitButton = "home"
    static let ContinueButton = "play"
    static let MusicOnButton = "musicOn"
    static let MusicOffButton = "musicOff"
    static let GravityNormalOn = "arrowDown"
    static let GravityNormalOff = "arrowUp"
    static let DarkColorsOn = "moon"
    static let DarkColorsOff = "sun"
    static let RemoveAdsButton = "shoppingCart"
    static let GameCenterButton = "leaderboard"
    static let MoreGamesButton = "iphone"
    static let LiveLeft = "heart"
    static let HomeButton = "home"
    static let TouchScreen = "touchScreen"
    static let SelectBallButton = "plusBall"
}

struct BallImage {
    static let Ball_Special = "pacman"
    static let Ball_1 = "tennisBall"
    
    static let Balls = [BallImage.Ball_1]
}

struct Physics {
    // world
    static let GravityBaseY: CGFloat = -5
    // ring
    static let RingDensity: CGFloat = 10
    static let RingBounciness: CGFloat = 0.0
    static let RingLinearDamping: CGFloat = 0.0
    static let RingImpulseMultiplier: CGFloat = 0.9
    // ball
    static let BallDensity: CGFloat = 4
    static let BallLinearDamping: CGFloat = 0.0
    static let BallVelocityMultiplier: CGFloat = 0.2 // 0.5
    static let BallBounciness: CGFloat = 0.6
}

struct PhysicsCategory {
    static let None:        UInt32 = 0
    static let Ring:        UInt32 = 0b1
    static let RingGoal:    UInt32 = 0b10
    static let Boundary:    UInt32 = 0b100
    static let MiddleBar:   UInt32 = 0b1000
    static let Ball:        UInt32 = 0b10000
    static let MenuBoundary:UInt32 = 0b100000
    static let All:         UInt32 = UInt32.max
}

struct Time {
    // ring
    static let RingFloatingCycle: Double = 2
    // ball
    static let BallsWait: Double = 3
    
    static let BallRotate: Double = 3
    static let BallFadeOut: Double = 0.3
    // coin count
    static let CoinsLabelFlashAction: Double = 0.2
    // score label
    static let ScoreLabelFlashAction: Double = 0.2
}

struct Color {
    // -------------------------------------------------------------------------------- //
    static let BackgroundDark = SKColor(red: 0, green: 0, blue: 0.1, alpha: 1.0)
    static let BackgroundLight = SKColor(red: 202.0/255.0, green: 240.0/255.0, blue: 255.0/255.0, alpha: 1.0)

    static let BarDark: SKColor = SKColor.orangeColor()
    static let BarLight: SKColor = SKColor(red: 3.0/255.0, green: 41.0/255.0, blue: 56.0/255.0, alpha: 1.0)
    
    static let RingDark: SKColor = SKColor(red: 43.0/255.0, green: 150.0/255.0, blue: 192.0/255.0, alpha: 1.0)
    static let RingLight: SKColor = SKColor(red: 255.0/255.0, green: 64.0/255.0, blue: 82.0/255.0, alpha: 1.0)
    // -------------------------------------------------------------------------------- //
    
    static let LiveLeftDark: SKColor = Color.BackgroundDark
    static let LiveLeftLight: SKColor = Color.BackgroundLight
    static let LiveLeftBlendFactor: CGFloat = 1.0
    
    static let PlayButtonDark: SKColor = Color.BarDark
    static let PlayButtonLight: SKColor = Color.BarLight
    static let PlayButtonBlendFactor: CGFloat = 1.0
    
    static let TopLeftButtonDark: SKColor = Color.BackgroundDark
    static let TopLeftButtonLight: SKColor = Color.BackgroundLight
    static let TopLeftButtonBlendFactor: CGFloat = 1.0
    
    static let ConfigButtonDark: SKColor = Color.BarDark
    static let ConfigButtonLight: SKColor = Color.BarLight
    static let ConfigButtonBlendFactor: CGFloat = Color.PlayButtonBlendFactor
    
    // Pause node
    static let PauseNodeBackground: SKColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.95)
    static let PauseNodeSmallButtonDark: SKColor = Color.BarDark
    static let PauseNodeSmallButtonLight: SKColor = Color.BackgroundLight
    static let PauseNodeSmallButtonBlendFactor: CGFloat = 1.0
    static let PauseNodeLargeButtonDark: SKColor = Color.BarDark
    static let PauseNodeLargeButtonLight: SKColor = Color.BackgroundLight
    static let PauseNodeLargeButtonBlendFactor: CGFloat = 1.0
}

struct FontColor {
    static let GameTitleDark: SKColor = Color.RingDark
    static let GameTitleLight: SKColor = Color.RingLight
    
    static let ScoreDark: SKColor = Color.BackgroundDark
    static let ScoreLight: SKColor = Color.BackgroundLight
    
    static let BestScoreDark: SKColor = Color.BackgroundDark
    static let BestScoreLight: SKColor = Color.BackgroundLight
    
    static let TitleDark: SKColor = Color.BackgroundDark
    static let TitleLight: SKColor = Color.BackgroundLight
    
    static let CoinsDark: SKColor = Color.BackgroundDark
    static let CoinsLight: SKColor = Color.BackgroundLight
}

struct FontName {
    static let GameTitle = "Snaps Taste"
    static let Title = "Snaps Taste"
    static let Score = "Snaps Taste"
    static let BestScore = "Snaps Taste"
    static let Coins = "Snaps Taste"
}

struct NodeName {
    static let Ring = "ringNode"
    static let RingPart = "ringPartNode"
    static let Ball = "ballNode"
    static let SelectBallButton = "selectBallButtonNode"
    static let Boundary = "boundaryNode"
    static let BestScoreLabel = "bestScoreLabel"
    static let GameTitleLabel = "gameTitleLabel"
    static let LiveLeftNode = "liveLeftNode"
    static let PlayButton = "playButtonNode"
    static let PauseButton = "pauseButtonNode"
    static let QuitButton = "quitButtonNode"
    static let ContinueButton = "continueButtonNode"
    static let MusicOnOffButton = "musicOnOffButtonNode"
    static let DarkColorsOnOffButton = "darkColorsOnOffButtonNode"
    static let GravityNormalOnOffButton = "gravityNormalOnOffButtonNode"
    static let RemoveAdsButton = "removeAdsButtonNode"
    static let GameCenterButton = "gameCenterButtonNode"
    static let MoreGamesButton = "moreGamesButtonNode"
    static let HomeButton = "homeButtonNode"
    static let BackToMenuButton = "backToMenuButtonNode"
}

struct SegueId {
    static let About = "aboutSegue"
    static let ExitAbout = "exitAboutSegue"
}

struct ActionKey {
    static let RingFloatingAnimation = "ringFloatingAnimation"
    static let BallsGeneration = "ballsGenerationAction"
    static let BallRotate = "ballRotateAction"
}

struct UserDefaultsKey {
    static let ShowAds = "showAds"
    static let MusicOn = "musicOn"
    static let DarkColorsOn = "darkColorsOn"
    static let GravityNormal = "gravityNormal"
    static let CoinsCount = "coinsCount"
    static let BestScore = "bestScore"
    static let BallSelected = "ballSelected"
}

struct UserDefaults {
    // default values
    static let ShowAds = true
    static let MusicOn = true
    static let DarkColorsOn = false
    static let GravityNormal = true
    static let CoinsCount: Int = 0
    static let BestScore: Int = 0
    static let BallSelected: String = BallImage.Ball_1
}

struct URLString {
    static let AppStoreRate = "itms-apps://itunes.apple.com/app/id1068384300"
    
    static let FacebookFromApp = "fb://profile/800203350077160"
    static let Facebook = "https://www.facebook.com/800203350077160"
    static let TwitterFromApp = "twitter:///user?screen_name=Villou_Apps"
    static let Twitter = "https://twitter.com/Villou_Apps"
    static let Villou = "http://www.villou.com"
    
    static let MrMarketAppStore = "itms-apps://itunes.apple.com/app/id1033738154"
    static let HiInvestAppStore = "itms-apps://itunes.apple.com/app/id1009148607"
}

struct Text {
    static let GameTitle = "Dainzu"
    static let BestScore = "Best"
    static let HowToPlay = "How to play"
    static let SelectBall = "Select ball"
    
    static let RemoveAds = NSLocalizedString("Remove Ads", comment: "For a button, to pay to remove advertising.")
    static let Purchase = NSLocalizedString("Purchase", comment: "Verb. For a button, to purchase a product")
    static let Restore = NSLocalizedString("Restore", comment: "Verb. For a button to restore previous purchases.")
    static let Cancel = NSLocalizedString("Cancel", comment: "Verb. For a button to cancel an operation")
    static let PurchasesRestored = NSLocalizedString("Purchases restored successfully.", comment: "For an alert view message.")
    static let NoPreviousPurchases = NSLocalizedString("No previous purchases could be restored.", comment: "For an alert view message.")
    static let Ok = NSLocalizedString("Ok", comment: "For a button to close an alert view.")
}

struct InAppPurchase {
    static let RemoveAdsProductId = "DainzuRemoveAds"
}

struct GameCenter {
    static let LeaderboardId = "Dainzu_001"
}

struct GameOption {
    static let SpecialBallsOn = true
    static let SpecialBallsRatio: UInt32 = 10 // 1 in X
    static let ResetVelocityBeforeImpulse = true
    static let LivesNum: Int = 3
}

struct Test {
    static let TestModeOn = true
}
