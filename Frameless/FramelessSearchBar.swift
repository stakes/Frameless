//
//  FramelessSearchBar.swift
//  Frameless
//
//  Created by Jay Stakelon on 12/1/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import UIKit

class FramelessSearchBar: UISearchBar {
    
    var framelessSearchBarDelegate:FramelessSearchBarDelegate?
    var _refreshButton:UIButton!
    var _field:UITextField!

    func handleRefreshTap() {
        framelessSearchBarDelegate?.searchBarRefreshWasPressed!()
    }
    
    func refreshButton() -> UIButton {
        if _refreshButton == nil {
            _refreshButton = UIButton(frame: CGRectMake(0, 0, 16, 14.5))
        }
        return _refreshButton
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.autocapitalizationType = .None
        self.returnKeyType = .Go
        self.keyboardType = .URL
        
        let clearSans = UIFont(name: "ClearSans", size: 16)
        if let font = clearSans {
            var normalTextAttributes: Dictionary = [
                NSFontAttributeName: font
            ]
            UIBarButtonItem.appearance().setTitleTextAttributes(normalTextAttributes, forState: .Normal)
            
            // See: http://stackoverflow.com/a/26224862/534343
            AppearanceBridge.setSearchBarTextInputAppearance()
            
            var closeImg = UIImage(named: "close")
            self.setImage(closeImg, forSearchBarIcon: .Clear, state: .Normal)
            var closeImgHighlight = UIImage(named: "close-highlight")
            self.setImage(closeImgHighlight, forSearchBarIcon: .Clear, state: .Highlighted)
            
            // Swap search bar button out for refresh
            var searchField: UITextField?
            var searchBarSubviews = self.subviews.first?.subviews
            for subview in searchBarSubviews! {
                if subview.isKindOfClass(UITextField) {
                    searchField = subview as? UITextField
                    searchField?.rightView?.backgroundColor = UIColorFromHex(0x9178E2)
                    break
                }
            }
            if let field = searchField {
                _field = field
                var iconImage = UIImage(named: "refresh")
                var iconImageDisabled = UIImage(named: "refresh-disabled")
                if _refreshButton == nil {
                    _refreshButton = UIButton(frame: CGRectMake(0, 0, 16, 14.5))
                }
                _refreshButton.setImage(iconImage, forState: UIControlState.Normal)
                _refreshButton.setImage(iconImageDisabled, forState: UIControlState.Disabled)
                _refreshButton.addTarget(self, action: Selector("handleRefreshTap"), forControlEvents: .TouchUpInside)
                _refreshButton.enabled = false
                field.leftView = _refreshButton
            }
        }
    }
    
    func selectAllText() {
        if let field = _field {
            if field.text != "" {
                field.selectAll(self)
            }
        }
    }

}

@objc protocol FramelessSearchBarDelegate {
    optional func searchBarRefreshWasPressed()
}
