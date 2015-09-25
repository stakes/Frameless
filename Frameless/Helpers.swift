//
//  Helpers.swift
//  Frameless
//
//  Created by Jay Stakelon on 10/25/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import Foundation
import UIKit

func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    
    return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
}

// Adapted from obj-c solution at
// http://a2apps.com.au/lighten-or-darken-a-uicolor/
func adjustBrightness(color:UIColor, amount:CGFloat) -> UIColor {
    var hue:CGFloat = 0
    var saturation:CGFloat = 0
    var brightness:CGFloat = 0
    var alpha:CGFloat = 0
    if color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
        brightness += (amount-1.0)
        brightness = max(min(brightness, 1.0), 0.0)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    return color
}

// Extend UIImage with a method to create
// a UIImage from a solid color
// See: http://stackoverflow.com/questions/20300766/how-to-change-the-highlighted-color-of-a-uibutton
extension UIImage {
    class func withColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

// Grabbed from comments on
// http://codewithchris.com/common-mistakes-with-adding-custom-fonts-to-your-ios-app/
func listAllAvailableFonts() {
    for family: AnyObject in UIFont.familyNames() {
        print("\(family)")
        for font: AnyObject in UIFont.fontNamesForFamilyName(family as! String) {
            print(" \(font)")
        }
    }
}


/// Given input from user, turn it into a URL, which could be either a direct URL or a search query
func urlifyUserInput(input: String) -> String {
    
    // This method should really be tested, but I ran into trouble adding unit tests into this project due to some Cocoapods thing
    
    let normalizedInput = input.lowercaseStringWithLocale(NSLocale.currentLocale())
    
    // true = treat as URL, false = treat as search query
    var looksLikeUrl = false
    
    // test various cases
    if normalizedInput.hasPrefix("http://") || normalizedInput.hasPrefix("https://") {
        // normal prefixed urls
        looksLikeUrl = true
    } else if (normalizedInput.rangeOfString("\\w:\\d+", options: .RegularExpressionSearch) != nil) {
        // "internal:4000"
        // "192.168.1.2:4000"
        looksLikeUrl = true
    } else if (normalizedInput.rangeOfString("\\w\\.\\w", options: .RegularExpressionSearch) != nil) {
        // "example.com"
        // "192.168.1.2"
        looksLikeUrl = true
    }
    
    if (looksLikeUrl) {
        // This is a URL. Prefix it if needed, otherwise just pass through
        
        let urlCandidate = input
        if normalizedInput.hasPrefix("http://") || normalizedInput.hasPrefix("https://") {
            return urlCandidate
        } else {
            return "http://" + urlCandidate
        }
    } else {
        // This is a search query. Grab the correct URL template and drop the encoded query into it
        // We are optimists here, assuming that userdefault value and search engine spec is always present,
        // encoding never fails etc
        
        let engineType = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.SearchEngine.rawValue) as! String
        let engine = searchEngine(engineType)
        
        let urlTemplate = engine!.queryURLTemplate
        
        let encodedInput = normalizedInput.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        
        let url = urlTemplate.stringByReplacingOccurrencesOfString("{query}", withString: encodedInput!)
        
        return url
        
    }
}
