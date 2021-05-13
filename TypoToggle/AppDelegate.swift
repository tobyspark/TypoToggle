//
//  AppDelegate.swift
//  TypoToggle
//
//  Created by Toby Harris on 12/05/2021.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBar: StatusBarController?
    var popover = NSPopover()
    
    let capsLock = CapsLock()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let contentView = ContentView()
        popover.contentSize = NSSize(width: 360, height: 360)
        popover.contentViewController = NSHostingController(rootView: contentView)
        statusBar = StatusBarController(popover)
        
        capsLock.handler = {
            // With global hotkeys set for 'Smart Quotes' and 'Text Replacement',
            // the following will send keystrokes to trigger them.
            // System Preferences → Keyboard → Shortcuts → App Shortcuts
            // Currently cmd-alt-ctrl-shift-F18 and -F19
            
            // https://gist.github.com/swillits/df648e87016772c7f7e5dbed2b345066
            let f18 : UInt16 = 0x4F
            let f19 : UInt16 = 0x50
            
            let modifiers: CGEventFlags = [
                CGEventFlags.maskCommand,
                CGEventFlags.maskAlternate,
                CGEventFlags.maskControl,
                CGEventFlags.maskShift,
            ]
            
            for key in [f18, f19] {
                let keyDownEvent = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: true)
                keyDownEvent?.flags = modifiers
                keyDownEvent?.post(tap: CGEventTapLocation.cghidEventTap)
                
                let keyUpEvent = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: false)
                keyUpEvent?.flags = CGEventFlags.maskCommand
                keyUpEvent?.post(tap: CGEventTapLocation.cghidEventTap)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

