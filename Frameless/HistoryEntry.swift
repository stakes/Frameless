//
//  HistoryEntry.swift
//  Frameless
//
//  Created by Jay Stakelon on 7/31/15.
//  Copyright (c) 2015 Jay Stakelon. All rights reserved.
//

class HistoryEntry {
    
    var url: NSURL
    var urlString: String
    var title: String?
    
    init(url: NSURL, urlString: String, title: String?) {
        self.url = url
        self.urlString = urlString
        if let t = title {
            self.title = t
        }
    }
    
}
