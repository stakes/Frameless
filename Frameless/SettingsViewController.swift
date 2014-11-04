//
//  SettingsViewController.swift
//  Frameless
//
//  Created by Jay Stakelon on 11/3/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    var delegate:ViewController?
    
    @IBAction func closeSettingsView(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.delegate!.focusOnSearchBar()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
