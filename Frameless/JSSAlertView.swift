//
//  JSSAlertView
//  JSSAlertView
//
//  Created by Jay Stakelon on 9/16/14.
//  Copyright (c) 2014 Jay Stakelon / https://github.com/stakes  - all rights reserved.
//
//  Inspired by and modeled after https://github.com/vikmeup/SCLAlertView-Swift
//  by Victor Radchenko: https://github.com/vikmeup
//

import Foundation
import UIKit

class JSSAlertView: UIViewController {
    
    var containerView:UIView!
    var alertBackgroundView:UIView!
    var dismissButton:UIButton!
    var cancelButton:UIButton!
    var buttonLabel:UILabel!
    var cancelButtonLabel:UILabel!
    var titleLabel:UILabel!
    var textView:UITextView!
    var rootViewController:UIViewController!
    var iconImage:UIImage!
    var iconImageView:UIImageView!
    var closeAction:(()->Void)!
    var isAlertOpen:Bool = false
    
    enum FontType {
        case Title, Text, Button
    }
    var titleFont:String?
    var textFont:String?
    var buttonFont:String?
    
    var defaultColor = UIColorFromHex(0xF2F4F4, alpha: 1)
    
    enum TextColorTheme {
        case Dark, Light
    }
    var darkTextColor = UIColorFromHex(0x000000, alpha: 0.75)
    var lightTextColor = UIColorFromHex(0xffffff, alpha: 0.9)
    
    let baseHeight:CGFloat = 160.0
    var alertWidth:CGFloat = 260.0
    let buttonHeight:CGFloat = 48.0
    let padding:CGFloat = 20.0
    
    var viewWidth:CGFloat?
    var viewHeight:CGFloat?
    
    // Allow alerts to be closed/renamed in a chainable manner
    class JSSAlertViewResponder {
        let alertview: JSSAlertView
        
        init(alertview: JSSAlertView) {
            self.alertview = alertview
        }
        
        func addAction(action: ()->Void) {
            self.alertview.addAction(action)
        }
        
        func setTitleFont(fontStr: String) {
            self.alertview.setFont(fontStr, type: .Title)
        }
        
        func setTextFont(fontStr: String) {
            self.alertview.setFont(fontStr, type: .Text)
        }
        
        func setButtonFont(fontStr: String) {
            self.alertview.setFont(fontStr, type: .Button)
        }
        
        func setTextTheme(theme: TextColorTheme) {
            self.alertview.setTextTheme(theme)
        }
        
        func close() {
            self.alertview.closeView(false)
        }
    }
    
    func setFont(fontStr: String, type: FontType) {
        switch type {
        case .Title:
            self.titleFont = fontStr
            if let font = UIFont(name: self.titleFont!, size: 18) {
                self.titleLabel.font = font
            } else {
                self.titleLabel.font = UIFont.systemFontOfSize(18)
            }
        case .Text:
            if self.textView != nil {
                self.textFont = fontStr
                if let font = UIFont(name: self.textFont!, size: 14) {
                    self.textView.font = font
                } else {
                    self.textView.font = UIFont.systemFontOfSize(14)
                }
            }
        case .Button:
            self.buttonFont = fontStr
            if let font = UIFont(name: self.buttonFont!, size: 18) {
                self.buttonLabel.font = font
            } else {
                self.buttonLabel.font = UIFont.systemFontOfSize(18)
            }
        }
        // relayout to account for size changes
        self.viewDidLayoutSubviews()
    }
    
    func setTextTheme(theme: TextColorTheme) {
        switch theme {
        case .Light:
            recolorText(lightTextColor)
        case .Dark:
            recolorText(darkTextColor)
        }
    }
    
