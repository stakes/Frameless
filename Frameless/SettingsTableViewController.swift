//
//  SettingsTableViewController.swift
//  Frameless
//
//  Created by Jay Stakelon on 11/4/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var _forwardBackSwitch: UISwitch!
    @IBOutlet weak var _shakeSwitch: UISwitch!
    @IBOutlet weak var _swipeUpSwitch: UISwitch!
    @IBOutlet weak var _swipeDownSwitch: UISwitch!
    @IBOutlet weak var _tripleTapSwitch: UISwitch!
    @IBOutlet weak var _bonjourSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _shakeSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ShakeGesture.rawValue) as! Bool
        _swipeUpSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.PanFromBottomGesture.rawValue) as! Bool
        _swipeDownSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.PanFromTopGesture.rawValue) as! Bool
        _tripleTapSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.TripleTapGesture.rawValue)as! Bool
        _forwardBackSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ForwardBackGesture.rawValue) as! Bool
        _bonjourSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.FramerBonjour.rawValue) as! Bool
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        let value = _bonjourSwitch.on
        let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController as! ViewController
        if value == true {
            rootViewController.startSearching()
        } else {
            rootViewController.stopSearching()
        }
    }

    // Settings
    
    @IBAction func toggleShakeSwitch(sender: AnyObject) {
        var value = (sender as! UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.ShakeGesture.rawValue)
        checkControlsSettings()
    }

    @IBAction func toggleSwipeUpSwitch(sender: AnyObject) {
        var value = (sender as! UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.PanFromBottomGesture.rawValue)
        checkControlsSettings()
    }
    
    @IBAction func toggleSwipeDownSwitch(sender: AnyObject) {
        var value = (sender as! UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.PanFromTopGesture.rawValue)
        checkControlsSettings()
    }
    
    @IBAction func toggleTripleTapSwitch(sender: AnyObject) {
        var value = (sender as! UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.TripleTapGesture.rawValue)
        checkControlsSettings()
    }
    
    @IBAction func toggleBrowserNavSwitch(sender: AnyObject) {
        var value = (sender as! UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.ForwardBackGesture.rawValue)
    }
    
    @IBAction func toggleFramerSwitch(sender: AnyObject) {
        var value = (sender as! UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.FramerBonjour.rawValue)
    }
    
    func checkControlsSettings() -> Bool {
        var arr = [_swipeUpSwitch.on, _swipeDownSwitch.on, _tripleTapSwitch.on]
        let filtered = arr.filter { $0 == true }
        var parent = self.parentViewController as! SettingsViewController
        if filtered.count == 0 {
            parent.closeButtonEnabled(false)
            return false
        } else {
            parent.closeButtonEnabled(true)
            return true
        }
    }


}
