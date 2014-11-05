//
//  AppDelegate.swift
//  Unframed
//
//  Created by Jay Stakelon on 10/23/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.window!.backgroundColor = UIColor.whiteColor()
        
        if let lastIntro: AnyObject = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.IntroVersionSeen.rawValue) {
            setupAppViewController(false)
        } else {
            self.window!.rootViewController = createIntroViewController()
        }
        
        setUserSettingsDefaults()
        
        self.window!.makeKeyAndVisible()
        
        return true
    }
    
    func setUserSettingsDefaults() {
        println(NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ShakeGesture.rawValue)!)
        if NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ShakeGesture.rawValue) == nil {
            NSUserDefaults.standardUserDefaults().setValue(true, forKey: AppDefaultKeys.ShakeGesture.rawValue)
        }
        if NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ForwardBackGesture.rawValue) == nil {
            NSUserDefaults.standardUserDefaults().setValue(true, forKey: AppDefaultKeys.ForwardBackGesture.rawValue)
        }
    }
    
    func createIntroViewController() -> OnboardingViewController {
        let page01: OnboardingContentViewController = OnboardingContentViewController(title: nil, body: "Frameless is a chromeless,\n full-screen web browser. Load a page and the browser bar will hide", image: UIImage(named: "introimage01"), buttonText: nil) {
        }
        page01.iconWidth = 158
        page01.iconHeight = 258.5
        
        let page02: OnboardingContentViewController = OnboardingContentViewController(title: nil, body: "Swipe up from the bottom of\nyour screen to show the browser\nbar and the keyboard", image: UIImage(named: "introimage02"), buttonText: nil) {
        }
        page02.iconWidth = 158
        page02.iconHeight = 258.5
        
        let page03: OnboardingContentViewController = OnboardingContentViewController(title: nil, body: "Or give your device a hearty shake,\nwhich will also show and\n hide the browser bar", image: UIImage(named: "introimage03"), buttonText: "GOT IT") {
            self.introCompletion()
        }
        page03.iconWidth = 158
        page03.iconHeight = 258.5
        
        let bgImage = UIImage.withColor(UIColorFromHex(0x9178E2))
        let onboardingViewController = OnboardingViewController(
            backgroundImage: bgImage,
            contents: [page01, page02, page03])
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
        let appViewController = storyboard.instantiateViewControllerWithIdentifier("mainViewController") as UIViewController
        if animated {
            UIView.transitionWithView(self.window!, duration: 0.5, options:UIViewAnimationOptions.TransitionFlipFromBottom, animations: { () -> Void in
                self.window!.rootViewController = appViewController
                }, completion:nil)
        }
        else {
            self.window?.rootViewController = appViewController
        }
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
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.stakelon.Unframed" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Unframed", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Unframed.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

