//
//  BallSelectionScene.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/18/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import SpriteKit

class BallSelectionScene: GameScene {
    
    private let imageFilenames: [String]
    
    private var topBarUILayer = SKNode()
    private var gridLayer = SKNode()
    
    private var gridNodes: [SKSpriteNode] = []
    
    init(size: CGSize, bannerHeight: CGFloat, imageFilenames: [String]) {
        self.imageFilenames = imageFilenames
        super.init(size: size, bannerHeight: bannerHeight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            
            topBarUISetup()
            gridSetup()
            
            contentCreated = true
        }

        updateColors()
        adjustLabelsSize()
    }
    
    private func topBarUISetup() {
        topBarUILayer.zPosition = ZPosition.BallSelectionTopBarUILayer
        topBarUILayer.position = CGPoint(
            x: playableRectOriginInScene.x + playableRect.width/2,
            y: playableRectOriginInScene.y + playableRect.height/2)
        addChild(topBarUILayer)
        
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
        topBarUILayer.addChild(homeButtonNode!)
        
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
        topBarUILayer.addChild(titleLabel!)
    }
    
    
    // TODO: facebook, twitter and rate balls
    private func gridSetup() {
        gridLayer.zPosition = ZPosition.BallSelectionGridLayer
        gridLayer.position = CGPoint(
            x: playableRectOriginInScene.x,
            y: playableRectOriginInScene.y)
        addChild(gridLayer)
        
        updateGrid()
    }
    
    
    // MARK: Update methods
    
    private func updateGrid() {
        resetGrid()
        
        // +1 row and column to set offset with boundaries
        let squareHeight = playableRect.height / CGFloat(Geometry.BallSelectionNumberOfRows + 1)
        let squareWidth = playableRect.width / CGFloat(Geometry.BallSelectionNumberOfColumns + 1)
        let ballHeight = playableRect.height * Geometry.BallSelectionBallRelativeHeight
        
        var ballIndex = 0
        for column in 0..<Geometry.BallSelectionNumberOfColumns {
            for row in 0..<Geometry.BallSelectionNumberOfRows {
                let xPos = squareWidth + squareWidth * CGFloat(column)
                let yPos = playableRect.height - squareHeight - squareHeight * CGFloat(row)
                
                if ballIndex < imageFilenames.count {
                    let imageFilename = imageFilenames[ballIndex]
                    let purchased = NSUserDefaults.standardUserDefaults().boolForKey(imageFilename)
                    
                    let ballNode: SKSpriteNode
                    if purchased {
                        ballNode = SKSpriteNode(imageNamed: imageFilename)
    
                    } else {
                        ballNode = SKSpriteNode(imageNamed: ImageFilename.BallNotPurchased)
                        ballNode.color = darkColorsOn ? Color.BallSelectionNotPurchasedDark : Color.BallSelectionNotPurchasedLight
                        ballNode.colorBlendFactor = Color.BallSelectionNotPurchasedBlendFactor
                    }
                    let ballNodeRatio = ballNode.size.width / ballNode.size.height
                    ballNode.size = CGSize(width: ballNodeRatio * ballHeight, height: ballHeight)
                    ballNode.position = CGPoint(x: xPos, y: yPos)
                    ballNode.name = imageFilename
                    gridLayer.addChild(ballNode)
            
                    gridNodes.append(ballNode)
                    
                }
                ballIndex++
            }
        }
    }
    
    private func resetGrid() {
        for var i = 0; i < gridNodes.count; i++ {
            let ballNode = gridNodes[i]
            ballNode.removeFromParent()
        }
        gridNodes = []
    }
    
    
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
    }
    
}















