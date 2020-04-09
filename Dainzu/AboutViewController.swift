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

    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()

        hiInvestButton.imageView?.layer.cornerRadius = hiInvestButton.frame.width * Geometry.AboutAppButtonsRelativeCornerRadius
        hiInvestButton.imageView?.layer.masksToBounds = true
        
        mrMarketButton.imageView?.layer.cornerRadius = mrMarketButton.frame.width * Geometry.AboutAppButtonsRelativeCornerRadius
        mrMarketButton.imageView?.layer.masksToBounds = true
    }
    
    @IBAction func homeButtonPressed(sender: AnyObject) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func mrMarketButtonPressed(sender: UIButton) {
        if let url = URL(string: URLString.MrMarketAppStore) {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func hiInvestButtonPressed(sender: UIButton) {
        if let url = URL(string: URLString.HiInvestAppStore) {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func facebookButtonPressed(sender: UIButton) {
        guard let facebookFromAppURL = URL(string: URLString.FacebookFromApp) else { return }

        if UIApplication.shared.canOpenURL(facebookFromAppURL) {
            UIApplication.shared.openURL(facebookFromAppURL)
        } else if let facebookURL = URL(string: URLString.Facebook) {
            UIApplication.shared.openURL(facebookURL)
        }
    }
    
    @IBAction func twitterButtonPressed(sender: UIButton) {
        guard let twitterFromAppURL = URL(string: URLString.TwitterFromApp) else { return }

        if UIApplication.shared.canOpenURL(twitterFromAppURL) {
            UIApplication.shared.openURL(twitterFromAppURL)
        } else if let twitterURL = URL(string: URLString.Twitter) {
            UIApplication.shared.openURL(twitterURL)
        }
    }

}
