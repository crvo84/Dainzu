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
    static let BestScoreLabelRelativeWidth: CGFloat = 0.30 // relative to playableRect width
    
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
    static let LivesLeftNodeRelativeSideOffset: CGFloat = 0.03 // relative to playableRect width

    // game title label
    static let GameTitleRelativeHeight: CGFloat = 0.25 // relative to playableRect height
    static let GameTitleRelativeWidth: CGFloat = 0.7 // relative to playableRect left side width
    static let GameTitleRelativeYPosition: CGFloat = 0.8 // relative to playableRect height
    
    // play button
    static let PlayButtonRelativeHeight: CGFloat = 0.28 // relative to playableRect height
    
    // config buttons
    static let ConfigButtonRelativeHeight: CGFloat = 0.6 // relative to gameTitleLabel height
    static let ConfigButtonRelativeHorizontalOffset: CGFloat = 0.06 // relative to playableRect width
    static let ConfigButtonRelativeVerticalOffset: CGFloat = 0.02 // relative to playableRect height
    static let ConfigButtonRelativeSeparation: CGFloat = 0.1 // relative to playableRect width
    // config select ball button
    static let ConfigSelectBallButtonRelativeHeight: CGFloat = 0.18 // relative to playableRect height
    
    // top left buttons
    static let TopLeftButtonRelativeHeight: CGFloat = 0.95 // relative to topBar height
    static let TopLeftButtonRelativeSideOffset: CGFloat = 0.04 // relative to playableRect width

    // pause node
    static let PauseNodeSmallButtonRelativeHeight: CGFloat = 0.11 // relative to pauseNode height
    static let PauseNodeSmallButtonRelativeSideOffset: CGFloat = 0.04 // relative to pauseNode height
    static let PauseNodeSmallButtonRelativeVerticalOffset: CGFloat = 0.07
    static let PauseNodeLargeButtonRelativeHeight: CGFloat = 0.20 // relative to pauseNode height
    
    // about app buttons
    static let AboutAppButtonsRelativeCornerRadius: CGFloat = 0.2 // relative to button width
    
    // instruction labels
    static let InstructionLabelRelativeWidth: CGFloat = 0.7 // relative to side screen width
    static let InstructionLabelRelativeHeight: CGFloat = 0.20 // relative to playableRect height
    static let InstructionLabelRelativeYPosition: CGFloat = 0.7 // relative to playableRect height
    
    // ball selection
    static let BallSelectionBallRelativeHeight: CGFloat = 0.15 // relative to playableRect height
    static let BallSelectionNumberOfRows: Int = 2 // 1
    static let BallSelectionNumberOfColumns: Int = 5 // 5
}

struct ZPosition {
    // Game Scene
    static let PauseNode: CGFloat = 300
    static let AlwaysVisibleUILayer: CGFloat = 250
    static let GameOnlyUILayer: CGFloat = 200
    static let MenuOnlyUILayer: CGFloat = 200
    static let InstructionsLayer: CGFloat = 200
    static let RingAbove: CGFloat = 110
    static let BallsLayer: CGFloat = 100
    static let RingsLayer: CGFloat = 90
    static let BarsLayer: CGFloat = 80
    
    // BallSelectionScene
    static let BallSelectionTopBarUILayer: CGFloat = 300
    static let BallSelectionGridLayer: CGFloat = 200
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
    static let BallNotPurchased = "questionMark"
    static let BallNextScreen = "arrowRight"
    static let Facebook = "facebook"
    static let Twitter = "twitter"
}

