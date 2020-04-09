//
//  PauseNode.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/15/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import SpriteKit

class PauseNode: SKNode {
    
    let size: CGSize

    init(size: CGSize, musicOn: Bool, darkColorsOn: Bool, gravityNormal: Bool) {
        self.size = size
        super.init()
        
        // BACKGROUND NODE
        let backgroundNode = SKSpriteNode(texture: nil, color: Color.PauseNodeBackground, size: size)
        addChild(backgroundNode)
        
        
        let largeButtonHeight = size.height * Geometry.PauseNodeLargeButtonRelativeHeight
        
        // CONTINUE BUTTON NODE
        let continueButton = SKSpriteNode(imageNamed: ImageFilename.ContinueButton)
        let continueButtonRatio = continueButton.size.width / continueButton.size.height
        continueButton.size = CGSize(
            width: largeButtonHeight * continueButtonRatio,
            height: largeButtonHeight)
        continueButton.position = .zero
        continueButton.color = darkColorsOn ? Color.PauseNodeLargeButtonDark : Color.PauseNodeLargeButtonLight
        continueButton.colorBlendFactor = Color.BlendFactor
        continueButton.name = NodeName.ContinueButton
        backgroundNode.addChild(continueButton)
    
        
        let smallButtonSideOffset = size.height * Geometry.PauseNodeSmallButtonRelativeSideOffset
        let smallButtonHeight = size.height * Geometry.PauseNodeSmallButtonRelativeHeight
//        let smallButtonVerticalOffset = size.height * Geometry.PauseNodeSmallButtonRelativeVerticalOffset
        
        // QUIT BUTTON NODE (small button)
        let quitButton = SKSpriteNode(imageNamed: ImageFilename.QuitButton)
        let quitButtonRatio = quitButton.size.width / quitButton.size.height
        quitButton.size = CGSize(
            width: smallButtonHeight * quitButtonRatio,
            height: smallButtonHeight)
        quitButton.position = CGPoint(
            x: +size.width/2 - smallButtonSideOffset - quitButton.size.width/2,
            y: +size.height/2 - smallButtonSideOffset - smallButtonHeight/2)
        quitButton.color = darkColorsOn ? Color.PauseNodeSmallButtonDark : Color.PauseNodeSmallButtonLight
        quitButton.colorBlendFactor = Color.BlendFactor
        quitButton.name = NodeName.QuitButton
        backgroundNode.addChild(quitButton)

        // MUSIC ON/OFF BUTTON NODE
        let musicButton = SKSpriteNode(imageNamed: musicOn ? ImageFilename.MusicOnButton : ImageFilename.MusicOffButton)
        let musicOnOffButtonRatio = musicButton.size.width / musicButton.size.height
        musicButton.size = CGSize(width: smallButtonHeight * musicOnOffButtonRatio, height: smallButtonHeight)
        musicButton.position = CGPoint(
            x: -size.width/2 + smallButtonSideOffset + musicButton.size.width/2,
            y: +size.height/2 - smallButtonSideOffset - smallButtonHeight/2)
        musicButton.color = darkColorsOn ? Color.PauseNodeSmallButtonDark : Color.PauseNodeSmallButtonLight
        musicButton.colorBlendFactor = Color.BlendFactor
        musicButton.name = NodeName.MusicOnOffButton
        backgroundNode.addChild(musicButton)
        
//        // DARK COLORS BUTTON NODE
//        let darkColorsButton = SKSpriteNode(imageNamed: darkColorsOn ? ImageFilename.DarkColorsOn : ImageFilename.DarkColorsOff)
//        let darkColorsButtonRatio = darkColorsButton.size.width / darkColorsButton.size.height
//        darkColorsButton.size = CGSize(
//            width: smallButtonHeight * darkColorsButtonRatio,
//            height: smallButtonHeight)
//        darkColorsButton.position = CGPoint(
//            x: musicButton.position.x,
//            y: musicButton.position.y - smallButtonHeight - smallButtonVerticalOffset)
//        darkColorsButton.color = Color.PauseNodeSmallButton
//        darkColorsButton.colorBlendFactor = Color.PauseNodeSmallButtonBlendFactor
//        darkColorsButton.name = NodeName.DarkColorsOnOffButton
//        backgroundNode.addChild(darkColorsButton)
//        
//        // GRAVITY NORMAL BUTTON NODE
//        let gravityNormalButton = SKSpriteNode(imageNamed: gravityNormal ? ImageFilename.GravityNormalOn : ImageFilename.GravityNormalOff)
//        let gravityNormalButtonRatio = gravityNormalButton.size.width / gravityNormalButton.size.height
//        gravityNormalButton.size = CGSize(
//            width: smallButtonHeight * gravityNormalButtonRatio,
//            height: smallButtonHeight)
//        gravityNormalButton.position = CGPoint(
//            x: musicButton.position.x,
//            y: darkColorsButton.position.y - smallButtonHeight - smallButtonVerticalOffset)
//        gravityNormalButton.color = Color.PauseNodeSmallButton
//        gravityNormalButton.colorBlendFactor = Color.PauseNodeSmallButtonBlendFactor
//        gravityNormalButton.name = NodeName.GravityNormalOnOffButton
//        backgroundNode.addChild(gravityNormalButton)
        
    }
 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
