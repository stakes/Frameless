//
//  AppDefaults.swift
//  Frameless
//
//  Created by Jay Stakelon on 10/26/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

enum AppDefaultKeys: String {
    case History = "browserHistory"
    case KeepHistory = "keepHistory"
    case Favorites = "browserFavorites"
    case IntroVersionSeen = "introVersionSeen"
    case ShakeGesture = "shake"
    case PanFromBottomGesture = "panFromBottom"
    case PanFromTopGesture = "panFromTop"
    case ForwardBackGesture = "panLeftRight"
    case FramerBonjour = "framerConnect"
    case KeepAwake = "keepAwake"
    case SearchEngine = "searchEngine"
    case FixiOS9 = "fixiOS9"
}

let BLUE = UIColorFromHex(0x28AFFA)
let HIGHLIGHT_BLUE = UIColorFromHex(0x28AFFA, alpha: 0.6)
let GREEN = UIColorFromHex(0x7DDC16)
let PURPLE = UIColorFromHex(0x9178E2)
let CYAN = UIColorFromHex(0x2DD7AA)

let TEXT = UIColorFromHex(0x24262A)
let LIGHT_TEXT = UIColorFromHex(0xAEB2BA)
let LIGHT_GREY = UIColorFromHex(0xF2F5F9)
let LIGHT_GREY_BORDER = UIColorFromHex(0xCACED3)

let HISTORY_UPDATED_NOTIFICATION = "HistoryUpdatedNotification"