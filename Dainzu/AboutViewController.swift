//
//  AboutViewController.swift
//  Roger 360
//
//  Created by Carlos Rogelio Villanueva Ousset on 11/19/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
    
    @IBOutlet weak var mrMarketButton: UIButton!
    @IBOutlet weak var hiInvestButton: UIButton!
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        hiInvestButton.imageView?.layer.cornerRadius = hiInvestButton.frame.width * Geometry.AboutAppButtonsRelativeCornerRadius
        hiInvestButton.imageView?.layer.masksToBounds = true
        
        mrMarketButton.imageView?.layer.cornerRadius = mrMarketButton.frame.width * Geometry.AboutAppButtonsRelativeCornerRadius
        mrMarketButton.imageView?.layer.masksToBounds = true
    }
    
    @IBAction func homeButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier(SegueId.ExitAbout, sender: self)
    }

    
    @IBAction func mrMarketButtonPressed(sender: UIButton) {
        if let url = NSURL(string: URLString.MrMarketAppStore) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func hiInvestButtonPressed(sender: UIButton) {
        if let url = NSURL(string: URLString.HiInvestAppStore) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    @IBAction func facebookButtonPressed(sender: UIButton) {
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
    
    @IBAction func twitterButtonPressed(sender: UIButton) {
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
