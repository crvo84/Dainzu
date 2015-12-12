//
//  GameViewController.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/9/15.
//  Copyright (c) 2015 Villou. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = false
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true

        let bannerHeight = skView.frame.height * 0.1
        
        let gameScene = GameScene(size: view.frame.size, bannerHeight: bannerHeight)
        
        gameScene.scaleMode = .AspectFill

        skView.presentScene(gameScene)
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
