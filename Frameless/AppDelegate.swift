//
//  AppDelegate.swift
//  Unframed
//
//  Created by Jay Stakelon on 10/23/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = UIColor.whiteColor()
        
        setUserSettingsDefaults()
        
        if let lastIntro: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.IntroVersionSeen.rawValue) {
            setupAppViewController(false)
        } else {
            self.window!.rootViewController = createIntroViewController()
            self.window!.makeKeyAndVisible()
        }

        
        UIButton.appearance().tintColor = UIColorFromHex(0x9178E2)
                
        return true
    }
    
    func setUserSettingsDefaults() {
        
        NSUserDefaults.standardUserDefaults().registerDefaults([
            AppDefaultKeys.ShakeGesture.rawValue: true,
            AppDefaultKeys.PanFromBottomGesture.rawValue: true,
            AppDefaultKeys.TripleTapGesture.rawValue: true,
            AppDefaultKeys.ForwardBackGesture.rawValue: true,
            AppDefaultKeys.FramerBonjour.rawValue: true,
            AppDefaultKeys.KeepAwake.rawValue: true,
            AppDefaultKeys.SearchEngine.rawValue: SearchEngineType.DuckDuckGo.rawValue
        ])
        
        let isIdleTimer = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.KeepAwake.rawValue) as? Bool
        UIApplication.sharedApplication().idleTimerDisabled = isIdleTimer!
    }
    
    func createIntroViewController() -> OnboardingViewController {
        let page01: OnboardingContentViewController = OnboardingContentViewController(title: nil, body: "Frameless is a chromeless,\nfull-screen web browser. Load a\npage and everything else hides", image: UIImage(named: "introimage01"), buttonText: nil) {
        }
        page01.iconWidth = 158
        page01.iconHeight = 258.5
        
        let page02: OnboardingContentViewController = OnboardingContentViewController(title: nil, body: "Swipe up, tap with three fingers\nor shake the device to show\nthe browser bar and keyboard", image: UIImage(named: "introimage02"), buttonText: nil) {
        }
        page02.iconWidth = 158
        page02.iconHeight = 258.5
        
        let page03: OnboardingContentViewController = OnboardingContentViewController(title: nil, body: "Swipe left and right to go\nforward and back in your\nsession history", image: UIImage(named: "introimage03"), buttonText: nil) {
            self.introCompletion()
        }
        page03.iconWidth = 158
        page03.iconHeight = 258.5
        
        let page04: OnboardingContentViewController = OnboardingContentViewController(title: nil, body: "And disable any of the gestures\nif they get in your way", image: UIImage(named: "introimage04"), buttonText: "LET'S GO!") {
            self.introCompletion()
        }
        page04.iconWidth = 158
        page04.iconHeight = 258.5
        
        let bgImage = UIImage.withColor(UIColorFromHex(0x9178E2))
        let onboardingViewController = PortraitOnboardingViewController(
            backgroundImage: bgImage,
            contents: [page01, page02, page03, page04])
        onboardingViewController.fontName = "ClearSans"
        onboardingViewController.bodyFontSize = 16
        onboardingViewController.titleFontName = "ClearSans-Bold"
        onboardingViewController.titleFontSize = 22
        onboardingViewController.buttonFontName = "ClearSans-Bold"
        onboardingViewController.buttonFontSize = 20
        onboardingViewController.topPadding = 60+(self.window!.frame.height/12)
        onboardingViewController.underTitlePadding = 8
        
        onboardingViewController.shouldMaskBackground = false
        
        return onboardingViewController
    }
    
    
    func introCompletion() {
        NSUserDefaults.standardUserDefaults().setValue(1, forKey: AppDefaultKeys.IntroVersionSeen.rawValue)
        setupAppViewController(true)
    }
    
    func setupAppViewController(animated : Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let appViewController = storyboard.instantiateViewControllerWithIdentifier("mainViewController") as! UIViewController
        if animated {
            UIView.transitionWithView(self.window!, duration: 0.5, options:UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
                self.window!.rootViewController = appViewController
                }, completion:nil)
        }
        else {
            self.window?.rootViewController = appViewController
        }
        self.window!.makeKeyAndVisible()
    }
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

}