    func recolorText(color: UIColor) {
        titleLabel.textColor = color
        if textView != nil {
            textView.textColor = color
        }
        buttonLabel.textColor = color
        if cancelButtonLabel != nil {
            cancelButtonLabel.textColor = color
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let size = UIScreen.mainScreen().bounds.size
        self.viewWidth = size.width
        self.viewHeight = size.height
        
        var yPos:CGFloat = 0.0
        let contentWidth:CGFloat = self.alertWidth - (self.padding*2)
        
        // position the icon image view, if there is one
        if self.iconImageView != nil {
            yPos += iconImageView.frame.height
            let centerX = (self.alertWidth-self.iconImageView.frame.width)/2
            self.iconImageView.frame.origin = CGPoint(x: centerX, y: self.padding)
            yPos += padding
        }
        
        // position the title
        let titleString = titleLabel.text! as NSString
        let titleAttr = [NSFontAttributeName:titleLabel.font]
        let titleSize = CGSize(width: contentWidth, height: 90)
        let titleRect = titleString.boundingRectWithSize(titleSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: titleAttr, context: nil)
        yPos += padding
        self.titleLabel.frame = CGRect(x: self.padding, y: yPos, width: self.alertWidth - (self.padding*2), height: ceil(titleRect.size.height))
        yPos += ceil(titleRect.size.height)
        
        
        // position text
        if self.textView != nil {
            let textString = textView.text! as NSString
            var range = NSMakeRange(0, 1)
            let pStyle: AnyObject? = textView.attributedText.attribute(NSParagraphStyleAttributeName, atIndex: 0, effectiveRange: &range)
            let font = textView.font as AnyObject!
            var textAttr = [NSFontAttributeName: font]
            if let style: AnyObject = pStyle {
                textAttr = [NSFontAttributeName: font, NSParagraphStyleAttributeName: style]
            }
            let textSize = CGSize(width: contentWidth, height: 0)
            let textRect = textString.boundingRectWithSize(textSize, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: textAttr, context: nil)
            self.textView.frame = CGRect(x: self.padding, y: yPos, width: self.alertWidth - (self.padding*2), height: ceil(textRect.size.height)*2)
            yPos += ceil(textRect.size.height) + padding/1.5
        }
        
        // position the buttons
        yPos += self.padding
        
        var buttonWidth = self.alertWidth
        if self.cancelButton != nil {
            buttonWidth = self.alertWidth/2
            self.cancelButton.frame = CGRect(x: 0, y: yPos, width: buttonWidth-0.5, height: self.buttonHeight)
            if self.cancelButtonLabel != nil {
                self.cancelButtonLabel.frame = CGRect(x: self.padding, y: (self.buttonHeight/2) - 12, width: buttonWidth - (self.padding*2), height: 24)
            }
        }
        
        let buttonX = buttonWidth == self.alertWidth ? 0 : buttonWidth
        self.dismissButton.frame = CGRect(x: buttonX, y: yPos, width: buttonWidth, height: self.buttonHeight)
        if self.buttonLabel != nil {
            self.buttonLabel.frame = CGRect(x: self.padding, y: (self.buttonHeight/2) - 12, width: buttonWidth - (self.padding*2), height: 24)
        }
        
        // set button fonts
        if self.buttonLabel != nil {
            if let font = self.buttonFont {
                buttonLabel.font = UIFont(name: font, size: 18)
            } else {
                buttonLabel.font = UIFont.systemFontOfSize(18)
            }
        }
        if self.cancelButtonLabel != nil {
            if let font = self.buttonFont {
                cancelButtonLabel.font = UIFont(name: font, size: 18)
            } else {
                cancelButtonLabel.font = UIFont.systemFontOfSize(18)
            }
        }
    
        yPos += self.buttonHeight
        
        // size the background view
        self.alertBackgroundView.frame = CGRect(x: 0, y: 0, width: self.alertWidth, height: yPos)
        
        // size the container that holds everything together
        self.containerView.frame = CGRect(x: (self.viewWidth!-self.alertWidth)/2, y: (self.viewHeight! - yPos)/2, width: self.alertWidth, height: yPos)
    }
    
    
    
    func info(viewController: UIViewController, title: String, text: String?=nil, buttonText: String?=nil, cancelButtonText: String?=nil) -> JSSAlertViewResponder {
        let alertview = self.show(viewController, title: title, text: text, buttonText: buttonText, cancelButtonText: cancelButtonText, color: UIColorFromHex(0x3498db, alpha: 1))
        alertview.setTextTheme(.Light)
        return alertview
    }
    
    func success(viewController: UIViewController, title: String, text: String?=nil, buttonText: String?=nil, cancelButtonText: String?=nil) -> JSSAlertViewResponder {
        return self.show(viewController, title: title, text: text, buttonText: buttonText, cancelButtonText: cancelButtonText, color: UIColorFromHex(0x2ecc71, alpha: 1))
    }
    
    func warning(viewController: UIViewController, title: String, text: String?=nil, buttonText: String?=nil, cancelButtonText: String?=nil) -> JSSAlertViewResponder {
        return self.show(viewController, title: title, text: text, buttonText: buttonText, cancelButtonText: cancelButtonText, color: UIColorFromHex(0xf1c40f, alpha: 1))
    }
    
    func danger(viewController: UIViewController, title: String, text: String?=nil, buttonText: String?=nil, cancelButtonText: String?=nil) -> JSSAlertViewResponder {
        let alertview = self.show(viewController, title: title, text: text, buttonText: buttonText, cancelButtonText: cancelButtonText, color: UIColorFromHex(0xe74c3c, alpha: 1))
        alertview.setTextTheme(.Light)
        return alertview
    }
    
    func show(viewController: UIViewController, title: String, text: AnyObject?=nil, buttonText: String?=nil, cancelButtonText: String?=nil, color: UIColor?=nil, iconImage: UIImage?=nil) -> JSSAlertViewResponder {
        
        self.rootViewController = viewController
        self.rootViewController.addChildViewController(self)
        self.rootViewController.view.addSubview(view)
        
        self.view.backgroundColor = UIColorFromHex(0x000000, alpha: 0.7)
        
        var baseColor:UIColor?
        if let customColor = color {
            baseColor = customColor
        } else {
            baseColor = self.defaultColor
        }
        let textColor = self.darkTextColor
        
        let sz = UIScreen.mainScreen().bounds.size
        self.viewWidth = sz.width
        self.viewHeight = sz.height
        
        // Container for the entire alert modal contents
        self.containerView = UIView()
        self.view.addSubview(self.containerView!)
        
        // Background view/main color
        self.alertBackgroundView = UIView()
        alertBackgroundView.backgroundColor = baseColor
        alertBackgroundView.layer.cornerRadius = 4
        alertBackgroundView.layer.masksToBounds = true
        self.containerView.addSubview(alertBackgroundView!)
        
        // Icon
        self.iconImage = iconImage
        if self.iconImage != nil {
            self.iconImageView = UIImageView(image: self.iconImage)
            self.containerView.addSubview(iconImageView)
        }
        
        // Title
        self.titleLabel = UILabel()
        titleLabel.textColor = textColor
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .Center
        if let font = self.titleFont {
            titleLabel.font = UIFont(name: font, size: 24)
        } else {
            titleLabel.font = UIFont.systemFontOfSize(24)
        }
        titleLabel.text = title
        self.containerView.addSubview(titleLabel)
        
        // View text
        if let textObj: AnyObject = text {
            self.textView = UITextView()
            self.textView.userInteractionEnabled = false
            textView.editable = false
            textView.textColor = textColor
            textView.textAlignment = .Center
            if let font = self.textFont {
                textView.font = UIFont(name: font, size: 16)
            } else {
                textView.font = UIFont.systemFontOfSize(16)
            }
            textView.backgroundColor = UIColor.clearColor()
            if let attStr = textObj as? NSAttributedString {
                textView.attributedText = attStr
            }
            if let str = textObj as? String {
                textView.text = str
            }
            
            self.containerView.addSubview(textView)
        }
        
        // Button
        self.dismissButton = UIButton()
        let buttonColor = UIImage.withColor(adjustBrightness(baseColor!, amount: 0.8))
        let buttonHighlightColor = UIImage.withColor(adjustBrightness(baseColor!, amount: 0.9))
        dismissButton.setBackgroundImage(buttonColor, forState: .Normal)
        dismissButton.setBackgroundImage(buttonHighlightColor, forState: .Highlighted)
        dismissButton.addTarget(self, action: "buttonTap", forControlEvents: .TouchUpInside)
        alertBackgroundView!.addSubview(dismissButton)
        // Button text
        self.buttonLabel = UILabel()
        buttonLabel.textColor = textColor
        buttonLabel.numberOfLines = 1
        buttonLabel.textAlignment = .Center
        if let text = buttonText {
            buttonLabel.text = text
        } else {
            buttonLabel.text = "OK"
        }
        dismissButton.addSubview(buttonLabel)
        
        // Second cancel button
        if let _ = cancelButtonText {
            self.cancelButton = UIButton()
            let buttonColor = UIImage.withColor(adjustBrightness(baseColor!, amount: 0.8))
            let buttonHighlightColor = UIImage.withColor(adjustBrightness(baseColor!, amount: 0.9))
            cancelButton.setBackgroundImage(buttonColor, forState: .Normal)
            cancelButton.setBackgroundImage(buttonHighlightColor, forState: .Highlighted)
            cancelButton.addTarget(self, action: "cancelButtonTap", forControlEvents: .TouchUpInside)
            alertBackgroundView!.addSubview(cancelButton)
            // Button text
            self.cancelButtonLabel = UILabel()
            cancelButtonLabel.alpha = 0.7
            cancelButtonLabel.textColor = textColor
            cancelButtonLabel.numberOfLines = 1
            cancelButtonLabel.textAlignment = .Center
            if let text = cancelButtonText {
                cancelButtonLabel.text = text
            }

            cancelButton.addSubview(cancelButtonLabel)
        }
        
        // Animate it in
        self.view.alpha = 0
        UIView.animateWithDuration(0.2, animations: {
            self.view.alpha = 1
        })
        self.containerView.frame.origin.x = self.rootViewController.view.center.x
        self.containerView.center.y = -500
        UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.containerView.center = self.rootViewController.view.center
            }, completion: { finished in
                
        })
        
        isAlertOpen = true
        return JSSAlertViewResponder(alertview: self)
    }
    
    func addAction(action: ()->Void) {
        self.closeAction = action
    }
    
    func buttonTap() {
        closeView(true);
    }
    
    func cancelButtonTap() {
        closeView(false);
    }
    
    func closeView(withCallback:Bool) {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.containerView.center.y = self.rootViewController.view.center.y + self.viewHeight!
            }, completion: { finished in
                UIView.animateWithDuration(0.1, animations: {
                    self.view.alpha = 0
                    }, completion: { finished in
                        if withCallback == true {
                            if let action = self.closeAction {
                                action()
                            }
                        }
                        self.removeView()
                })
                
        })
    }
    
    func removeView() {
        isAlertOpen = false
        self.view.removeFromSuperview()
    }
    
}
