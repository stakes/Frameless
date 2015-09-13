//
//  HistoryManager.swift
//  Frameless
//
//  Created by Jay Stakelon on 8/6/15.
//  Copyright (c) 2015 Jay Stakelon. All rights reserved.
//

import WebKit

class HistoryManager: NSObject {
    
    static let manager = HistoryManager()
    
    let _maxHistoryItems = 50
    var _fullHistory: Array<HistoryEntry>?
    
    var totalEntries: Int {
        get {
            return _fullHistory!.count
        }
    }
    var studio: HistoryEntry?
    var matches: Array<HistoryEntry> = Array<HistoryEntry>()
    var history: Array<HistoryEntry> = Array<HistoryEntry>()
    
    override init() {
        super.init()
        _fullHistory = readHistory()
    }
    
    func getHistoryDataFor(originalString: String) {
        let stringToFind = originalString.lowercaseString
        studio = nil
        history.removeAll(keepCapacity: false)
        matches.removeAll(keepCapacity: false)
        var framerMatches = Array<HistoryEntry>()
        var domainMatches = Array<HistoryEntry>()
        var titleMatches = Array<HistoryEntry>()
        for entry:HistoryEntry in _fullHistory! {
            let entryUrl = entry.urlString.lowercaseString
            let entryTitle = entry.title?.lowercaseString
            if entryTitle?.rangeOfString("framer studio projects") != nil {
                // Put Framer Studio home in the top matches
                studio = entry
            } else if entryUrl.rangeOfString(stringToFind) != nil {
                if entryUrl.lowercaseString.rangeOfString(".framer") != nil {
                    // is it a framer project URL? these go first
                    framerMatches.insert(entry, atIndex: 0)
                } else {
                    if entryUrl.hasPrefix(stringToFind) && entryUrl.lowercaseString.rangeOfString(".framer") == nil {
                        // is it a domain match? if it's a letter-for-letter match put in top matches
                        // unless it's a local Framer Studio URL because that list will get long
                        matches.append(entry)
                    } else {
                        // otherwise add to history
                        domainMatches.insert(entry, atIndex: 0)
                    }
                }
            } else if entryTitle?.rangeOfString(stringToFind) != nil {
                // is it a title match? cause these go last
                titleMatches.insert(entry, atIndex: 0)
            }
            history = framerMatches + domainMatches + titleMatches
        }
        NSNotificationCenter.defaultCenter().postNotificationName(HISTORY_UPDATED_NOTIFICATION, object: nil)
    }
    
    func addToHistory(webView: WKWebView) {
        if NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.KeepHistory.rawValue) as! Bool == true {
            if let urlStr = webView.URL?.absoluteString as String! {
                if verifyUniquenessOfURL(urlStr) {
                    checkForFramerStudio(webView)
                    var title = webView.title
                    if title == nil || title == "" {
                        title = " "
                    }
                    let historyEntry = HistoryEntry(url: webView.URL!, urlString: createDisplayURLString(webView.URL!), title: title)
                    _fullHistory?.append(historyEntry)
                    trimHistory()
                    saveHistory()
                    NSNotificationCenter.defaultCenter().postNotificationName(HISTORY_UPDATED_NOTIFICATION, object: nil)
                }
            }
        }
    }
    
    func trimHistory() {
        if let arr = _fullHistory {
            if arr.count > _maxHistoryItems {
                let count = arr.count as Int
                let extraCount = count - _maxHistoryItems
                let newarr = arr[extraCount...(arr.endIndex-1)]
                _fullHistory = Array<HistoryEntry>(newarr)
            }
        }
    }
    
    func createDisplayURLString(url: NSURL) -> String {
        var str = url.resourceSpecifier
        if str.hasPrefix("//") {
            str = str.substringFromIndex(str.startIndex.advancedBy(2))
        }
        if str.hasPrefix("www.") {
            str = str.substringFromIndex(str.startIndex.advancedBy(4))
        }
        if str.hasSuffix("/") {
            str = str.substringToIndex(str.endIndex.predecessor())
        }
        return str
    }
    
    func verifyUniquenessOfURL(urlStr: String) -> Bool {
        for entry:HistoryEntry in _fullHistory! {
            let fullURLString = entry.url.absoluteString as String!
            if fullURLString == urlStr {
                return false
            }
        }
        return true
    }
    
    func checkForFramerStudio(webView:WKWebView) {
        // if this is a Framer Studio URL
        if webView.title?.lowercaseString.rangeOfString("framer studio projects") != nil {
            // remove old framer studios
            let filteredHistory = _fullHistory!.filter({
                return $0.title?.lowercaseString.rangeOfString("framer studio projects") == nil
            })
            _fullHistory = filteredHistory
            saveHistory()
        }
    }
    
    func clearHistory() {
        history.removeAll(keepCapacity: false)
        matches.removeAll(keepCapacity: false)
        _fullHistory?.removeAll(keepCapacity: false)
        saveHistory()
        NSNotificationCenter.defaultCenter().postNotificationName(HISTORY_UPDATED_NOTIFICATION, object: nil)
    }
    
    func saveHistory() {
        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject(_fullHistory as Array<HistoryEntry>!)
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(archivedObject, forKey: AppDefaultKeys.History.rawValue)
        defaults.synchronize()
    }
    
    func readHistory() -> Array<HistoryEntry>? {
        if let unarchivedObject = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.History.rawValue) as? NSData {
            return (NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedObject) as? [HistoryEntry])!
        } else {
            return Array<HistoryEntry>()
        }
    }
    
    
}
