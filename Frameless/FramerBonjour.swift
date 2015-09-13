//
//  FramerBonjour.swift
//  Frameless
//
//  Created by Jay Stakelon on 12/8/14.
//  Copyright (c) 2014 Jay Stakelon. All rights reserved.
//

import Foundation

class FramerBonjour:NSObject, NSNetServiceDelegate, NSNetServiceBrowserDelegate {
    
    var _browser:NSNetServiceBrowser!
    var _service:NSNetService!
    var delegate:FramerBonjourDelegate!
    
    override init() {
        super.init()
        _browser = NSNetServiceBrowser()
        _browser.delegate = self
    }
    
    func start() {
        _browser.searchForServicesOfType("_framerstudio._tcp", inDomain: "")
    }
    
    func stop() {
        _browser.stop()
    }
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService aNetService: NSNetService, moreComing: Bool) {
        if !moreComing {
            _service = aNetService
            _service.delegate = self
            _service.resolveWithTimeout(5)
        }
    }
    
    // ty, https://github.com/matti-kariluoma/ios-http_control
    // this grabs ip and port from the service
    func netServiceDidResolveAddress(sender: NSNetService) {
        if let addresses = sender.addresses {
            var host:String!
            for address in addresses {
                let ptr = UnsafePointer<sockaddr_in>(address.bytes)
                var addr = ptr.memory.sin_addr
                let buf = UnsafeMutablePointer<Int8>.alloc(Int(INET6_ADDRSTRLEN))
                let family = ptr.memory.sin_family
                var ipc = UnsafePointer<Int8>()
                if family == __uint8_t(AF_INET) {
                    ipc = inet_ntop(Int32(family), &addr, buf, __uint32_t(INET6_ADDRSTRLEN))
                }
                if let ip = String.fromCString(ipc) {
                    host = ip
                }
            }
            if let hoststr = host {
                resolveToHost(hoststr, port: sender.port)
            }
        }
    }
    
    func resolveToHost(host: String, port: Int) {
        let httpd = "http://\(host):\(port)/"
        delegate?.didResolveAddress(httpd)
    }
}

protocol FramerBonjourDelegate {
    func didResolveAddress(address:String)
}