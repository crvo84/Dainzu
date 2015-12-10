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
    static let RingPhysicsBodyRelativeHeight: CGFloat = 0.1 // Rel to ringNode height
    static let RingRelativeFloatingVerticalRange: CGFloat = 0.1 // relative to ringNode height
    
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
    static let RingsLayer: CGFloat = 100
    static let RingBelow: CGFloat = 90
    static let BarsLayer: CGFloat = 80
}

struct ImageFilename {
    static let RingLeft = "ringLeft"
    static let RingRight = "ringRight"
}

struct Physics {
    // world
    static let GravityBaseY: CGFloat = -5
    // ring
    static let RingDensity: CGFloat = 10
    static let RingLinearDamping: CGFloat = 0.2
    static let RingImpulseMultiplier: CGFloat = 0.9
}

struct PhysicsCategory {
    static let None:        UInt32 = 0      // 0
    static let Ring:        UInt32 = 0b1    // 1
    static let Boundary:        UInt32 = 0b10   // 2
    static let Ball:        UInt32 = 0b100  // 3
    static let All:         UInt32 = UInt32.max
}

struct Time {
    static let RingFloatingCycle: Double = 2
}

struct Color {
    static let BottomBar: SKColor = SKColor.orangeColor()
    static let TopBar: SKColor = SKColor.orangeColor()
    static let VerticalMiddleBar: SKColor = SKColor.orangeColor()
}

struct ActionKey {
    static let RingFloatingAnimation = "ringFloatingAnimation"
}

struct Test {
    static let TestModeOn = true
}
