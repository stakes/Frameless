//
//  SettingsTableViewController.swift
//  Frameless
//
//  Created by Jay Stakelon on 11/4/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UINavigationControllerDelegate {

    @IBOutlet weak var _swipeUpSwitch: UISwitch!
    @IBOutlet weak var _swipeDownSwitch: UISwitch!
    @IBOutlet weak var _forwardBackSwitch: UISwitch!
    @IBOutlet weak var _shakeSwitch: UISwitch!
    @IBOutlet weak var _framerSwitch: UISwitch!
    @IBOutlet weak var _sleepSwitch: UISwitch!
    @IBOutlet weak var _closeButton: UIBarButtonItem!
    @IBOutlet weak var _searchEngineLabel: UILabel!
    @IBOutlet weak var _historySwitch: UISwitch!
    @IBOutlet weak var _dimensionsSwitch: UISwitch!
    
    var delegate:ViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBarAppearance()
        let navigationController = self.navigationController
        navigationController?.delegate = self

        _shakeSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ShakeGesture.rawValue) as! Bool
        _swipeUpSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.PanFromBottomGesture.rawValue) as! Bool
        _swipeDownSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.PanFromTopGesture.rawValue) as! Bool
        _forwardBackSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ForwardBackGesture.rawValue) as! Bool
        _framerSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.FramerBonjour.rawValue) as! Bool
        _sleepSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.KeepAwake.rawValue) as! Bool
        _historySwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.KeepHistory.rawValue) as! Bool
        _dimensionsSwitch.on = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.FixiOS9.rawValue) as! Bool

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        let value = _framerSwitch.on
        let rootViewController = UIApplication.sharedApplication().keyWindow?.rootViewController as! ViewController
        if value == true {
            rootViewController.startSearching()
        } else {
            rootViewController.stopSearching()
        }
    }
    
    func setupNavigationBarAppearance() {
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        _closeButton.tintColor = UIColor.whiteColor()
//        var font = UIFont(name: "ClearSans-Bold", size: 18)
//        var textAttributes = [NSFontAttributeName: font!, NSForegroundColorAttributeName: UIColor.whiteColor()]
//        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {
            self.delegate?.focusOnSearchBar()
        })
    }

    // MARK: - Settings
    
    func updateSearchEngineLabel() {
        if let selectedEngineKey = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.SearchEngine.rawValue) as? String {
            if let searchEngine = searchEngine(selectedEngineKey) {
                _searchEngineLabel.text = "Search engine: \(searchEngine.displayName)"
            }
        }
    }
    
    @IBAction func toggleDimensionsSwitch(sender: AnyObject) {
        let value = (sender as! UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.FixiOS9.rawValue)
    }
    
    @IBAction func toggleShakeSwitch(sender: AnyObject) {
        let value = (sender as! UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.ShakeGesture.rawValue)
        checkControlsSettings()
    }

    @IBAction func toggleSwipeUpSwitch(sender: AnyObject) {
        let value = (sender as! UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.PanFromBottomGesture.rawValue)
        checkControlsSettings()
    }
    
    @IBAction func toggleSwipeDownSwitch(sender: AnyObject) {
        let value = (sender as! UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.PanFromTopGesture.rawValue)
        checkControlsSettings()
    }

    
    @IBAction func toggleBrowserNavSwitch(sender: AnyObject) {
        let value = (sender as! UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.ForwardBackGesture.rawValue)
    }
    
    @IBAction func toggleFramerSwitch(sender: AnyObject) {
        let value = (sender as! UISwitch).on
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.FramerBonjour.rawValue)
    }
    
    @IBAction func toggleSleepSwitch(sender: AnyObject) {
        let value = (sender as! UISwitch).on
        UIApplication.sharedApplication().idleTimerDisabled = value
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.KeepAwake.rawValue)
    }
    
    @IBAction func toggleHistorySwitch(sender: AnyObject) {
        let value = (sender as! UISwitch).on
        if !value {
            HistoryManager.manager.clearHistory()
        }
        NSUserDefaults.standardUserDefaults().setValue(value, forKey: AppDefaultKeys.KeepHistory.rawValue)
    }
    
    func checkControlsSettings() -> Bool {
        let arr = [_swipeUpSwitch.on, _swipeDownSwitch.on]
        let filtered = arr.filter { $0 == true }
        if filtered.count == 0 {
            _closeButton.enabled = false
            return false
        } else {
            _closeButton.enabled = true
            return true
        }
    }
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if viewController == self {
            updateSearchEngineLabel()
        }
    }


}
