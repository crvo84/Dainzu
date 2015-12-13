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
    static let RingRelativeHeight: CGFloat = 0.2 // Rel to playableRect height
    static let RingRatio: CGFloat = 0.25 // ring width/height
    static let RingRelativeStrokeWidth: CGFloat = 0.1 // Relative to ring height
    static let RingAngle: CGFloat = 0 // π/32 // Angle added to original position
    static let RingRelativeFloatingVerticalRange: CGFloat = 0.1 // relative to ringNode height
    
    // ring goal
    static let RingGoalRelativeLengthToCountPoint: CGFloat = 0.5 // Rel to ballNode height
    static let RingGoalRelativeHeight: CGFloat = 0.7 // Rel to ringNode height
    
    // balls
    static let BallRelativeHeight: CGFloat = 0.07 // Rel to playableRect height
    static let BallPhysicsBodyRelativeRadius: CGFloat = 0.5 // Rel to ballNode height
    
    // device
    static let DeviceBaseHeight: CGFloat = 320 // iPhone 5s landscape height (base to calculate gravity)
    
    // playableRect
    static let PlayableRectRatio: CGFloat = 2.25
    
    // bars
    static let TopRelativeHeightAssignedBeforeBottomBar: CGFloat = 0.1 // relative to playableRect height
    static let VerticalMiddleBarRelativeWidth: CGFloat = 0.02 // relative to playableRect width
    
    // score label
    static let ScoreLabelRelativeHeight: CGFloat = 0.7 // relative to topBarHeight
    static let ScoreLabelRelativeWidth: CGFloat = 0.20 // relative to playableRect width
    
    // coins label
    static let CoinNodeRelativeHeight: CGFloat = 0.45 // relative to topBarHeight
    static let CoinNodeRelativeSideOffset: CGFloat = 0.02 // relative to playableRect width
    static let CoinsLabelRelativeSideOffset: CGFloat = 0.01 // relative to playableRect width
    static let CoinsLabelRelativeHeight: CGFloat = 0.5 // relative to topBarHeight
    static let CoinsLabelRelativeWidth: CGFloat = 0.20 // relative to playableRect width

}

struct ZPosition {
    static let GeneralInfoLayer: CGFloat = 250
    static let GameInfoLayer: CGFloat = 200
    static let RingAbove: CGFloat = 110
    static let BallsLayer: CGFloat = 100
    static let RingsLayer: CGFloat = 90
    static let BarsLayer: CGFloat = 80
}

struct ImageFilename {

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
    static let BallsWait: Double = 1
    static let BallFadeOut: Double = 0.3
}

struct Color {
    static let BackgroundDark = SKColor(red: 0, green: 0, blue: 0.1, alpha: 1.0)
    static let BackgroundLight = SKColor(red: 202.0/255.0, green: 240.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    static let BottomBarDark: SKColor = SKColor.orangeColor()
    static let BottomBarLight: SKColor = SKColor(red: 3.0/255.0, green: 41.0/255.0, blue: 56.0/255.0, alpha: 1.0)
    
    static let TopBarDark: SKColor = SKColor.orangeColor()
    static let TopBarLight: SKColor = Color.BottomBarLight
    
    static let VerticalMiddleBarDark: SKColor = SKColor.orangeColor()
    static let VerticalMiddleBarLight: SKColor = Color.BottomBarLight
    
    static let RingDark: SKColor = SKColor.orangeColor()
    static let RingLight: SKColor = SKColor(red: 2.0/255.0, green: 24.0/255.0, blue: 33.0/255.0, alpha: 1.0)
    
    static let BallDark: SKColor = SKColor.whiteColor()
    static let BallLight: SKColor = SKColor(red: 25.0/255.0, green: 52.0/255.0, blue: 63.0/255.0, alpha: 1.0)
    
    static let BallSpecial: SKColor = SKColor.yellowColor()
}

struct FontName {
    static let ScoreLabel = "Arial"
    static let CoinsLabel = "Arial"
}

struct FontColor {
    static let ScoreLabelDark: SKColor = SKColor.whiteColor()
    static let ScoreLabelLight: SKColor = SKColor.orangeColor()
    
    static let CoinsLabelDark: SKColor = SKColor.whiteColor()
    static let CoinsLabelLight: SKColor = SKColor.whiteColor()
}

struct NodeName {
    static let Ring = "ringNode"
    static let RingPart = "ringPartNode"
    static let Ball = "ballNode"
    
    // TODO: Test
    static let TestButton1 = "testButton1"
    static let TestButton2 = "testButton2"
}

struct ActionKey {
    static let RingFloatingAnimation = "ringFloatingAnimation"
}

struct UserDefaultsKey {
    static let ShowAds = "showAds"
    static let MusicOn = "musicOn"
    static let DarkColorsOn = "darkColorsOn"
    static let GravityNormal = "gravityNormal"
    static let CoinsCount = "coinsCount"
}

struct UserDefaults {
    // default values
    static let ShowAds_Initial = true
    static let MusicOn_Initial = true
    static let DarkColorsOn = true
    static let GravityNormal = true
    static let CoinsCount: Int = 0
}

struct GameOption {
    static let SpecialBallsOn = true
    static let SpecialBallsRatio: UInt32 = 10 // 1 in X
}

struct Test {
    static let TestModeOn = true
}
