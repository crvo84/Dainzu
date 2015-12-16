//
//  GameViewController.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/9/15.
//  Copyright (c) 2015 Villou. All rights reserved.
//

import UIKit
import SpriteKit
import iAd

class GameViewController: UIViewController, ADBannerViewDelegate {
    
    // iAd Banner
    var adBanner: ADBannerView?
    var appJustLaunched = true
    
    private var showAds: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.ShowAds)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: UserDefaultsKey.ShowAds)
            if !newValue {
                canDisplayBannerAds = false
            }
        }
    }

    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        interstitialPresentationPolicy = .Manual
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.ShowAds) {
            adBanner = ADBannerView(frame: CGRectZero)
            adBanner!.delegate = self
            adBanner!.frame = CGRectMake(0.0, view.frame.size.height - adBanner!.frame.size.height, adBanner!.frame.size.width, adBanner!.frame.size.height)
            adBanner!.backgroundColor = SKColor.clearColor()
            view.addSubview(adBanner!)
        }
        
        if let skView = self.view as? SKView {
            skView.showsFPS = true
            skView.showsNodeCount = true
            skView.showsPhysics = false
            skView.ignoresSiblingOrder = true
            
            var bannerHeight: CGFloat = 0
            if adBanner != nil {
                bannerHeight = adBanner!.frame.height
                if Test.TestModeOn {
                    print("scene width: \(skView.frame.width),  height: \(skView.frame.height)")
                    print("bannerHeight: \(bannerHeight)")
                }
            }
            
            let gameScene = GameScene(size: view.frame.size, bannerHeight: bannerHeight)
            gameScene.viewController = self
            gameScene.scaleMode = .AspectFill
            
            skView.presentScene(gameScene)
        }

    }

    func requestInterstitialAdIfNeeded() {
        if showAds && !appJustLaunched {
            requestInterstitialAdPresentation()
        }
        appJustLaunched = false
    }
    
    // MARK: iAd Banner View Delegate
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        /* whatever you need */
        if let skView = view as? SKView {
            if let gameScene = skView.scene as? GameScene {
                // pause game
                gameScene.pauseGame()
            }
        }
        
        return true
    }
    
    func bannerViewActionDidFinish(banner: ADBannerView!) {
        
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        banner.hidden = false
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        banner.hidden = true
    }
    
    func bannerViewWillLoadAd(banner: ADBannerView!) {
        
    }
}
