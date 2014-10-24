//
//  ViewController.swift
//  Unframed
//
//  Created by Jay Stakelon on 10/23/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UISearchBarDelegate, UIGestureRecognizerDelegate {


    @IBOutlet weak var _webView: UIWebView!
    @IBOutlet weak var _searchBar: SearchBar!
    
    var _panRecognizer: UIScreenEdgePanGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _panRecognizer = UIScreenEdgePanGestureRecognizer(target: self, action: Selector("handleScreenEdgePan:"))
        _panRecognizer!.edges = UIRectEdge.Top
        _panRecognizer?.delegate = self
        self.view.addGestureRecognizer(_panRecognizer!)
        _searchBar.delegate = self
        _webView.scalesPageToFit = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // UI show/hide
    func handleScreenEdgePan(sender: AnyObject) {
        println(sender)
        showSearch()
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func hideSearch() {
        UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self._searchBar.transform = CGAffineTransformMakeTranslation(0, -44)
        }, nil)
    }
    
    func showSearch() {
        UIView.animateWithDuration(0.5, delay: 0.05, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: nil, animations: {
            self._searchBar.transform = CGAffineTransformMakeTranslation(0, 0)
        }, nil)
    }
    
    
    
    // Web view
    func loadURL(urlString: String) {
        let addr = NSURL(string: urlString)
        let req = NSURLRequest(URL: addr!)
        _webView.loadRequest(req)
    }
    
    
    
    // Search bar
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        hideSearch()
        loadURL(searchBar.text)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        hideSearch()
    }


}