struct BallImage {
    static let Ball_0 = "ocean-yellow-marble"
    // bot
    static let Ball_A1 = "bot-orange-marble"
    static let Ball_A2 = "bot-light-green-marble"
    static let Ball_A3 = "bot-blue-marble"
    static let Ball_A4 = "bot-green-marble"
    static let Ball_A5 = "bot-black-marble"
    static let Ball_A6 = "bot-pink-marble"
    static let Ball_A7 = "bot-purple-marble"
    static let Ball_A8 = "bot-red-marble"
    static let Ball_A9 = "bot-brown-marble"
    // creature
    static let Ball_B1 = "creature-cat-marble"
    static let Ball_B2 = "creature-angry-marble"
    static let Ball_B3 = "creature-creepy-nerd-marble"
    static let Ball_B4 = "creature-devil-marble"
    static let Ball_B5 = "creature-dog-marble"
    static let Ball_B6 = "creature-eye-ghost-marble"
    static let Ball_B7 = "creature-mouse-marble"
    static let Ball_B8 = "creature-skull-marble"
    static let Ball_B9 = "creature-spiky-marble"
    // ocean
    static let Ball_C1 = "ocean-black-marble"
    static let Ball_C2 = "ocean-blue-marble"
    static let Ball_C3 = "ocean-brown-marble"
    static let Ball_C4 = "ocean-dark-blue-marble"
    static let Ball_C5 = "ocean-green-marble"
    static let Ball_C6 = "ocean-light-green-marble"
    static let Ball_C7 = "ocean-orange-marble"
    static let Ball_C8 = "ocean-red-marble"
    static let Ball_C9 = "ocean-purple-marble"
    // monster
    static let Ball_D1 = "monster-1-marble"
    static let Ball_D2 = "monster-2-marble"
    static let Ball_D3 = "monster-3-marble"
    static let Ball_D4 = "monster-4-marble"
    static let Ball_D5 = "monster-5-marble"
    static let Ball_D6 = "monster-6-marble"
    static let Ball_D7 = "monster-7-marble"
    static let Ball_D8 = "monster-8-marble"
    static let Ball_D9 = "monster-9-marble"
    // glossy
    static let Ball_E1 = "glossy-black-marble"
    static let Ball_E2 = "glossy-blue-marble"
    static let Ball_E3 = "glossy-brown-marble"
    static let Ball_E4 = "glossy-green-marble"
    static let Ball_E5 = "glossy-orange-marble"
    static let Ball_E6 = "glossy-pink-marble"
    static let Ball_E7 = "glossy-purple-marble"
    static let Ball_E8 = "glossy-red-marble"
    static let Ball_E9 = "glossy-yellow-marble"
    // funny
    static let Ball_F1 = "funny-black-marble"
    static let Ball_F2 = "funny-blue-marble"
    static let Ball_F3 = "funny-brown-marble"
    static let Ball_F4 = "funny-pink-marble"
    static let Ball_F5 = "funny-green-marble"
    static let Ball_F6 = "funny-greenB-marble"
    static let Ball_F7 = "funny-orange-marble"
    static let Ball_F8 = "funny-red-marble"
    static let Ball_F9 = "funny-yellow-marble"
    
    
    static let Ball_Special = Ball_0 // coin
    static let Ball_Default = Ball_A1
    
    // screens
    static let ScreenA: [String] = [BallImage.Ball_Default, BallImage.Ball_A8, BallImage.Ball_A3, BallImage.Ball_A2, BallImage.Ball_A5, BallImage.Ball_A6, BallImage.Ball_A7, BallImage.Ball_A4, BallImage.Ball_A9, BallImage.NextScreenButton]
    
    static let ScreenB: [String] = [BallImage.PreviousScreenButton, BallImage.Ball_B7, BallImage.Ball_B2, BallImage.Ball_B3, BallImage.Ball_B4, BallImage.Ball_B6, BallImage.Ball_B1, BallImage.Ball_B8, BallImage.Ball_B9, BallImage.NextScreenButton]
    
    static let ScreenC: [String] = [BallImage.PreviousScreenButton, BallImage.Ball_C1, BallImage.Ball_C2, BallImage.Ball_C3, BallImage.Ball_C4, BallImage.Ball_C5, BallImage.Ball_C7, BallImage.Ball_C8, BallImage.Ball_C9, BallImage.NextScreenButton]
    
    static let ScreenD: [String] = [BallImage.PreviousScreenButton, BallImage.Ball_D1, BallImage.Ball_D2, BallImage.Ball_D3, BallImage.Ball_D4, BallImage.Ball_D5, BallImage.Ball_D6, BallImage.Ball_D7, BallImage.Ball_D9, BallImage.NextScreenButton]
    
    static let ScreenE: [String] = [BallImage.PreviousScreenButton, BallImage.Ball_E1, BallImage.Ball_E2, BallImage.Ball_E3, BallImage.Ball_E4, BallImage.Ball_E5, BallImage.Ball_E7, BallImage.Ball_E8, BallImage.Ball_E9, BallImage.NextScreenButton]
    
    static let ScreenF: [String] = [BallImage.PreviousScreenButton, BallImage.Ball_F1, BallImage.Ball_F2, BallImage.Ball_F3, BallImage.Ball_F4, BallImage.Ball_F5, BallImage.Ball_F7, BallImage.Ball_F8, BallImage.Ball_F6, BallImage.Ball_F9]
    
    
    // all screens (order screens here)
    static let Screens: [Int : [String]] = [0 : BallImage.ScreenA, 1 : BallImage.ScreenB, 2: BallImage.ScreenC, 3: BallImage.ScreenD, 4: BallImage.ScreenE, 5: BallImage.ScreenF]
    
    // navigation buttons
    static let NextScreenButton = "ballSelectionNextScreen"
    static let PreviousScreenButton = "ballSelectionPreviousScreen"
    
