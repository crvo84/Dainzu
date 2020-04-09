//
//  AppDelegate.swift
//  Dainzu
//
//  Created by Carlos Rogelio Villanueva Ousset on 12/9/15.
//  Copyright © 2015 Villou. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        // Override point for customization after application launch.

        userDefaultsSetup()

        UIViewController.prepareInterstitialAds()
    }

    // MARK: User Defaults
    private func userDefaultsSetup()
    {
        let defaults = UserDefaults.standard

        if UserDefaultsInitialValues.ShowAds == false {
            // handles the case where the user have already installed the app,
            // and then an update disables Ads for all users, even without paying.
            defaults.set(false, forKey: UserDefaultsKey.ShowAds)
        } else if defaults.object(forKey: UserDefaultsKey.ShowAds) == nil {
            defaults.set(UserDefaultsInitialValues.ShowAds, forKey: UserDefaultsKey.ShowAds)
        }
        
        if defaults.object(forKey: UserDefaultsKey.MusicOn) == nil {
            defaults.set(UserDefaultsInitialValues.MusicOn, forKey: UserDefaultsKey.MusicOn)
        }

        if defaults.object(forKey: UserDefaultsKey.DarkColorsOn) == nil {
            defaults.set(UserDefaultsInitialValues.DarkColorsOn, forKey: UserDefaultsKey.DarkColorsOn)
        }
        
        if defaults.object(forKey: UserDefaultsKey.GravityNormal) == nil {
            defaults.set(UserDefaultsInitialValues.GravityNormal, forKey: UserDefaultsKey.GravityNormal)
        }
        
        if defaults.object(forKey: UserDefaultsKey.CoinsCount) == nil {
            defaults.set(UserDefaultsInitialValues.CoinsCount, forKey: UserDefaultsKey.CoinsCount)
        }
        
        if defaults.object(forKey: UserDefaultsKey.BestScore) == nil {
            defaults.set(UserDefaultsInitialValues.BestScore, forKey: UserDefaultsKey.BestScore)
        }
        
        // ball available by default
        if defaults.object(forKey: UserDefaultsKey.BallDefault) == nil {
            defaults.set(UserDefaultsInitialValues.BallDefault, forKey: UserDefaultsKey.BallDefault)
        }
        
        if defaults.object(forKey: UserDefaultsKey.BallSelected) == nil {
            defaults.set(UserDefaultsInitialValues.BallSelected, forKey: UserDefaultsKey.BallSelected)
        }
        
        // instructions will be shown always the first game after the app launches
        defaults.set(UserDefaultsInitialValues.ShowInstructions, forKey: UserDefaultsKey.ShowInstructions)

        defaults.synchronize()
    }


}

