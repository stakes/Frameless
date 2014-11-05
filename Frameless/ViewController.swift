//
//  ViewController.swift
//  Unframed
//
//  Created by Jay Stakelon on 10/23/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate {


    @IBOutlet weak var _webView: UIWebView!
    @IBOutlet weak var _searchBar: SearchBar!
    @IBOutlet weak var _progressView: UIProgressView!
    @IBOutlet weak var _loadingErrorView: UIView!
    
    var _tapRecognizer: UITapGestureRecognizer?
    var _panRecognizer: UIScreenEdgePanGestureRecognizer?
    var _areControlsVisible = true
    var _isFirstRun = true
    var _effectView: UIVisualEffectView?
    var _errorView: UIView?
    var _settingsBarView:UIView?
    var _defaultsObject: NSUserDefaults?
    var _onboardingViewController: OnboardingViewController?
    
    // Loading progress? Fake it till you make it.
    var _progressTimer: NSTimer?
    var _isWebViewLoading = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _defaultsObject = NSUserDefaults.standardUserDefaults()
        
        _loadingErrorView.hidden = true
        
        _tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideSearch"))
        
        _panRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleScreenEdgePan:"))
        _panRecognizer!.edges = UIRectEdge.Bottom
        _panRecognizer?.delegate = self
        self.view.addGestureRecognizer(_panRecognizer!)
        
        _searchBar.delegate = self
        _searchBar.autocapitalizationType = .None
        _searchBar.returnKeyType = .Go
        _searchBar.keyboardType = .URL
        _searchBar.showsCancelButton = false
        _searchBar.becomeFirstResponder()
        customizeSearchBarAppearance()
        
        _webView.scalesPageToFit = true
        _webView.delegate = self
        
        _settingsBarView = UIView(frame: CGRectMake(0, self.view.frame.height, self.view.frame.width, 44))
        var settingsButton = UIButton(frame: CGRectMake(7, 0, 36, 36))
        var buttonImg = UIImage(named: "settings-icon")
        settingsButton.setImage(buttonImg, forState: .Normal)
        var buttonHighlightImg = UIImage(named: "settings-icon-highlighted")
        settingsButton.setImage(buttonHighlightImg, forState: .Highlighted)
        settingsButton.addTarget(self, action: "presentSettingsView:", forControlEvents: .TouchUpInside)
        _settingsBarView?.addSubview(settingsButton)
        self.view.addSubview(_settingsBarView!)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        _progressView.hidden = true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func introCompletion() {
        _onboardingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // UI show/hide
    
    func keyboardWillShow(sender: NSNotification) {
        let dict:NSDictionary = sender.userInfo! as NSDictionary
        let s:NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as NSValue
        let rect :CGRect = s.CGRectValue()
        _settingsBarView!.frame.origin.y = self.view.frame.height - rect.height - _settingsBarView!.frame.height
        _settingsBarView!.alpha = 1
    }
    
    func keyboardWillHide(sender: NSNotification) {
        _settingsBarView!.frame.origin.y = self.view.frame.height
        _settingsBarView!.alpha = 0
    }
    
    func handleScreenEdgePan(sender: AnyObject) {
        showSearch()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if(event.subtype == UIEventSubtype.MotionShake) {
            if (!_areControlsVisible) {
                showSearch()
            } else {
                hideSearch()
            }
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func hideSearch() {
        _searchBar.resignFirstResponder()
        UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self._searchBar.transform = CGAffineTransformMakeTranslation(0, -44)
        }, nil)
        _areControlsVisible = false
        removeBackgroundBlur()
    }
    
    func showSearch() {
        UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self._searchBar.transform = CGAffineTransformMakeTranslation(0, 0)
        }, nil)
        _areControlsVisible = true
        _searchBar.becomeFirstResponder()
        blurBackground()
    }
    
    func blurBackground() {
        if !_isFirstRun {
            if _effectView == nil {
                var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
                _effectView = UIVisualEffectView(effect: blur)
                var size = _webView.frame.size
                _effectView!.frame = CGRectMake(0,0,size.width,size.height)
                _effectView!.alpha = 0
                _effectView?.addGestureRecognizer(_tapRecognizer!)
                
                _webView.addSubview(_effectView!)
                _webView.alpha = 0.25
                UIView.animateWithDuration(0.25, animations: {
                    self._effectView!.alpha = 1
                }, nil)
            }
        }
    }
    
    func removeBackgroundBlur() {
        if _effectView != nil {
            UIView.animateWithDuration(0.25, animations: {
                self._effectView!.alpha = 0
            }, completion: { finished in
                self._effectView = nil
            })
            _webView.alpha = 1
        }
    }
    
    func focusOnSearchBar() {
        _searchBar.becomeFirstResponder()
    }
    
    // Settings view
    func presentSettingsView(sender:UIButton!) {
        var settingsController: SettingsViewController = storyboard?.instantiateViewControllerWithIdentifier("settingsController") as SettingsViewController
        settingsController.delegate = self
        self.presentViewController(settingsController, animated: true, completion: nil)
    }
    
    
    // Web view
    func webViewDidStartLoad(webView: UIWebView) {
        _searchBar.showsCancelButton = true
        _loadingErrorView.hidden = true
        _isFirstRun = false
        _isWebViewLoading = true
        _progressView.hidden = false
        _progressView.progress = 0
        _progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: "progressTimerCallback", userInfo: nil, repeats: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        _isWebViewLoading = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        _isWebViewLoading = false
        showSearch()
        displayLoadingErrorMessage()
    }
    
    func progressTimerCallback() {
        if (!_isWebViewLoading) {
            if (_progressView.progress >= 1) {
                _progressView.hidden = true
                _progressTimer?.invalidate()
            } else {
                _progressView.progress += 0.05
            }
        } else {
            _progressView.progress += 0.02
            if (_progressView.progress >= 0.95) {
                _progressView.progress = 0.95
            }
        }
    }
    
    func loadURL(urlString: String) {
        let addrStr = httpifyString(urlString)
        let addr = NSURL(string: addrStr)
        if let webAddr = addr {
            let req = NSURLRequest(URL: webAddr)
            _webView.loadRequest(req)
        } else {
            displayLoadingErrorMessage()
        }
        
    }
    
    func httpifyString(str: String) -> String {
        let lcStr:String = (str as NSString).lowercaseString
        if (countElements(lcStr) >= 7) {
            if ((lcStr as NSString).substringToIndex(7) == "http://") {
                return lcStr
            }
        }
        return "http://"+lcStr
    }
    
    func displayLoadingErrorMessage() {
        _searchBar.showsCancelButton = false
        _loadingErrorView.hidden = false
    }
    
    
    
    // Search bar
    func customizeSearchBarAppearance() {
        let clearSans = UIFont(name: "ClearSans", size: 16)
        if let font = clearSans {
            var normalTextAttributes: Dictionary = [
                NSFontAttributeName: font
            ]
            UIBarButtonItem.appearance().setTitleTextAttributes(normalTextAttributes, forState: .Normal)
            
            // See: http://stackoverflow.com/a/26224862/534343
            AppearanceBridge.setSearchBarTextInputAppearance()
            
            // Change search bar icon
            var searchField: UITextField?
            var searchBarSubviews = _searchBar.subviews.first?.subviews
            for subview in searchBarSubviews! {
                if subview.isKindOfClass(UITextField) {
                    searchField = subview as? UITextField
                    break
                }
            }
            if let field = searchField {
                var iconImage = UIImage(named: "compass")
                var imageView = UIImageView(frame: CGRectMake(0, 0, 14, 14))
                imageView.image = iconImage
                field.leftView = imageView
            }
        }
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        hideSearch()
        loadURL(searchBar.text)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        hideSearch()
    }


}