    // special images
    static let FacebookBall = BallImage.Ball_A2
    static let TwitterBall = BallImage.Ball_B1
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
    static let BallBounciness: CGFloat = 0.6
    static let BallVelocityMultiplier: CGFloat = 0.2 // 0.5
    // menu ball
    static let MenuBallVelocityMultiplier: CGFloat = 0.1
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
    static let BallRotate: Double = 3
    static let BallFadeOut: Double = 0.3
    static let BallsWaitInitial: Double = 3
    static let BallsWaitDecrease: Double = 0.1
    static let BallsWaitMinimum: Double = 2
    // menu ball
    static let MenuBallWait: Double = 5
    static let MenuBallRotate: Double = 5
    static let MenuBallFadeOut: Double = 0.5
    // coin count
    static let CoinsLabelFlashAction: Double = 0.2
    // score label
    static let ScoreLabelFlashAction: Double = 0.2
    // instruction label
    static let InstructionLabelWait: Double = 4
    static let InstructionLabelFadeOut: Double = 0.4
}

struct Color {
    // -------------------------------------------------------------------------------- //
    static let BackgroundDark = SKColor(red: 0, green: 0, blue: 0.1, alpha: 1.0)
    static let BackgroundLight = SKColor(red: 202.0/255.0, green: 240.0/255.0, blue: 255.0/255.0, alpha: 1.0)

    static let BarDark: SKColor = SKColor(red: 192.0/255.0, green: 95.0/255.0, blue: 0.0, alpha: 1.0)
    static let BarLight: SKColor = SKColor(red: 5.0/255.0, green: 62.0/255.0, blue: 84.0/255.0, alpha: 1.0)
    
    static let RingDark: SKColor = SKColor(red: 43.0/255.0, green: 150.0/255.0, blue: 192.0/255.0, alpha: 1.0)
    static let RingLight: SKColor = SKColor(red: 255.0/255.0, green: 64.0/255.0, blue: 82.0/255.0, alpha: 1.0)
    
    static let ConfigButtonDark: SKColor = SKColor.orange
    static let ConfigButtonLight: SKColor = SKColor(red: 6.0/255.0, green: 81.0/255.0, blue: 111.0/255.0, alpha: 1.0)
    
    static let BlendFactor: CGFloat = 1.0
    // -------------------------------------------------------------------------------- //
    
    static let LiveLeftDark: SKColor = Color.BackgroundDark
    static let LiveLeftLight: SKColor = Color.BackgroundLight
    
    static let PlayButtonDark: SKColor = Color.ConfigButtonDark
    static let PlayButtonLight: SKColor = Color.ConfigButtonLight
    
    static let TopLeftButtonDark: SKColor = Color.BackgroundDark
    static let TopLeftButtonLight: SKColor = Color.BackgroundLight
    
    // Pause node
    static let PauseNodeBackground: SKColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.95)
    static let PauseNodeSmallButtonDark: SKColor = Color.ConfigButtonDark
    static let PauseNodeSmallButtonLight: SKColor = Color.BackgroundLight
    static let PauseNodeLargeButtonDark: SKColor = Color.ConfigButtonDark
    static let PauseNodeLargeButtonLight: SKColor = Color.BackgroundLight
    
    // ball selection
    static let BallSelectionNotPurchasedDark: SKColor = Color.RingDark
    static let BallSelectionNotPurchasedLight: SKColor = Color.RingLight
    static let BallSelectionButtonDark: SKColor = Color.ConfigButtonDark
    static let BallSelectionButtonLight: SKColor = Color.ConfigButtonLight
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
    
    static let InstructionDark: SKColor = Color.RingDark
    static let InstructionLight: SKColor = Color.RingLight
}

struct FontName {
    static let GameTitle = "Snaps Taste"
    static let Title = "Snaps Taste"
    static let Score = "Snaps Taste"
    static let BestScore = "Snaps Taste"
    static let Coins = "Snaps Taste"
    static let Instruction = "Snaps Taste"
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
    static let InstructionLabel = "instructionLabelNode"
}

struct SegueId {
    static let About = "aboutSegue"
//    static let ExitAbout = "exitAboutSegue" // currently not used
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
    static let ShowInstructions = "showInstructions"
    static let CoinsCount = "coinsCount"
    static let BestScore = "bestScore"
    static let BallDefault = BallImage.Ball_Default
    static let BallSelected = "ballSelected"
}

struct UserDefaultsInitialValues {
    // default values
    static let ShowAds = false // TODO: set 'true' to enable Ads
    static let MusicOn = true
    static let DarkColorsOn = false
    static let GravityNormal = true
    static let ShowInstructions = true
    static let CoinsCount: Int = 0
    static let BestScore: Int = 0
    // ball purchased
    static let BallSelected: String = BallImage.Ball_Default
    static let BallDefault = true
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
    static let SelectBall = "Marbles"
    static let TapToJump = "Tap to jump"
    
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
    static let SpecialBallsRatio: UInt32 = 10 // 10 // 1 in X
    static let ResetVelocityBeforeImpulse = true
    static let LivesNum: Int = 3 // 3
    static let BallPrice: Int = 20 // 20
    static let RoundsPerLevel: Int = 5
}

struct Test {
    static let TestModeOn = false
}
