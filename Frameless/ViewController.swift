//
//  ViewController.swift
//  Frameless
//
//  Created by Jay Stakelon on 10/23/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UISearchBarDelegate, FramelessSearchBarDelegate, UIGestureRecognizerDelegate, WKNavigationDelegate, FramerBonjourDelegate, UITableViewDataSource, UITableViewDelegate {


    
    @IBOutlet weak var _searchBar: FramelessSearchBar!
    @IBOutlet weak var _progressView: UIProgressView!
    @IBOutlet weak var _loadingErrorView: UIView!
    
    let _confirmFramerConnect = true
    
    var _webView: WKWebView?
    var _isMainFrameNavigationAction: Bool?
    var _loadingTimer: NSTimer?
    
    var _tapRecognizer: UITapGestureRecognizer?
    var _threeFingerTapRecognizer: UITapGestureRecognizer?
    var _panFromBottomRecognizer: UIScreenEdgePanGestureRecognizer?
    var _panFromTopRecognizer: UIScreenEdgePanGestureRecognizer?
    var _panFromRightRecognizer: UIScreenEdgePanGestureRecognizer?
    var _panFromLeftRecognizer: UIScreenEdgePanGestureRecognizer?
    var _areControlsVisible = true
    var _isFirstRun = true
    var _effectView: UIVisualEffectView?
    var _errorView: UIView?
    var _settingsBarView: UIView?
    var _defaultsObject: NSUserDefaults?
    var _onboardingViewController: OnboardingViewController?
    var _isCurrentPageLoaded = false
    
    var _framerBonjour = FramerBonjour()
    var _framerAddress: String?
    
    var _alertBuilder: JSSAlertView = JSSAlertView()
    
    var _keyboardHeight:CGFloat = 216
    var _suggestionsTableView: UITableView?
    var _clearHistoryButton: UIButton?
    
    // Loading progress? Fake it till you make it.
    var _progressTimer: NSTimer?
    var _isWebViewLoading = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var webViewConfiguration: WKWebViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.allowsInlineMediaPlayback = true
        webViewConfiguration.mediaPlaybackRequiresUserAction = false
        
        _webView = WKWebView(frame: self.view.frame, configuration: webViewConfiguration)

        self.view.addSubview(_webView!)
        //        _webView!.scalesPageToFit = true
        _webView!.navigationDelegate = self
        self.view.sendSubviewToBack(_webView!)
        
        _defaultsObject = NSUserDefaults.standardUserDefaults()
        
        _loadingErrorView.hidden = true
        
        _tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideSearch"))
        
        _threeFingerTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleThreeFingerTap:"))
        _threeFingerTapRecognizer?.numberOfTouchesRequired = 3
        self.view.addGestureRecognizer(_threeFingerTapRecognizer!)
        
        _panFromBottomRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleBottomEdgePan:"))
        _panFromBottomRecognizer!.edges = UIRectEdge.Bottom
        _panFromBottomRecognizer!.delegate = self
        self.view.addGestureRecognizer(_panFromBottomRecognizer!)
        
        _panFromTopRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleTopEdgePan:"))
        _panFromTopRecognizer!.edges = UIRectEdge.Top
        _panFromTopRecognizer!.delegate = self
        self.view.addGestureRecognizer(_panFromTopRecognizer!)
        
        _panFromLeftRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleGoBackPan:"))
        _panFromLeftRecognizer!.edges = UIRectEdge.Left
        _panFromLeftRecognizer!.delegate = self
        self.view.addGestureRecognizer(_panFromLeftRecognizer!)
        
        _panFromRightRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleGoForwardPan:"))
        _panFromRightRecognizer!.edges = UIRectEdge.Right
        _panFromRightRecognizer!.delegate = self
        self.view.addGestureRecognizer(_panFromRightRecognizer!)

        _searchBar.delegate = self
        _searchBar.framelessSearchBarDelegate = self
        _searchBar.showsCancelButton = false
        _searchBar.becomeFirstResponder()
         AppearanceBridge.setSearchBarTextInputAppearance()
        
        _settingsBarView = UIView(frame: CGRectMake(0, self.view.frame.height, self.view.frame.width, 44))
        _settingsBarView?.backgroundColor = LIGHT_GREY
        
        var settingsButton = UIButton(frame: CGRectZero)
        settingsButton.setTitle("Settings", forState: .Normal)
        settingsButton.setTitleColor(BLUE, forState: .Normal)
        settingsButton.setTitleColor(HIGHLIGHT_BLUE, forState: .Highlighted)
        settingsButton.titleLabel!.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
        settingsButton.sizeToFit()
        var settingsFrame = settingsButton.frame
        settingsFrame.origin.x = _settingsBarView!.frame.width - settingsFrame.width - 14
        settingsFrame.origin.y = 7
        settingsButton.frame = settingsFrame
        
        _clearHistoryButton = UIButton(frame: CGRectZero)
        _clearHistoryButton!.setTitle("Clear History", forState: .Normal)
        _clearHistoryButton!.setTitleColor(BLUE, forState: .Normal)
        _clearHistoryButton!.setTitleColor(HIGHLIGHT_BLUE, forState: .Highlighted)
        _clearHistoryButton!.setTitleColor(LIGHT_TEXT, forState: .Disabled)
        _clearHistoryButton!.titleLabel!.font = UIFont(name: "HelveticaNeue", size: 14)
        _clearHistoryButton!.sizeToFit()
        var clearFrame = _clearHistoryButton!.frame
        clearFrame.origin.x = 14
        clearFrame.origin.y = 7
        _clearHistoryButton!.frame = clearFrame

        settingsButton.addTarget(self, action: "presentSettingsView:", forControlEvents: .TouchUpInside)
        _clearHistoryButton!.addTarget(self, action: "didTapClearHistory:", forControlEvents: .TouchUpInside)
        
        var topBorder = UIView()
        topBorder.frame = CGRectMake(0, 0, _settingsBarView!.frame.width, 0.5)
        topBorder.backgroundColor = LIGHT_GREY_BORDER
        
        _settingsBarView?.addSubview(topBorder)
        _settingsBarView?.addSubview(settingsButton)
        _settingsBarView?.addSubview(_clearHistoryButton!)
        self.view.addSubview(_settingsBarView!)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardShown:"), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("historyUpdated:"), name: HISTORY_UPDATED_NOTIFICATION, object: nil)
        
        _framerBonjour.delegate = self
        if NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.FramerBonjour.rawValue) as! Bool == true {
            _framerBonjour.start()
        }
        
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
    
    
    //MARK: - UI show/hide
    
    func keyboardShown(sender: NSNotification) {
        let info  = sender.userInfo!
        let value: AnyObject = info[UIKeyboardFrameEndUserInfoKey]!
        let rawFrame = value.CGRectValue()
        let keyboardFrame = view.convertRect(rawFrame, fromView: nil)
        _keyboardHeight = keyboardFrame.height
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if _searchBar.isFirstResponder() {
            let dict:NSDictionary = sender.userInfo! as NSDictionary
            let s:NSValue = dict.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
            let rect :CGRect = s.CGRectValue()
            _settingsBarView!.frame.origin.y = self.view.frame.height - rect.height - _settingsBarView!.frame.height
            _settingsBarView!.alpha = 1
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        _settingsBarView!.frame.origin.y = self.view.frame.height
        _settingsBarView!.alpha = 0
    }
    
    func handleBottomEdgePan(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.PanFromBottomGesture.rawValue) as! Bool == true {
            showSearch()
        }
    }
    
    func handleTopEdgePan(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.PanFromTopGesture.rawValue) as! Bool == true {
            showSearch()
        }
    }
    
    func handleThreeFingerTap(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.TripleTapGesture.rawValue) as! Bool == true {
            showSearch()
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if let isShakeActive:Bool = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ShakeGesture.rawValue) as? Bool {
//            if(event.subtype == UIEventSubtype.MotionShake && isShakeActive == true) {
//                if (!_areControlsVisible) {
//                    showSearch()
//                } else {
//                    hideSearch()
//                }
//            }
            searchBarRefreshWasPressed()
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func hideSearch() {
        removeSuggestionsTableView()
        _searchBar.resignFirstResponder()
        UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self._searchBar.transform = CGAffineTransformMakeTranslation(0, -44)
        }, completion: nil)
        _areControlsVisible = false
        removeBackgroundBlur()
    }
    
    func showSearch() {
        if let urlString = _webView?.URL?.absoluteString {
            _searchBar.text = urlString
        }
        UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self._searchBar.transform = CGAffineTransformMakeTranslation(0, 0)
        }, completion: nil)
        _areControlsVisible = true
        _searchBar.selectAllText()
        _searchBar.becomeFirstResponder()
        blurBackground()
    }
    
    func blurBackground() {
        if !_isFirstRun {
            if _effectView == nil {
                var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
                _effectView = UIVisualEffectView(effect: blur)
                var size = _webView!.frame.size
                _effectView!.frame = CGRectMake(0,0,size.width,size.height)
                _effectView!.alpha = 0
                _effectView?.addGestureRecognizer(_tapRecognizer!)
                
                _webView!.addSubview(_effectView!)
                _webView!.alpha = 0.25
                UIView.animateWithDuration(0.25, animations: {
                    self._effectView!.alpha = 1
                }, completion: nil)
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
            _webView!.alpha = 1
        }
    }
    
    func focusOnSearchBar() {
        _searchBar.becomeFirstResponder()
    }

    
    //MARK: -  Settings view
    
    func presentSettingsView(sender:UIButton!) {
        
        let settingsNavigationController = storyboard?.instantiateViewControllerWithIdentifier("settingsController") as! UINavigationController
        
        let settingsTableViewController = settingsNavigationController.topViewController as! SettingsTableViewController
        settingsTableViewController.delegate = self
        
        // Animated form sheet presentation was crashing on regular size class (all iPads, and iPhone 6+ landscape).
        // Disabling the animation until the root cause of that crash is found.
        let shouldAnimateSettingsPresentation: Bool = self.traitCollection.horizontalSizeClass != .Regular
        
        self.presentViewController(settingsNavigationController, animated: shouldAnimateSettingsPresentation, completion: nil)
    }
    
    
    //MARK: -  Web view
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        _searchBar.showsCancelButton = true
        _loadingErrorView.hidden = true
        _isFirstRun = false
        _isWebViewLoading = true
        _progressView.hidden = false
        _progressView.progress = 0
        _progressTimer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: "progressTimerCallback", userInfo: nil, repeats: true)
        _loadingTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "loadingTimeoutCallback", userInfo: nil, repeats: false)
    }
    
    func loadingTimeoutCallback() {
        _webView?.stopLoading()
        handleWebViewError()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        HistoryManager.manager.addToHistory(webView)
        removeSuggestionsTableView()
        _isCurrentPageLoaded = true
        _loadingTimer!.invalidate()
        _isWebViewLoading = false
    }

    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        if let newFrameLoading = _isMainFrameNavigationAction {
            // do nothing, I'm pretty sure it's a new page load into target="_blank" before the old one's subframes are finished
        } else {
            handleWebViewError()
        }
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        if let newFrameLoading = _isMainFrameNavigationAction {
            // do nothing, it's a new page load before the old one's subframes are finished
        } else {
            handleWebViewError()
        }
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.targetFrame == nil && navigationAction.navigationType == .LinkActivated) {
            _webView!.loadRequest(navigationAction.request)
        }
        _isMainFrameNavigationAction = navigationAction.targetFrame?.mainFrame
        decisionHandler(.Allow)
    }

    func handleWebViewError() {
        _loadingTimer!.invalidate()
        _isCurrentPageLoaded = false
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
                _progressView.progress += 0.2
            }
        } else {
            _progressView.progress += 0.003
            if (_progressView.progress >= 0.95) {
                _progressView.progress = 0.95
            }
        }
    }
    
    func loadURL(urlString: String, andCloseSearch: Bool = false) {
        let addrStr = urlifyUserInput(urlString)
        let addr = NSURL(string: addrStr)
        if let webAddr = addr {
            if let loadTimer = _loadingTimer {
                loadTimer.invalidate()
            }
            _webView!.stopLoading()
            let req = NSURLRequest(URL: webAddr)
            _webView!.loadRequest(req)
        } else {
            displayLoadingErrorMessage()
        }
        if andCloseSearch == true {
            hideSearch()
        }
    }
    
    
    func displayLoadingErrorMessage() {
        _loadingErrorView.hidden = false
    }
    
    func handleGoBackPan(sender: UIScreenEdgePanGestureRecognizer) {
        if NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ForwardBackGesture.rawValue) as! Bool == true {
            if (sender.state == .Began) {
                _webView!.goBack()
            }
        }
    }
    
    func handleGoForwardPan(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ForwardBackGesture.rawValue) as! Bool == true {
            if (sender.state == .Began) {
                _webView!.goForward()
            }
        }
    }
    
    // Framer.js Bonjour Integration
    
    func didResolveAddress(address: String) {
        if _confirmFramerConnect {
            if !_alertBuilder.isAlertOpen {
                var windowCount = UIApplication.sharedApplication().windows.count
                if let targetView = UIApplication.sharedApplication().windows[windowCount-1].rootViewController! {
                    _framerAddress = address
                    
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.lineSpacing = 2
                    paragraphStyle.alignment = .Center
                    let alertStr = NSMutableAttributedString(string: "Framer Studio is running on your network. Connect now?")
                    alertStr.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, alertStr.length))
                    var alert = _alertBuilder.show(targetView as UIViewController!, title: "Framer Mirror", text: alertStr, cancelButtonText: "Cancel", buttonText: "Connect", color: BLUE)
                    alert.addAction(handleAlertConfirmTap)
                    alert.setTextTheme(.Light)
                    alert.setTitleFont("HelveticaNeue-Bold")
                    alert.setTextFont("HelveticaNeue")
                    alert.setButtonFont("HelveticaNeue")
                }
            }
        } else {
            loadFramer(address)
        }
    }
    
    func handleAlertConfirmTap() {
        loadFramer(_framerAddress!)
    }
    
    func loadFramer(address: String) {
        hideSearch()
        loadURL(address)
    }
    
    func startSearching() {
        _framerBonjour.start()
    }
    
    func stopSearching() {
        _framerBonjour.stop()
    }
    
    
    
    //MARK: -  Search bar

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        hideSearch()
        loadURL(searchBar.text)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        hideSearch()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        var enable = false
        if (count(_searchBar.text as String) > 0) && _isCurrentPageLoaded {
            enable = true
        }
        _searchBar.refreshButton().enabled = enable
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        updateSuggestions(searchText)
        _searchBar.refreshButton().enabled = false
    }
    
    func searchBarRefreshWasPressed() {
        _loadingTimer!.invalidate()
        hideSearch()
        if let urlString = _webView?.URL?.absoluteString {
            _searchBar.text = urlString
        }
        loadURL(_searchBar.text)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ context in
            self._webView!.frame = CGRectMake(0, 0, size.width, size.height)
        }, completion: nil)
    }
    
    //MARK: - History & favorites suggestions
    
    func historyUpdated(notification: NSNotification) {
        checkHistoryButton()
        _suggestionsTableView?.reloadData()
    }
    
    func didTapClearHistory(sender: UIButton!) {
        HistoryManager.manager.clearHistory()
        _suggestionsTableView?.reloadData()
    }
    
    func checkHistoryButton() {
        if HistoryManager.manager.totalEntries > 0 {
            _clearHistoryButton!.enabled = true
        } else {
            _clearHistoryButton!.enabled = false
        }
    }
    
    func updateSuggestions(text: String) {
        if text == "" {
            removeSuggestionsTableView()
        } else {
            showSuggestionsTableView()
        }
    }
    
    func showSuggestionsTableView() {   
        if _suggestionsTableView == nil {
            let size = UIScreen.mainScreen().bounds.size
            let availHeight = size.height - 88 - CGFloat(_keyboardHeight)
            _suggestionsTableView = UITableView(frame: CGRectMake(0, 44, size.width, availHeight), style: .Grouped)
            _suggestionsTableView?.delegate = self
            _suggestionsTableView?.dataSource = self
            _suggestionsTableView?.backgroundColor = UIColor.clearColor()
            _suggestionsTableView?.separatorColor = UIColorFromHex(0x000000, alpha: 0.1)
            self.view.insertSubview(_suggestionsTableView!, belowSubview: _settingsBarView!)
        }
        populateSuggestionsTableView()
    }
    
    func populateSuggestionsTableView() {
        HistoryManager.manager.getHistoryDataFor(_searchBar.text)
    }
    
    func removeSuggestionsTableView() {
        _suggestionsTableView?.removeFromSuperview()
        _suggestionsTableView = nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:HistoryTableViewCell = HistoryTableViewCell(style: .Subtitle, reuseIdentifier: nil)
        var entry:HistoryEntry
        if indexPath.section == 0 {
            entry = HistoryManager.manager.matches[indexPath.row]
        } else {
            entry = HistoryManager.manager.history[indexPath.row]
        }
        cell.backgroundColor = UIColor.clearColor()
        cell.entry = entry
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = _suggestionsTableView?.cellForRowAtIndexPath(indexPath) as? HistoryTableViewCell {
            loadURL(cell.entry!.url.absoluteString!, andCloseSearch: true)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return HistoryManager.manager.matches.count
        } else {
            return HistoryManager.manager.history.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var rows = self.tableView(tableView, numberOfRowsInSection: section)
        if rows == 0 {
            return ""
        } else if section == 0 {
            return "Top Matches"
        } else {
            return "History"
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let size = UIScreen.mainScreen().bounds.size
        var label = UILabel(frame: CGRectMake(14, 4, size.width - 28, 13))
        label.font = UIFont(name: "HelveticaNeue", size: 13)
        label.textColor = UIColorFromHex(0x000000, alpha: 0.5)
        label.text = self.tableView(tableView, titleForHeaderInSection: section)?.uppercaseString

        var headerView = UIView()
        headerView.backgroundColor = UIColorFromHex(0x000000, alpha: 0.05)
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && HistoryManager.manager.matches.count > 0 {
            return 21
        } else if section == 1 && HistoryManager.manager.history.count > 0 {
            return 21
        } else {
            return CGFloat.min
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.min
    }
    
}

