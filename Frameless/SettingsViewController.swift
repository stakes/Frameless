//
//  SettingsViewController.swift
//  Frameless
//
//  Created by Jay Stakelon on 11/3/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var _closeButton: UIBarButtonItem!
    @IBOutlet weak var _navigationBar: UINavigationBar!
    
    var delegate:ViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        var font = UIFont(name: "ClearSans-Bold", size: 18)
        var textAttributes = [NSFontAttributeName: font!, NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().titleTextAttributes = textAttributes
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeSettingsView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.delegate!.focusOnSearchBar()
    }
    
    func closeButtonEnabled(bool:Bool) {
        _closeButton.enabled = bool
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
