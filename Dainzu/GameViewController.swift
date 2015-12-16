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

class GameViewController: UIViewController, ADBannerViewDelegate, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    // iAd Banner
    var adBanner: ADBannerView?
    var appJustLaunched = true
    
    // In-App Purchases
    var product: SKProduct?
    var waitingForProduct = false
    
    private var showAds: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(UserDefaultsKey.ShowAds)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: UserDefaultsKey.ShowAds)
            if !newValue {
                adBanner?.removeFromSuperview()
                adBanner = nil
                // TODO: remove ads button from GameScene
                if let skView = view as? SKView {
                    if let gameScene = skView.scene as? GameScene {
                        gameScene.removeRemoveAdsButton()
                    }
                }
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
        
        if showAds {
            SKPaymentQueue.defaultQueue().addTransactionObserver(self)
            getProductInfo()
        }
        
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

    
    
    
    
    
    
}
