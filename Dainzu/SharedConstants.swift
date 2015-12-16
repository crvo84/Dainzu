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
    static let PlayableRectRatio: CGFloat = 2.25
    
    // bars
    static let TopRelativeHeightAssignedBeforeBottomBar: CGFloat = 0.1 // relative to playableRect height
    static let VerticalMiddleBarRelativeWidth: CGFloat = 0.02 // relative to playableRect width
    
    // score label
    static let ScoreLabelRelativeHeight: CGFloat = 0.7 // relative to topBar height
    static let ScoreLabelRelativeWidth: CGFloat = 0.30 // relative to playableRect width
    
    // best score label
    static let BestScoreLabelRelativeHeight: CGFloat = 0.7 // relative to topBar height
    static let BestScoreLabelRelativeWidth: CGFloat = 0.5 // relative to playableRect width
    
    // coins label
    static let CoinNodeRelativeHeight: CGFloat = 0.45 // relative to topBar height
    static let CoinNodeRelativeSideOffset: CGFloat = 0.02 // relative to playableRect width
    static let CoinsLabelRelativeSideOffset: CGFloat = 0.25 // relative to coinNode width
    static let CoinsLabelRelativeHeight: CGFloat = 0.5 // relative to topBar height
    static let CoinsLabelRelativeWidth: CGFloat = 0.20 // relative to playableRect width
    static let CoinsLabelFlashActionMaxScale: CGFloat = 1.5

    // main title label
    static let MainTitleRelativeHeight: CGFloat = 0.25 // relative to playableRect height
    static let MainTitleRelativeWidth: CGFloat = 0.7 // relative to playableRect left side width
    static let MainTitleRelativeYPosition: CGFloat = 0.8 // relative to playableRect height
    
    // play button
    static let PlayButtonRelativeHeight: CGFloat = 0.35 // relative to playableRect height
    
    // pause button
    static let PauseButtonRelativeHeight: CGFloat = 0.7 // relative to topBar height
    static let PauseButtonRelativeSideOffset: CGFloat = 0.02 // relative to playableRect width
    
    // pause node
    static let PauseNodeSmallButtonRelativeHeight: CGFloat = 0.15 // relative to pauseNode height
    static let PauseNodeSmallButtonRelativeSideOffset: CGFloat = 0.02 // relative to pauseNode height
    static let PauseNodeLargeButtonRelativeHeight: CGFloat = 0.3 // relative to pauseNode height
}

struct ZPosition {
    static let PauseNode: CGFloat = 300
    static let AlwaysVisibleUILayer: CGFloat = 250
    static let GameOnlyUILayer: CGFloat = 200
    static let MenuOnlyUILayer: CGFloat = 200
    static let RingAbove: CGFloat = 110
    static let BallsLayer: CGFloat = 100
    static let RingsLayer: CGFloat = 90
    static let BarsLayer: CGFloat = 80
}

struct ImageFilename {
    static let PlayButton = "playButton"
    static let PauseButton = "pauseButton"
    static let QuitButton = "homeButton"
    static let ContinueButton = "playButton"
    static let MusicOnButton = "musicOnButton"
    static let MusicOffButton = "musicOffButton"
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
}

struct PhysicsCategory {
    static let None:        UInt32 = 0
    static let Ring:        UInt32 = 0b1
    static let RingGoal:    UInt32 = 0b10
    static let Boundary:    UInt32 = 0b100
    static let MiddleBar:   UInt32 = 0b1000
    static let Ball:        UInt32 = 0b10000
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
}

struct Color {
    static let BackgroundDark = SKColor(red: 0, green: 0, blue: 0.1, alpha: 1.0)
    static let BackgroundLight = SKColor(red: 202.0/255.0, green: 240.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    static let BottomBarDark: SKColor = SKColor.orangeColor()
    static let BottomBarLight: SKColor = SKColor(red: 3.0/255.0, green: 41.0/255.0, blue: 56.0/255.0, alpha: 1.0)
    
    static let TopBarDark: SKColor = Color.BottomBarDark
    static let TopBarLight: SKColor = Color.BottomBarLight
    
    static let VerticalMiddleBarDark: SKColor = Color.BottomBarDark
    static let VerticalMiddleBarLight: SKColor = Color.BottomBarLight
    
    static let RingDark: SKColor = Color.BottomBarDark
    static let RingLight: SKColor = Color.BottomBarLight
    
    static let BallDark: SKColor = SKColor.whiteColor()
    static let BallLight: SKColor = SKColor.orangeColor()
    
    static let BallSpecial: SKColor = SKColor.yellowColor()
    
    static let PlayButtonDark: SKColor = Color.BottomBarDark
    static let PlayButtonLight: SKColor = Color.BottomBarLight
    static let PlayButtonBlendFactor: CGFloat = 0.5
    
    static let PauseButtonDark: SKColor = Color.BackgroundDark
    static let PauseButtonLight: SKColor = Color.BackgroundLight
    static let PauseButtonBlendFactor: CGFloat = 0.5
    static let PauseNodeBackground: SKColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.95)
}

struct FontColor {
    static let MainTitleDark: SKColor = Color.BackgroundLight
    static let MainTitleLight: SKColor = Color.BackgroundDark
    
    static let ScoreDark: SKColor = Color.BackgroundDark
    static let ScoreLight: SKColor = Color.BackgroundLight
    
    static let BestScoreDark: SKColor = Color.BackgroundDark
    static let BestScoreLight: SKColor = Color.BackgroundLight
    
    static let CoinsDark: SKColor = SKColor.whiteColor()
    static let CoinsLight: SKColor = SKColor.whiteColor()
}

struct FontName {
    static let MainTitle = "Snaps Taste"
    static let Score = "Snaps Taste"
    static let BestScore = "Snaps Taste"
    static let Coins = "Snaps Taste"
}

struct NodeName {
    static let Ring = "ringNode"
    static let RingPart = "ringPartNode"
    static let Ball = "ballNode"
    static let Boundary = "boundaryNode"
    static let BestScoreLabel = "bestScoreLabel"
    static let MainTitleLabel = "mainTitleLabel"
    static let PlayButton = "playButtonNode"
    static let PauseButton = "pauseButtonNode"
    static let QuitButton = "quitButtonNode"
    static let ContinueButton = "continueButtonNode"
    static let MusicOnOffButton = "musicOnOffButtonNode"
    
    // TODO: Test
    static let TestButton1 = "testButton1"
    static let TestButton2 = "testButton2"
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
}

struct UserDefaults {
    // default values
    static let ShowAds_Initial = true
    static let MusicOn_Initial = true
    static let DarkColorsOn = false
    static let GravityNormal = true
    static let CoinsCount: Int = 0
    static let BestScore: Int = 0
}

struct Text {
    static let BestScore = "Best"
    static let MainTitle = "Dainzu"
}

struct GameOption {
    static let SpecialBallsOn = true
    static let SpecialBallsRatio: UInt32 = 10 // 1 in X
    static let ResetVelocityBeforeImpulse = true
}

struct Test {
    static let TestModeOn = true
}
