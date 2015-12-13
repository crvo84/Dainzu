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
    static let RingAngle: CGFloat = π/32 // Angle added to original position
    static let RingRelativeFloatingVerticalRange: CGFloat = 0.1 // relative to ringNode height
    
    // balls
    static let BallRelativeHeight: CGFloat = 0.07 // Rel to playableRect height
    static let BallPhysicsBodyRelativeRadius: CGFloat = 0.45 // Rel to ballNode height
    static let BallRelativeHeightToCountPoint: CGFloat = 0.8 // Rel to ballNode height
    
    // device
    static let DeviceBaseHeight: CGFloat = 320 // iPhone 5s landscape height (base to calculate gravity)
    
    // playableRect
    static let PlayableRectRatio: CGFloat = 2.25
    
    // bars
    static let TopRelativeHeightAssignedBeforeBottomBar: CGFloat = 0.1 // relative to playableRect height
    static let VerticalMiddleBarRelativeWidth: CGFloat = 0.02 // relative to playableRect width

}

struct ZPosition {
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
    static let BackgroundLight = SKColor(red: 0.9, green: 1, blue: 1, alpha: 1.0)
    static let BackgroundDark = SKColor(red: 0, green: 0, blue: 0.1, alpha: 1.0)
    
    static let BottomBarDark: SKColor = SKColor.orangeColor()
    static let BottomBarLight: SKColor = SKColor.darkGrayColor()
    
    static let TopBarDark: SKColor = SKColor.orangeColor()
    static let TopBarLight: SKColor = SKColor.darkGrayColor()
    
    static let VerticalMiddleBarDark: SKColor = SKColor.orangeColor()
    static let VerticalMiddleBarLight: SKColor = SKColor.darkGrayColor()
    
    static let RingDark: SKColor = SKColor.orangeColor()
    static let RingLight: SKColor = SKColor.darkGrayColor()
    
    static let BallDark: SKColor = SKColor.whiteColor()
    static let BallLight: SKColor = SKColor.darkGrayColor()
}

struct NodeName {
    static let Ring = "ringNode"
    static let RingPart = "ringPartNode"
    static let Ball = "ballNode"
    
    // TODO: Test
    static let TestButton = "testButton"
}

struct ActionKey {
    static let RingFloatingAnimation = "ringFloatingAnimation"
}

struct UserDefaultsKey {
    static let ShowAds = "showAds"
    static let MusicOn = "musicOn"
    static let DarkColorsOn = "darkColorsOn"
    static let GravityNormal = "gravityNormal"
}

struct UserDefaults {
    // default values
    static let ShowAds_Initial = true
    static let MusicOn_Initial = true
    static let DarkColorsOn = true
    static let GravityNormal = true
}

struct Test {
    static let TestModeOn = true
}
