//
//  TutorialGameScene.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/18/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import SpriteKit

class TutorialGameScene: GameScene {
    
    private var ringsPhysicsActivated = false
    
    private var tutorialUILayer = SKNode()
    
    override func didMoveToView(view: SKView) {
        gameState = .GameRunning
        
        view.multipleTouchEnabled = true
        isSoundActivated = isMusicOn
        
        /* Setup your scene here */
        if !contentCreated {

            physicsWorld.contactDelegate = self
            
            playableRectSetup()
            barsSetup() // call after playableRectSetup()
            
            // ----- This methods must be called after barsSetup ----- //
            
            ringsSetup()
            
            tutorialUISetup()

            contentCreated = true
        }

        updateGravity()
        updateColors()
        adjustLabelsSize()
    }
    
    private func tutorialUISetup() {
        tutorialUILayer.zPosition = ZPosition.TutorialUILayer
        tutorialUILayer.position = CGPoint(
            x: playableRectOriginInScene.x + playableRect.width/2,
            y: playableRectOriginInScene.y + playableRect.height/2)
        addChild(tutorialUILayer)
        
        // home button
        homeButtonNode = SKSpriteNode(imageNamed: ImageFilename.HomeButton)
        let homeButtonRatio = homeButtonNode!.size.width / homeButtonNode!.size.height
        let homeButtonHeight = topBarHeight * Geometry.TopLeftButtonRelativeHeight
        homeButtonNode!.size = CGSize(width: homeButtonRatio * homeButtonHeight, height: homeButtonHeight)
        homeButtonNode!.position = CGPoint(
            x: -playableRect.width/2 + playableRect.width * Geometry.TopLeftButtonRelativeSideOffset + homeButtonNode!.size.width/2,
            y: +playableRect.height/2 + topBarHeight / 2)
        homeButtonNode!.name = NodeName.BackToMenuButton
        homeButtonNode!.color = darkColorsOn ? Color.TopLeftButtonDark : Color.TopLeftButtonLight
        homeButtonNode!.colorBlendFactor = Color.TopLeftButtonBlendFactor
        tutorialUILayer.addChild(homeButtonNode!)
        
        // title label
        let titleLabelHeight = topBarHeight * Geometry.TitleLabelRelativeHeight
        let titleLabelWidth = playableRect.width * Geometry.TitleLabelRelativeWidth
        titleLabel = SKLabelNode(text: Text.HowToPlay)
        titleLabel!.verticalAlignmentMode = .Center
        titleLabel!.horizontalAlignmentMode = .Center
        titleLabel!.fontName = FontName.Title
        titleLabel!.fontColor = darkColorsOn ? FontColor.TitleDark : FontColor.TitleLight
        adjustFontSizeForLabel(titleLabel!, tofitSize: CGSize(
            width: titleLabelWidth,
            height: titleLabelHeight))
        titleLabel!.position = CGPoint(x: 0, y: +playableRect.height/2 + topBarHeight/2)
        tutorialUILayer.addChild(titleLabel!)
        
        // touch
        let handColor = darkColorsOn ? Color.TutorialImageDark : Color.TutorialImageLight
        let handHeight = playableRect.height * Geometry.TutorialTouchImageRelativeHeight
        print("touch screen image height: \(handHeight)")

        // left hand
        let leftHand = SKSpriteNode(imageNamed: ImageFilename.TouchScreen)
        let handRatio = leftHand.size.width / leftHand.size.height
        leftHand.size = CGSize(width: handRatio * handHeight, height: handHeight)
        leftHand.position = CGPoint(x: playableRect.width/4, y: 0)
        leftHand.xScale = -1
        leftHand.color = handColor
        leftHand.colorBlendFactor = Color.TutorialImageBlendFactor
        leftHand.name = NodeName.TutorialImage
        tutorialUILayer.addChild(leftHand)
        // right hand
        let rightHand = SKSpriteNode(imageNamed: ImageFilename.TouchScreen)
        rightHand.size = leftHand.size
        rightHand.position = CGPoint(x: -playableRect.width/4, y: 0)
        rightHand.color = handColor
        rightHand.colorBlendFactor = Color.TutorialImageBlendFactor
        rightHand.name = NodeName.TutorialImage
        tutorialUILayer.addChild(rightHand)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !ringsPhysicsActivated {
            activateRingsPhysics()
            ringsPhysicsActivated = true
        } else {
            super.touchesBegan(touches, withEvent: event)
        }
    }

    
    
    
}
