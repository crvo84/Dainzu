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

    init(size: CGSize, musicOn: Bool) {
        self.size = size
        super.init()
        
        // BACKGROUND NODE
        let backgroundNode = SKSpriteNode(texture: nil, color: Color.PauseNodeBackground, size: size)
        addChild(backgroundNode)
        
        
        let largeButtonHeight = size.height * Geometry.PauseNodeLargeButtonRelativeHeight
        
        // CONTINUE BUTTON NODE
        let continueButtonNode = SKSpriteNode(imageNamed: ImageFilename.ContinueButton)
        let continueButtonRatio = continueButtonNode.size.width / continueButtonNode.size.height
        continueButtonNode.size = CGSize(
            width: largeButtonHeight * continueButtonRatio,
            height: largeButtonHeight)
        continueButtonNode.position = CGPointZero
        continueButtonNode.name = NodeName.ContinueButton
        backgroundNode.addChild(continueButtonNode)
    
        
        let smallButtonSideOffset = size.height * Geometry.PauseNodeSmallButtonRelativeSideOffset
        let smallButtonHeight = size.height * Geometry.PauseNodeSmallButtonRelativeHeight
        
        // QUIT BUTTON NODE (small button)
        let quitButtonNode = SKSpriteNode(imageNamed: ImageFilename.QuitButton)
        let quitButtonRatio = quitButtonNode.size.width / quitButtonNode.size.height
        quitButtonNode.size = CGSize(
            width: smallButtonHeight * quitButtonRatio,
            height: smallButtonHeight)
        quitButtonNode.position = CGPoint(
            x: +size.width/2 - smallButtonSideOffset - quitButtonNode.size.width/2,
            y: +size.height/2 - smallButtonHeight/2)
        quitButtonNode.name = NodeName.QuitButton
        backgroundNode.addChild(quitButtonNode)

        
        // MUSIC ON/OFF BUTTON NODE
        let musicOnOffButtonNode = SKSpriteNode(imageNamed: musicOn ? ImageFilename.MusicOnButton : ImageFilename.MusicOffButton)
        let musicOnOffButtonRatio = musicOnOffButtonNode.size.width / musicOnOffButtonNode.size.height
        musicOnOffButtonNode.size = CGSize(
            width: smallButtonHeight * musicOnOffButtonRatio,
            height: smallButtonHeight)
        musicOnOffButtonNode.position = CGPoint(
            x: -size.width/2 + smallButtonSideOffset + quitButtonNode.size.width/2,
            y: +size.height/2 - smallButtonHeight/2)
        musicOnOffButtonNode.name = NodeName.MusicOnOffButton
        backgroundNode.addChild(musicOnOffButtonNode)
    }
 
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
