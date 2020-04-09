//
//  BallSelectionScene.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/18/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import SpriteKit

class BallSelectionScene: GameScene {
    private let screenIndex: Int
    private let imageFilenames: [String]
    
    private var topBarUILayer = SKNode()
    private var gridLayer = SKNode()
    
    private var gridNodes: [SKSpriteNode] = []
    
    private var unlockedSpecialBall = false
    
    init(size: CGSize, bannerHeight: CGFloat, screenIndex: Int) {
        self.screenIndex = screenIndex
        self.imageFilenames = BallImage.Screens[screenIndex]!
        super.init(size: size, bannerHeight: bannerHeight)
    }
    
    private var nextScreenIndex: Int? {
        if screenIndex < BallImage.Screens.count - 1 {
            return screenIndex + 1
        }
        return nil
    }
    
    private var previousScreenIndex: Int? {
        if screenIndex > 0 {
            return screenIndex - 1
        }
        return nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        gameState = .GameMenu
        
        isSoundActivated = isMusicOn
        
        /* Setup your scene here */
        if !contentCreated {
            
            registerAppTransitionObservers()
            
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
    
    override func updateUI() {
        super.updateUI()
        
        updateGrid()
        
        if unlockedSpecialBall && isSoundActivated {
            run(moneySound) {
                self.unlockedSpecialBall = false
            }
        }
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
        homeButtonNode!.colorBlendFactor = Color.BlendFactor
        topBarUILayer.addChild(homeButtonNode!)
        
        // title label
        let titleLabelHeight = topBarHeight * Geometry.TitleLabelRelativeHeight
        let titleLabelWidth = playableRect.width * Geometry.TitleLabelRelativeWidth
        titleLabel = SKLabelNode(text: Text.SelectBall)
        titleLabel!.verticalAlignmentMode = .center
        titleLabel!.horizontalAlignmentMode = .center
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
        for row in 0..<Geometry.BallSelectionNumberOfRows {
            for column in 0..<Geometry.BallSelectionNumberOfColumns {
                let xPos = squareWidth + squareWidth * CGFloat(column)
                let yPos = playableRect.height - squareHeight - squareHeight * CGFloat(row)
                
                if ballIndex < imageFilenames.count {
                    
                    let imageFilename = imageFilenames[ballIndex]
                    let ballNode: SKSpriteNode
                    
                    let purchased = UserDefaults.standard.bool(forKey: imageFilename)
                    
                    switch imageFilename {
                        
                    case BallImage.NextScreenButton:
                        ballNode = SKSpriteNode(imageNamed: ImageFilename.BallNextScreen)
                        ballNode.color = darkColorsOn ? Color.BallSelectionButtonDark : Color.BallSelectionButtonLight
                        ballNode.colorBlendFactor = Color.BlendFactor
                        
                    case BallImage.PreviousScreenButton:
                        ballNode = SKSpriteNode(imageNamed: ImageFilename.BallNextScreen)
                        ballNode.color = darkColorsOn ? Color.BallSelectionButtonDark : Color.BallSelectionButtonLight
                        ballNode.colorBlendFactor = Color.BlendFactor
                        ballNode.xScale = -1 // point to left
                        
                    case BallImage.FacebookBall where !purchased:
                        ballNode = SKSpriteNode(imageNamed: ImageFilename.Facebook)
                        
                    case BallImage.TwitterBall where !purchased:
                        ballNode = SKSpriteNode(imageNamed: ImageFilename.Twitter)
                        
                    default:
                        if purchased {
                            ballNode = SKSpriteNode(imageNamed: imageFilename)
                            
                        } else {
                            ballNode = SKSpriteNode(imageNamed: ImageFilename.BallNotPurchased)
                            ballNode.color = darkColorsOn ? Color.BallSelectionNotPurchasedDark : Color.BallSelectionNotPurchasedLight
                            ballNode.colorBlendFactor = Color.BlendFactor
                        }
                        
                    }
                    
                    let ballNodeRatio = ballNode.size.width / ballNode.size.height
                    ballNode.size = CGSize(width: ballNodeRatio * ballHeight, height: ballHeight)
                    ballNode.position = CGPoint(x: xPos, y: yPos)
                    ballNode.name = imageFilename
                    gridLayer.addChild(ballNode)
                    
                    gridNodes.append(ballNode)
                }
                ballIndex += 1
            }
        }
    }
    
    private func resetGrid() {
        for i in 0..<gridNodes.count {
            let ballNode = gridNodes[i]
            ballNode.removeFromParent()
        }
        gridNodes = []
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        let touchedNode = self.atPoint(location)
            
        if let nodeName = touchedNode.name {
            if imageFilenames.contains(nodeName) {
                selectBall(withImageFilename: nodeName)
                
            } else {
                super.touchesBegan(touches, with: event)
            }
        }
    }
    
    private func selectBall(withImageFilename imageFilename: String) {
        let defaults = UserDefaults.standard
        
        // if there is an object in user defaults, it has been purchased
        if defaults.object(forKey: imageFilename) != nil {
            // already purchased. Select
            ballSelected = imageFilename
            
            if isSoundActivated {
                run(ballCatchSound) { self.startNewGame() }
            } else {
                startNewGame()
            }
            
        } else {
            // if is a next/previous screen button 
            if imageFilename == BallImage.NextScreenButton {
                if let index = nextScreenIndex {
                    if isSoundActivated {
                        run(buttonSmallSound) {
                            self.startBallSelection(withScreenIndex: index)
                        }
                    } else {
                        startBallSelection(withScreenIndex: index)
                    }
                }
                
            } else if imageFilename == BallImage.PreviousScreenButton {
                if let index = previousScreenIndex {
                    if isSoundActivated {
                        run(buttonSmallSound) {
                            self.startBallSelection(withScreenIndex: index)
                        }
                    } else {
                        startBallSelection(withScreenIndex: index)
                    }
                }
                
            } else if imageFilename == BallImage.FacebookBall { // open facebook
                defaults.set(true, forKey: imageFilename)
                ballSelected = imageFilename
                if let gameViewController = viewController as? GameViewController {
                    gameViewController.facebookButtonPressed()
                    unlockedSpecialBall = true
                }
                
            } else if imageFilename == BallImage.TwitterBall { // open twitter
                defaults.set(true, forKey: imageFilename)
                ballSelected = imageFilename
                if let gameViewController = viewController as? GameViewController {
                    gameViewController.twitterButtonPressed()
                    unlockedSpecialBall = true
                }
                
            } else {
                
                // if enough money, purchase
                if coinsCount >= GameOption.BallPrice {
                    
                    defaults.set(true, forKey: imageFilename)
                    coinsCount -= GameOption.BallPrice
                    ballSelected = imageFilename
                    
                    if isSoundActivated { run(moneySound) }
                    
                } else {
                    if isSoundActivated { run(ballFailedSound) }
                }
                
                if coinsLabelFlashAction != nil && coinNodeFlashAction != nil {
                    coinsLabel?.run(coinsLabelFlashAction!)
                    coinNode?.run(coinNodeFlashAction!)
                }
                
                updateGrid()
            }
        }
        defaults.synchronize()
    }
    
}















