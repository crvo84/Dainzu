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
            return UserDefaults.standard.bool(forKey: UserDefaultsKey.ShowAds)
        }
        set {
            let defaults = UserDefaults.standard
            defaults.set(newValue, forKey: UserDefaultsKey.ShowAds)
            defaults.synchronize()
            if !newValue {
                adBanner?.removeFromSuperview()
                adBanner = nil
                startNewGameScene()
            }
        }
    }

    override var prefersStatusBarHidden: Bool { return true}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        interstitialPresentationPolicy = .manual
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // game center
        authenticatePlayer()
        
        if showAds {
            SKPaymentQueue.default().add(self)
            getProductInfo()
        }
        
        startNewGameScene()
    }
    
    func startNewGameScene() {
        adBanner = nil
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.ShowAds) {
            adBanner = ADBannerView(frame: .zero)
            adBanner!.delegate = self
            adBanner!.frame = CGRect(x: 0.0, y: view.frame.size.height - adBanner!.frame.size.height, width: adBanner!.frame.size.width, height: adBanner!.frame.size.height)
            adBanner!.backgroundColor = SKColor.clear
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
            gameScene.scaleMode = .aspectFill
            
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

    func bannerViewActionShouldBegin(_ banner: ADBannerView, willLeaveApplication willLeave: Bool) -> Bool {
        /* whatever you need */
        if let skView = view as? SKView {
            if let gameScene = skView.scene as? GameScene {
                // pause game
                gameScene.pauseGame()
            }
        }
        
        return true
    }

    func bannerViewActionDidFinish(_ banner: ADBannerView) {
    }

    func bannerViewDidLoadAd(_ banner: ADBannerView) {
        banner.isHidden = false
    }

    func bannerView(_ banner: ADBannerView, didFailToReceiveAdWithError error: Error) {
        banner.isHidden = true
    }
    
    func bannerViewWillLoadAd(banner: ADBannerView!) {
    }
    
    
      // --------------------------------- //
     // ----- MARK: In-App Purchases ---- //
    // --------------------------------- //
    
    func removeAdsButtonPressed(sourceView: UIView, sourceRect: CGRect) {
        
        var alertMessage: String?

        if let product = product {
            let numberFormatter = NumberFormatter()
            numberFormatter.locale = product.priceLocale
            numberFormatter.numberStyle = .currency
            alertMessage = numberFormatter.string(from: NSNumber(value: Double(truncating: product.price)))
        }
        
        let removeAdsActionSheet = UIAlertController(title: Text.RemoveAds, message: alertMessage, preferredStyle: .actionSheet)
        
        let purchaseAction = UIAlertAction(title: Text.Purchase, style: .default) { (action:UIAlertAction) in
            self.removeAds()
        }
        let restorePurchaseAction = UIAlertAction(title: Text.Restore, style: .default) { (action: UIAlertAction) in
            self.restorePurchases()
        }
        let cancelAction = UIAlertAction(title: Text.Cancel, style: .cancel, handler: nil)
        removeAdsActionSheet.addAction(purchaseAction)
        removeAdsActionSheet.addAction(restorePurchaseAction)
        removeAdsActionSheet.addAction(cancelAction)
        
        if let popoverController = removeAdsActionSheet.popoverPresentationController {
//            popoverController.sourceView = sender
//            popoverController.sourceRect = sender.bounds
            popoverController.sourceView = sourceView
            popoverController.sourceRect = sourceRect
        }
        
        present(removeAdsActionSheet, animated: true, completion: nil)
    }
    
    private func removeAds()
    {
        if !showAds { return }
        
        if product != nil {
            let payment = SKPayment(product: product!)
            SKPaymentQueue.default().add(payment)
        } else {
            waitingForProduct = true
            getProductInfo()
        }
    }
    
    private func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
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
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
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
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
                
            case SKPaymentTransactionState.failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case SKPaymentTransactionState.restored:
                fallthrough
                
            case SKPaymentTransactionState.purchased:
                showAds = false
                SKPaymentQueue.default().finishTransaction(transaction)
                
            default:
                break
            }
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        //called when the user successfully restores a purchase
        var itemsRestored = false
        for transaction in queue.transactions {
            if transaction.transactionState == SKPaymentTransactionState.restored {
                itemsRestored = true
            }
        }
        let restoredTitle = itemsRestored ? Text.PurchasesRestored : Text.NoPreviousPurchases
        let restoredAlertController = UIAlertController(title: restoredTitle, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Text.Ok, style: .default, handler: nil)
        restoredAlertController.addAction(okAction)
        self.present(restoredAlertController, animated: true, completion: nil)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        let failToRestoreAlert = UIAlertController(title: error.localizedDescription, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: Text.Ok, style: .default, handler: nil)
        failToRestoreAlert.addAction(okAction)
        present(failToRestoreAlert, animated: true, completion: nil)
    }

    
    // ---------------------------- //
    // ----- MARK: GameCenter ---- //
    // -------------------------- //
    
    func reportScore(_ score: Int) {
        let gkScore = GKScore(leaderboardIdentifier: GameCenter.LeaderboardId)
        
        gkScore.value = Int64(score)
        
        GKScore.report([gkScore], withCompletionHandler: { (error) -> Void in
            guard let error = error else {
                return print("Successfully logged score!")
            }

            print("Failed to report score: \(error)")
        })
    }
    
    // Game Kit Delegate
    
    func authenticatePlayer()
    {
        let localPlayer = GKLocalPlayer.local
        // Assigning a block to the localPlayer's
        // authenticateHandler kicks off the process
        // of authenticating the user with Game Center.
        localPlayer.authenticateHandler = { (viewController, error) in
            
            if viewController != nil {
                // We need to present a view controller
                // to finish the authentication process
                self.present(viewController!, animated: true, completion: nil)
                
            } else if localPlayer.isAuthenticated {
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
        gameCenterViewController.viewState = GKGameCenterViewControllerState.leaderboards
        gameCenterViewController.leaderboardIdentifier = GameCenter.LeaderboardId
        self.present(gameCenterViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }

    
    // ---------------------------- //
    // ----- MARK: Navigation ---- //
    // -------------------------- //
    
    @IBAction func moreGamesButtonPressed() {
        performSegue(withIdentifier: SegueId.About, sender: self)
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
        guard let facebookFromAppURL = URL(string: URLString.FacebookFromApp) else { return }

        if UIApplication.shared.canOpenURL(facebookFromAppURL) {
            UIApplication.shared.openURL(facebookFromAppURL)
        } else if let facebookURL = URL(string: URLString.Facebook) {
            UIApplication.shared.openURL(facebookURL)
        }
    }
    
    @IBAction func twitterButtonPressed() {
        guard let twitterFromAppURL = URL(string: URLString.TwitterFromApp) else { return }

        if UIApplication.shared.canOpenURL(twitterFromAppURL) {
            UIApplication.shared.openURL(twitterFromAppURL)
        } else if let twitterURL = URL(string: URLString.Twitter) {
            UIApplication.shared.openURL(twitterURL)
        }
    }
    
}
