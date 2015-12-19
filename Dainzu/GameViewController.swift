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
import StoreKit
import GameKit

class GameViewController: UIViewController, ADBannerViewDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate, GKGameCenterControllerDelegate {
    
    // iAd Banner
    var adBanner: ADBannerView?
    var appJustLaunched = true
    
    // In-App Purchases
    var product: SKProduct?
    var waitingForProduct = false
    
    // Game Center
//    var isGameCenterEnabled = false
    
    private var showAds: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.ShowAds)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: UserDefaultsKey.ShowAds)
            if !newValue {
                adBanner?.removeFromSuperview()
                adBanner = nil
                startNewGameScene()
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
        
        // game center
        authenticatePlayer()
        
        if showAds {
            SKPaymentQueue.defaultQueue().addTransactionObserver(self)
            getProductInfo()
        }
        
        startNewGameScene()
    }
    
    func startNewGameScene() {
        adBanner = nil
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
    
    // called from GameScene
    func requestInterstitialAdIfNeeded() {
        if showAds && !appJustLaunched {
            requestInterstitialAdPresentation()
        }
        appJustLaunched = false
    }
    
    // ------------------------------------------ //
    // ----- MARK: iAd Banner View Delegate ---- //
    // ---------------------------------------- //
    
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
    
    
      // --------------------------------- //
     // ----- MARK: In-App Purchases ---- //
    // --------------------------------- //
    
    func removeAdsButtonPressed(sourceView: UIView, sourceRect: CGRect) {
        
        var alertMessage: String?
        if product != nil{
            let numberFormatter = NSNumberFormatter()
            numberFormatter.locale = product!.priceLocale
            numberFormatter.numberStyle = .CurrencyStyle
            alertMessage = numberFormatter.stringFromNumber(NSNumber(double: Double(product!.price)))
        }
        
        let removeAdsActionSheet = UIAlertController(title: Text.RemoveAds, message: alertMessage, preferredStyle: .ActionSheet)
        
        let purchaseAction = UIAlertAction(title: Text.Purchase, style: .Default) { (action:UIAlertAction) in
            self.removeAds()
        }
        let restorePurchaseAction = UIAlertAction(title: Text.Restore, style: .Default) { (action: UIAlertAction) in
            self.restorePurchases()
        }
        let cancelAction = UIAlertAction(title: Text.Cancel, style: .Cancel, handler: nil)
        removeAdsActionSheet.addAction(purchaseAction)
        removeAdsActionSheet.addAction(restorePurchaseAction)
        removeAdsActionSheet.addAction(cancelAction)
        
        if let popoverController = removeAdsActionSheet.popoverPresentationController {
//            popoverController.sourceView = sender
//            popoverController.sourceRect = sender.bounds
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceRect
        }
        
        presentViewController(removeAdsActionSheet, animated: true, completion: nil)
    }
    
    private func removeAds()
    {
        if !showAds { return }
        
        if product != nil {
            let payment = SKPayment(product: product!)
            SKPaymentQueue.defaultQueue().addPayment(payment)
        } else {
            waitingForProduct = true
            getProductInfo()
        }
    }
    
    private func restorePurchases() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    func getProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdsSet = Set([InAppPurchase.RemoveAdsProductId])
            let request = SKProductsRequest(productIdentifiers: productIdsSet)
            request.delegate = self
            request.start()
        } else {
            print("Please enable In App Purchase in Settings")
        }
    }
    
    // SKProduct request delegate
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        var products = response.products
        if (products.count > 0) {
            product = products[0]
            if waitingForProduct {
                waitingForProduct = false
                removeAds()
            }
        }
        
        for product in response.invalidProductIdentifiers {
            print("Product not found: \(product)")
        }
    }
    
    // SKPayment transaction delegate
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.Failed:
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            case SKPaymentTransactionState.Restored:
                fallthrough
                
            case SKPaymentTransactionState.Purchased:
                showAds = false
                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
                
            default:
                break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        //called when the user successfully restores a purchase
        var itemsRestored = false
        for transaction in queue.transactions {
            if transaction.transactionState == SKPaymentTransactionState.Restored {
                itemsRestored = true
            }
        }
        let restoredTitle = itemsRestored ? Text.PurchasesRestored : Text.NoPreviousPurchases
        let restoredAlertController = UIAlertController(title: restoredTitle, message: nil, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: Text.Ok, style: .Default, handler: nil)
        restoredAlertController.addAction(okAction)
        self.presentViewController(restoredAlertController, animated: true, completion: nil)
    }
    
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError) {
        let failToRestoreAlert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: Text.Ok, style: .Default, handler: nil)
        failToRestoreAlert.addAction(okAction)
        presentViewController(failToRestoreAlert, animated: true, completion: nil)
    }

    
    // ---------------------------- //
    // ----- MARK: GameCenter ---- //
    // -------------------------- //
    
    func reportScore(score: Int) {
        let gkScore = GKScore(leaderboardIdentifier: GameCenter.LeaderboardId)
        
        gkScore.value = Int64(score)
        
        GKScore.reportScores([gkScore], withCompletionHandler: { (error) -> Void in
            if error != nil {
                print("Failed to report score: \(error)")
            } else {
                print("Successfully logged score!")
            }
        })
    }
    
    // Game Kit Delegate
    
    func authenticatePlayer()
    {
        let localPlayer = GKLocalPlayer.localPlayer()
        // Assigning a block to the localPlayer's
        // authenticateHandler kicks off the process
        // of authenticating the user with Game Center.
        localPlayer.authenticateHandler = { (viewController, error) in
            
            if viewController != nil {
                // We need to present a view controller
                // to finish the authentication process
                self.presentViewController(viewController!, animated: true, completion: nil)
                
            } else if localPlayer.authenticated {
                // We're authenticated, and can now use Game Center features
                print("Authenticated")
//                self.isGameCenterEnabled = true
                
            } else if let theError = error {
                // We're not authenticated.
                print("Error! \(theError)")
//                self.isGameCenterEnabled = false
            }
            
        }
    }
    
    @IBAction func leaderboardButtonPressed(sender: AnyObject)
    {
        let gameCenterViewController: GKGameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = GKGameCenterViewControllerState.Leaderboards
        gameCenterViewController.leaderboardIdentifier = GameCenter.LeaderboardId
        self.presentViewController(gameCenterViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // ---------------------------- //
    // ----- MARK: Navigation ---- //
    // -------------------------- //
    
    @IBAction func moreGamesButtonPressed() {
        performSegueWithIdentifier(SegueId.About, sender: self)
    }
    
    @IBAction func unwindToInitialViewController(segue: UIStoryboardSegue)
    {
        if let segueName = segue.identifier {
            switch segueName {
            default:
                break
            }
        }
    }
    
    @IBAction func facebookButtonPressed() {
        if let facebookFromAppURL = NSURL(string: URLString.FacebookFromApp) {
            if UIApplication.sharedApplication().canOpenURL(facebookFromAppURL) {
                UIApplication.sharedApplication().openURL(facebookFromAppURL)
            } else {
                if let facebookURL = NSURL(string: URLString.Facebook) {
                    UIApplication.sharedApplication().openURL(facebookURL)
                }
            }
        }
    }
    
    @IBAction func twitterButtonPressed() {
        if let twitterFromAppURL = NSURL(string: URLString.TwitterFromApp) {
            if UIApplication.sharedApplication().canOpenURL(twitterFromAppURL) {
                UIApplication.sharedApplication().openURL(twitterFromAppURL)
            } else {
                if let twitterURL = NSURL(string: URLString.Twitter) {
                    UIApplication.sharedApplication().openURL(twitterURL)
                }
            }
        }
    }
    
    
    
}
