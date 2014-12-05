//
//  SettingsTableViewController.swift
//  Frameless
//
//  Created by Jay Stakelon on 11/4/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var _shakeSwitch: UISwitch!
    @IBOutlet weak var _swipeUpSwitch: UISwitch!
    @IBOutlet weak var _tripleTapSwitch: UISwitch!
    @IBOutlet weak var _browserSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _shakeSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ShakeGesture.rawValue) as Bool
        _swipeUpSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.PanFromBottomGesture.rawValue) as Bool
        _tripleTapSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.TripleTapGesture.rawValue) as Bool
        _browserSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ForwardBackGesture.rawValue) as Bool
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    // Settings
    
    @IBAction func toggleShakeSwitch(sender: AnyObject) {
        var value = (sender as UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.ShakeGesture.rawValue)
        checkControlsSettings()
    }

    @IBAction func toggleSwipeUpSwitch(sender: AnyObject) {
        var value = (sender as UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.PanFromBottomGesture.rawValue)
        checkControlsSettings()
    }
    
    @IBAction func toggleTripleTapSwitch(sender: AnyObject) {
        var value = (sender as UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.TripleTapGesture.rawValue)
        checkControlsSettings()
    }
    
    @IBAction func toggleBrowserNavSwitch(sender: AnyObject) {
        var value = (sender as UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.ForwardBackGesture.rawValue)
    }
    
    func checkControlsSettings() -> Bool {
        var arr = [_shakeSwitch.on, _swipeUpSwitch.on, _tripleTapSwitch.on]
        let filtered = arr.filter { $0 == true }
        var parent = self.parentViewController as SettingsViewController
        if filtered.count == 0 {
            parent.closeButtonEnabled(false)
            return false
        } else {
            parent.closeButtonEnabled(true)
            return true
        }
    }
    
    // Actions
    
    @IBAction func clearCacheButtonPress(sender: AnyObject) {
        let appDelegate  = UIApplication.sharedApplication().delegate as AppDelegate
        let rootViewController = appDelegate.window!.rootViewController as ViewController
        rootViewController.clearBrowserCache()
    }


}
