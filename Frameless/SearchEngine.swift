//
//  SearchEngine.swift
//  Frameless
//
//  Created by Jaanus Kase on 14.06.15.
//  Copyright (c) 2015 Jay Stakelon. All rights reserved.
//

import Foundation

enum SearchEngineType: String {
    case Google = "google"
    case DuckDuckGo = "ddg"
}

/// Model object for a search engine
struct SearchEngine {
    
    /// A stable identifier for this engine, like "google"
    var type: SearchEngineType
    
    /// The string that’s displayed in the UI
    var displayName: String
    
    /// The URL used to construct a query. The string {query} gets replaced with the actual query that the user typed
    var queryURLTemplate: String
}

func searchEngine(type: SearchEngineType) -> SearchEngine {
    switch (type) {
    case .Google:
        return SearchEngine(type: .Google, displayName: "Google",
            queryURLTemplate: "https://google.com/search?q={query}")
    case .DuckDuckGo:
        return SearchEngine(type: .DuckDuckGo, displayName: "DuckDuckGo",
            queryURLTemplate: "https://duckduckgo.com/?q={query}&kp=-1&kj=%2328AFFA&kt=h&ka=h")
    }
}

func searchEngine(type: String) -> SearchEngine? {
    if let engineType = SearchEngineType(rawValue: type) {
        return searchEngine(engineType)
    }
    return nil
}

func searchEngines() -> Array<SearchEngine> {
    return [ searchEngine(.DuckDuckGo), searchEngine(.Google) ]
}