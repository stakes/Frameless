//
//  SearchEnginesViewController.swift
//  Frameless
//
//  Created by Jaanus Kase on 14.06.15.
//  Copyright (c) 2015 Jay Stakelon. All rights reserved.
//

import UIKit

class SearchEnginesViewController: UITableViewController {
    
    let engines = searchEngines()
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return engines.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchEngineCell", forIndexPath: indexPath) 
        
        let thisEngine = engines[indexPath.row]
        cell.textLabel?.text = thisEngine.displayName
        
        if NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.SearchEngine.rawValue) as? String == thisEngine.type.rawValue {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedEngine = engines[indexPath.row]
        NSUserDefaults.standardUserDefaults().setObject(selectedEngine.type.rawValue, forKey: AppDefaultKeys.SearchEngine.rawValue)
        
        // A bit of visual trick. Note that we don’t actually update the checkmark here, because
        // doing a reload would cause the selection to disappear abruptly.
        // Instead, we pop back to previous controller which will already show the updated value.
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.navigationController?.popViewControllerAnimated(true)
    }
}