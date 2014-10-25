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
    
    var _panRecognizer: UIScreenEdgePanGestureRecognizer?
    var _areControlsVisible = true
    var _isFirstRun = true
    var _effectView: UIVisualEffectView?
    
    // Loading progress? Fake it till you make it.
    var _progressTimer: NSTimer?
    var _isWebViewLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _panRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleScreenEdgePan:"))
        _panRecognizer!.edges = UIRectEdge.Bottom
        _panRecognizer?.delegate = self
        self.view.addGestureRecognizer(_panRecognizer!)
        
        _searchBar.delegate = self
        _searchBar.returnKeyType = UIReturnKeyType.Go
        _searchBar.keyboardType = UIKeyboardType.URL
        _searchBar.becomeFirstResponder()
        customizeSearchBarAppearance()
        
        _webView.scalesPageToFit = true
        _webView.delegate = self
        
        _progressView.hidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // UI show/hide
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
                
                _webView.addSubview(_effectView!)
                _webView.alpha = 0.5
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
    
    
    // Web view
    func webViewDidStartLoad(webView: UIWebView) {
        _isFirstRun = false
        _isWebViewLoading = true
        _progressView.hidden = false
        _progressView.progress = 0
        _progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: "progressTimerCallback", userInfo: nil, repeats: true)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        _isWebViewLoading = false
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
        let req = NSURLRequest(URL: addr!)
        _webView.loadRequest(req)
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

