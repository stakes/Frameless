//
//  HistoryEntry.swift
//  Frameless
//
//  Created by Jay Stakelon on 7/31/15.
//  Copyright (c) 2015 Jay Stakelon. All rights reserved.
//

class HistoryEntry: NSObject, NSCoding {
    
    var url: NSURL
    var urlString: String
    var title: String?
    
    required init?(coder aDecoder: NSCoder) {
        url = aDecoder.decodeObjectForKey("url") as! NSURL
        urlString = aDecoder.decodeObjectForKey("urlString") as! String
        title = aDecoder.decodeObjectForKey("title") as? String
    }
    
    required init(url: NSURL, urlString: String, title: String?) {
        self.url = url
        self.urlString = urlString
        if let t = title {
            self.title = t
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(url, forKey: "url")
        aCoder.encodeObject(urlString, forKey: "urlString")
        aCoder.encodeObject(title, forKey: "title")
    }
    
}
