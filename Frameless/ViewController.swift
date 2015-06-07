//
//  ViewController.swift
//  Unframed
//
//  Created by Jay Stakelon on 10/23/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UISearchBarDelegate, FramelessSearchBarDelegate, UIGestureRecognizerDelegate, WKNavigationDelegate, FramerBonjourDelegate {


    
    @IBOutlet weak var _searchBar: FramelessSearchBar!
    @IBOutlet weak var _progressView: UIProgressView!
    @IBOutlet weak var _loadingErrorView: UIView!
    
    var _webView: WKWebView?
    var _isMainFrameNavigationAction: Bool?
    var _loadingTimer: NSTimer?
    var _screenIdleTimer: NSTimer?
    
    var _tapRecognizer: UITapGestureRecognizer?
    var _globalTapRecognizer: UITapGestureRecognizer?
    var _threeFingerTapRecognizer: UITapGestureRecognizer?
    var _panFromBottomRecognizer: UIScreenEdgePanGestureRecognizer?
    var _panFromRightRecognizer: UIScreenEdgePanGestureRecognizer?
    var _panFromLeftRecognizer: UIScreenEdgePanGestureRecognizer?
    var _swipeGestureRecognizerH: UISwipeGestureRecognizer?
    var _swipeGestureRecognizerV: UISwipeGestureRecognizer?
    var _areControlsVisible = true
    var _isFirstRun = true
    var _effectView: UIVisualEffectView?
    var _errorView: UIView?
    var _settingsBarView: UIView?
    var _screenIdleView: UIView?
    var _defaultsObject: NSUserDefaults?
    var _onboardingViewController: OnboardingViewController?
    var _isCurrentPageLoaded = false
    var _isScreenBlanked = false
    var _orgBrightness: CGFloat?
    
    var _framerBonjour = FramerBonjour()
    var _framerAddress: String?
    
    var _alertBuilder: JSSAlertView = JSSAlertView()
    
    // Loading progress? Fake it till you make it.
    var _progressTimer: NSTimer?
    var _isWebViewLoading = false
    
    // camera / video capturing
    let _motionDetectionSensitivity: CGFloat = 0.05
    var _enabledMotionDetection = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // enable software dimming to get the display as black as possible in
        // case our idleTimer executes.
        UIScreen.mainScreen().wantsSoftwareDimming = true
       
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
        
        _globalTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleFingerTap:"))
        _globalTapRecognizer?.numberOfTouchesRequired = 1
        _globalTapRecognizer?.delegate = self
        self.view.addGestureRecognizer(_globalTapRecognizer!)
        
        _threeFingerTapRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleThreeFingerTap:"))
        _threeFingerTapRecognizer?.numberOfTouchesRequired = 3
        _threeFingerTapRecognizer?.delegate = self
        self.view.addGestureRecognizer(_threeFingerTapRecognizer!)
        
        _panFromBottomRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleBottomEdgePan:"))
        _panFromBottomRecognizer!.edges = UIRectEdge.Bottom
        _panFromBottomRecognizer!.delegate = self
        self.view.addGestureRecognizer(_panFromBottomRecognizer!)
        
        _panFromLeftRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleGoBackPan:"))
        _panFromLeftRecognizer!.edges = UIRectEdge.Left
        _panFromLeftRecognizer!.delegate = self
        self.view.addGestureRecognizer(_panFromLeftRecognizer!)
        
        _panFromRightRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleGoForwardPan:"))
        _panFromRightRecognizer!.edges = UIRectEdge.Right
        _panFromRightRecognizer!.delegate = self
        self.view.addGestureRecognizer(_panFromRightRecognizer!)

        _swipeGestureRecognizerH = UISwipeGestureRecognizer(target: self, action: Selector("respondToSwipeGesture:"))
        _swipeGestureRecognizerH!.direction = UISwipeGestureRecognizerDirection.Right|UISwipeGestureRecognizerDirection.Left
        _swipeGestureRecognizerH!.delegate = self
        self.view.addGestureRecognizer(_swipeGestureRecognizerH!)

        _swipeGestureRecognizerV = UISwipeGestureRecognizer(target: self, action: Selector("respondToSwipeGesture:"))
        _swipeGestureRecognizerV!.direction = UISwipeGestureRecognizerDirection.Up|UISwipeGestureRecognizerDirection.Down
        _swipeGestureRecognizerV!.delegate = self
        self.view.addGestureRecognizer(_swipeGestureRecognizerV!)
        
        _searchBar.delegate = self
        _searchBar.framelessSearchBarDelegate = self
        _searchBar.showsCancelButton = false
        _searchBar.becomeFirstResponder()
         AppearanceBridge.setSearchBarTextInputAppearance()
        
        _settingsBarView = UIView(frame: CGRectMake(0, self.view.frame.height, self.view.frame.width, 44))
        var settingsButton = UIButton(frame: CGRectMake(7, 0, 36, 36))
        var buttonImg = UIImage(named: "settings-icon")
        settingsButton.setImage(buttonImg, forState: .Normal)
        var buttonHighlightImg = UIImage(named: "settings-icon-highlighted")
        settingsButton.setImage(buttonHighlightImg, forState: .Highlighted)
        settingsButton.addTarget(self, action: "presentSettingsView:", forControlEvents: .TouchUpInside)
        _settingsBarView?.addSubview(settingsButton)
        self.view.addSubview(_settingsBarView!)
        
        // create a screen idle view as large as the screen with a black background
        _screenIdleView = UIView(frame: UIScreen.mainScreen().bounds)
        _screenIdleView!.backgroundColor=UIColor.blackColor()
        _screenIdleView!.hidden = true
        _screenIdleView!.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth;
        self.view.addSubview(_screenIdleView!)
        self.view.sendSubviewToBack(_screenIdleView!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
        _framerBonjour.delegate = self
        if NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.FramerBonjour.rawValue) as! Bool == true {
            _framerBonjour.start()
        }
            
        _progressView.hidden = true
    }

    override func viewDidAppear(animated: Bool)
    {
        // if the user wants to have motion detection running to
        // disable the screen saver we perform this here since GPUImage stuff
        // starts to work in viewDidAppear()
        if NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.MotionDetection.rawValue) as! Bool == true {
            videoCamera?.startCameraCapture()
        }
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        self.videoCamera?.stopCameraCapture()
        super.viewDidDisappear(animated)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // lazy variable dealing with our motiondetection stuff
    lazy var videoCamera: GPUImageVideoCamera? =
    {
        var tempVideoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetLow, cameraPosition: .Front)
        if (tempVideoCamera != nil)
        {
            tempVideoCamera.outputImageOrientation = .Portrait
            var filter = GPUImageMotionDetector()
            filter.motionDetectionBlock =
            {
                [unowned self]
                (CGPoint motionCentroid, CGFloat motionIntensity, CMTime frameTime) -> Void in
                if motionIntensity > self._motionDetectionSensitivity
                {
                    if self._enabledMotionDetection
                    {
                        NSLog("motion detected")
                        dispatch_async(dispatch_get_main_queue(), {
                            self.resetScreenIdleTimer()
                        })
                    }
                    else
                    {
                        NSLog("motion ignored")
                    }
                }
            }
            tempVideoCamera.addTarget(filter)
        }
        return tempVideoCamera
    }()
    
    func introCompletion() {
        _onboardingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    //MARK: - UI show/hide
    
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
    
    func handleFingerTap(sender: AnyObject) {
        resetScreenIdleTimer()
    }
    
    func handleThreeFingerTap(sender: AnyObject) {
        if NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.TripleTapGesture.rawValue) as! Bool == true {
            showSearch()
        }
    }
  
    func respondToSwipeGesture(sender: AnyObject) {
        resetScreenIdleTimer()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if let isShakeActive:Bool = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ShakeGesture.rawValue) as? Bool {
            if(event.subtype == UIEventSubtype.MotionShake && isShakeActive == true) {
                if (!_areControlsVisible) {
                    showSearch()
                } else {
                    hideSearch()
                }
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
        }, completion:  nil)
        _areControlsVisible = false
        removeBackgroundBlur()
        resetScreenIdleTimer()   
    }
    
    func showSearch() {
        if let urlString = _webView?.URL?.absoluteString {
            _searchBar.text = urlString
        }
        UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self._searchBar.transform = CGAffineTransformMakeTranslation(0, 0)
        }, completion: nil)
        _areControlsVisible = true
        resetScreenIdleTimer()
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
        var settingsController: SettingsViewController = storyboard?.instantiateViewControllerWithIdentifier("settingsController") as! SettingsViewController
        settingsController.delegate = self
        settingsController.modalPresentationStyle = .FormSheet
        
        // Animated form sheet presentation was crashing on regular size class (all iPads, and iPhone 6+ landscape).
        // Disabling the animation until the root cause of that crash is found.
        let shouldAnimateSettingsPresentation: Bool = self.traitCollection.horizontalSizeClass != .Regular
        
        self.presentViewController(settingsController, animated: shouldAnimateSettingsPresentation, completion: nil)
    }
    
    
    //MARK: -  Web view
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        _searchBar.showsCancelButton = true
        _loadingErrorView.hidden = true
        _screenIdleView!.hidden = true
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
    
    func screenIdleTimeoutCallback() {
        
        // make sure the timer is invalidated
        _screenIdleTimer!.invalidate()
        
        // remember the original screen brightness so that we can
        // restore it accordingly.
        _orgBrightness = UIScreen.mainScreen().brightness
        fadeScreenBrightnessTo(0.0)
    }
    
    func fadeScreenBrightnessTo(var endValue: CGFloat, var fadeInterval: CGFloat = 0.01, var delayInSeconds: Double = 0.005) {
        var startValue: CGFloat = UIScreen.mainScreen().brightness
        
        if endValue < startValue {
            fadeInterval = -fadeInterval
        } else {
            // in case the user starts fading from 0 we have to disable screen blanking
            // first
            if _isScreenBlanked {
                // hide our black screenIdleView again and send it to the back.
                _screenIdleView!.hidden = true
                self.view.sendSubviewToBack(_screenIdleView!)
                _isScreenBlanked = false
            }
        }
        
        var brightness: CGFloat = startValue
        var i: Int = 0
        var dispatchTime: dispatch_time_t = DISPATCH_TIME_NOW
        
        while fabsf(Float(brightness - endValue)) > 0 {
    
            i++
            brightness += fadeInterval;
            
            if fabsf(Float(brightness - endValue)) < fabsf(Float(fadeInterval)) {
                brightness = endValue;
            }

            dispatchTime = dispatch_time(dispatchTime, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
            if i == 1 {
                dispatch_after(dispatchTime, dispatch_get_main_queue()) {
                    // disable motion detection for the time being
                    self._enabledMotionDetection = false
                    UIScreen.mainScreen().brightness += fadeInterval;
                }
            } else {
                dispatch_after(dispatchTime, dispatch_get_main_queue()) {
                    UIScreen.mainScreen().brightness += fadeInterval
                }
            }
        }

        // in case the user wants to completly blank a screen lets do it as the last operation
        if endValue == 0.0 {
            dispatchTime = dispatch_time(dispatchTime, Int64(delayInSeconds * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue()) {
                
                // completely set the brightness to zero
                UIScreen.mainScreen().brightness = 0;
                
                // bring the screenIdleView to the front
                self.view.bringSubviewToFront(self._screenIdleView!)
                self._screenIdleView!.hidden = false
                self._isScreenBlanked = true
            }
        }
        
        dispatchTime = dispatch_time(dispatchTime, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue()) {
            self._enabledMotionDetection = true
        }
    }
    
    func resetScreenIdleTimer(var fadeScreen: Bool = true) {
        NSLog("resetScreenIdleTimer")
        
        // invalidate screen idle timer
        if _screenIdleTimer != nil {
            _screenIdleTimer!.invalidate()
        }
        
        // if the screen is currently blanked bringt it back
        // online
        if _isScreenBlanked == true {
            if fadeScreen {
                fadeScreenBrightnessTo(_orgBrightness!)
            } else {
                // disable motion detection for the time being
                _enabledMotionDetection = false
                
                // hide our black screenIdleView again and send it to the back.
                _screenIdleView!.hidden = true
                self.view.sendSubviewToBack(_screenIdleView!)
                UIScreen.mainScreen().brightness = _orgBrightness!
                
                // bring motion detection back online
                _enabledMotionDetection = true
            }
            _isScreenBlanked = false
        }

        // restart screen idle timer in case no controls are visible
        if _areControlsVisible == false {
            let idleTimeout = NSUserDefaults.standardUserDefaults().objectForKey(AppDefaultKeys.ScreenIdleTimeout.rawValue) as! String
            if idleTimeout.isEmpty == false {
                let timeout = NSNumberFormatter().numberFromString(idleTimeout)
                _screenIdleTimer = NSTimer.scheduledTimerWithTimeInterval(timeout as! Double, target: self, selector: "screenIdleTimeoutCallback", userInfo: nil, repeats: false)
            }
        }
    }
  
    func stopScreenIdleTimer() {
        // invalidate screen idle timer
        if _screenIdleTimer != nil {
            _screenIdleTimer!.invalidate()
        }
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        _isCurrentPageLoaded = true
        _loadingTimer!.invalidate()
        _isWebViewLoading = false
        
        // lets fire the screen idle timer
        resetScreenIdleTimer()
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
    
    func loadURL(urlString: String) {
        let addrStr = httpifyString(urlString)
        let addr = NSURL(string: addrStr)
        if let webAddr = addr {
            let req = NSURLRequest(URL: webAddr)
            _webView!.loadRequest(req)
        } else {
            displayLoadingErrorMessage()
        }
        
    }
    
    func httpifyString(str: String) -> String {
        let lcStr:String = (str as NSString).lowercaseString
        if (count(lcStr) >= 7) {
            if (lcStr.rangeOfString("http://") != nil) {
                return str
            } else if (lcStr.rangeOfString("https://") != nil) {
                return str
            }
        }
        return "http://"+str
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
        if !_alertBuilder.isAlertOpen {
            var windowCount = UIApplication.sharedApplication().windows.count
            var targetView = UIApplication.sharedApplication().windows[windowCount-1].rootViewController!
            _framerAddress = address
            var alert = _alertBuilder.show(targetView as UIViewController!, title: "Connect to Framer?", text: "Looks like you (or someone on your network) is running Framer Studio. Want to connect?", cancelButtonText: "Nope", buttonText: "Sure!", color: UIColorFromHex(0x9178E2))
            alert.addAction(handleAlertConfirmTap)
            alert.setTextTheme(.Light)
            alert.setTitleFont("ClearSans")
            alert.setTextFont("ClearSans")
            alert.setButtonFont("ClearSans")
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
        if (count(_searchBar.text) > 0 && _isCurrentPageLoaded) {
            enable = true
        }
        _searchBar.refreshButton().enabled = enable
        return true
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        _searchBar.refreshButton().enabled = false
    }
    
    func searchBarRefreshWasPressed() {
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
}

