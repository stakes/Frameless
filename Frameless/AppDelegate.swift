//
//  AppDelegate.swift
//  Frameless
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
        
        if let _: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.IntroVersionSeen.rawValue) {
            setupAppViewController(false)
        } else {
            self.window!.rootViewController = createIntroViewController()
            self.window!.makeKeyAndVisible()
        }

        UIButton.appearance().tintColor = UIColorFromHex(0x9178E2)
                
        return true
    }
    
    // Open from custom URL scheme
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if let host = url.host {
            var urlstr = "http://" + host
            if let port = url.port {
                let portstr = port.stringValue
                urlstr += ":" + portstr
            }
            if let _ = url.path {
                urlstr += url.path!
            }
            
            let vc = self.window?.rootViewController as! ViewController
            vc.loadURL(urlstr, andCloseSearch: true)
            return true
        } else {
            return false
        }
        
    }
    
    func setUserSettingsDefaults() {
        
        NSUserDefaults.standardUserDefaults().registerDefaults([
            AppDefaultKeys.History.rawValue: Array<HistoryEntry>(),
            AppDefaultKeys.KeepHistory.rawValue: true,
            AppDefaultKeys.ShakeGesture.rawValue: true,
            AppDefaultKeys.PanFromBottomGesture.rawValue: true,
            AppDefaultKeys.PanFromTopGesture.rawValue: true,
            AppDefaultKeys.ForwardBackGesture.rawValue: true,
            AppDefaultKeys.FramerBonjour.rawValue: true,
            AppDefaultKeys.KeepAwake.rawValue: true,
            AppDefaultKeys.SearchEngine.rawValue: SearchEngineType.Google.rawValue,
            AppDefaultKeys.FixiOS9.rawValue: true
        ])
//        let defaults = NSUserDefaults.standardUserDefaults()
//        defaults.setObject(Array<HistoryEntry>(), forKey: AppDefaultKeys.History.rawValue)
        let isIdleTimer = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.KeepAwake.rawValue) as? Bool
        UIApplication.sharedApplication().idleTimerDisabled = isIdleTimer!
    }
    
    func createIntroViewController() -> OnboardingViewController {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        
        let str01 = NSMutableAttributedString(string: "Frameless for iOS is a full-screen\nbrowser that hides all controls")
        str01.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, str01.length))
        
        let page01: OnboardingContentViewController = OnboardingContentViewController(title: nil, body: str01, image: UIImage(named: "introimage01"), buttonText: nil) {
        }
        page01.iconWidth = 158
        page01.iconHeight = 258.5
        
        let str02 = NSMutableAttributedString(string: "Swipe up from the bottom or\ndown from the top to show\nthe browser bar and keyboard")
        str02.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, str02.length))
        let page02: OnboardingContentViewController = OnboardingContentViewController(title: nil, body: str02, image: UIImage(named: "introimage02"), buttonText: nil) {
        }
        page02.iconWidth = 158
        page02.iconHeight = 258.5
        
        let str03 = NSMutableAttributedString(string: "Shake the device\nto refresh content")
        str03.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, str03.length))
        let page03: OnboardingContentViewController = OnboardingContentViewController(title: nil, body: str03, image: UIImage(named: "introimage03"), buttonText: nil) {
        }
        page03.iconWidth = 158
        page03.iconHeight = 258.5
        
        let str04 = NSMutableAttributedString(string: "Swipe left or right to go\nback or forward in your history")
        str04.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, str04.length))
        let page04: OnboardingContentViewController = OnboardingContentViewController(title: nil, body: str04, image: UIImage(named: "introimage04"), buttonText: nil) {
            self.introCompletion()
        }
        page04.iconWidth = 158
        page04.iconHeight = 258.5
        
        let str05 = NSMutableAttributedString(string: "And disable any of the gestures\nif they get in your way")
        str05.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, str05.length))
        let page05: OnboardingContentViewController = OnboardingContentViewController(title: nil, body: str05, image: UIImage(named: "introimage05"), buttonText: "Done") {
            self.introCompletion()
        }
        page05.iconWidth = 158
        page05.iconHeight = 258.5
        
        let bgImage = UIImage.withColor(BLUE)
        let onboardingViewController = PortraitOnboardingViewController(
            backgroundImage: bgImage,
            contents: [page01, page02, page03, page04, page05])
        onboardingViewController.fontName = "HelveticaNeue"
        onboardingViewController.bodyFontSize = 16
        onboardingViewController.titleFontName = "HelveticaNeue-Bold"
        onboardingViewController.titleFontSize = 22
        onboardingViewController.buttonFontName = "HelveticaNeue-Bold"
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
        let appViewController = storyboard.instantiateViewControllerWithIdentifier("mainViewController") 
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

