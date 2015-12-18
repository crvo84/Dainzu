//
//  BallSelectionScene.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/18/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import SpriteKit

class BallSelectionScene: GameScene {
    
    private var ballSelectionUILayer = SKNode()

    override func didMoveToView(view: SKView) {
        gameState = .GameMenu
        
        isSoundActivated = isMusicOn
        
        /* Setup your scene here */
        if !contentCreated {
            
            playableRectSetup()
            barsSetup() // call after playableRectSetup()
            
            // ----- This methods must be called after barsSetup ----- //

            verticalMiddleBarNode?.removeFromParent()
            
            coinsUISetup()
            ballSelectionUISetup()
            
            contentCreated = true
        }

        updateColors()
        adjustLabelsSize()
    }
    
    private func ballSelectionUISetup() {
        ballSelectionUILayer.zPosition = ZPosition.BallSelectionUILayer
        ballSelectionUILayer.position = CGPoint(
            x: playableRectOriginInScene.x + playableRect.width/2,
            y: playableRectOriginInScene.y + playableRect.height/2)
        addChild(ballSelectionUILayer)
        
        // TODO: move top left button and title label implementation to super class
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
        ballSelectionUILayer.addChild(homeButtonNode!)
        
        // title label
        let titleLabelHeight = topBarHeight * Geometry.TitleLabelRelativeHeight
        let titleLabelWidth = playableRect.width * Geometry.TitleLabelRelativeWidth
        titleLabel = SKLabelNode(text: Text.SelectBall)
        titleLabel!.verticalAlignmentMode = .Center
        titleLabel!.horizontalAlignmentMode = .Center
        titleLabel!.fontName = FontName.Title
        titleLabel!.fontColor = darkColorsOn ? FontColor.TitleDark : FontColor.TitleLight
        adjustFontSizeForLabel(titleLabel!, tofitSize: CGSize(
            width: titleLabelWidth,
            height: titleLabelHeight))
        titleLabel!.position = CGPoint(x: 0, y: +playableRect.height/2 + topBarHeight/2)
        ballSelectionUILayer.addChild(titleLabel!)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
    
}
