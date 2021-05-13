//
//  CapsLock.swift
//  TypoToggle
//
//  Created by Toby Harris on 13/05/2021.
//

// Adapted from https://github.com/SkrewEverything/Swift-Keylogger/

import Foundation
import IOKit.hid
import OSLog

class CapsLock {
    var state = false
    private var manager: IOHIDManager
    
    init() {
        // Create HID manager for all keyboard devices
        manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
        guard CFGetTypeID(manager) == IOHIDManagerGetTypeID()
        else {
            os_log("Could not create manager")
            return
        }
        IOHIDManagerSetDeviceMatching(
            manager,
            [
                kIOHIDDeviceUsagePageKey: kHIDPage_GenericDesktop,
                kIOHIDDeviceUsageKey: kHIDUsage_GD_Keyboard
            ] as CFDictionary
        )
        
        // Set callback to observe input, passing this instance as context
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        IOHIDManagerRegisterInputValueCallback(manager, CapsLock.handleIOHIDInputValueCallback, observer);
        
        // Go!
        guard IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess
        else {
            os_log("Could not open manager")
            return
        }
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.defaultMode.rawValue)
    }
    
    static let handleIOHIDInputValueCallback: IOHIDValueCallback = { context, result, sender, device in
        let element = IOHIDValueGetElement(device)
        
        let capsLockPage:UInt32 = 7 // This is an empirical value
        let capsLockUsage:UInt32 = 0x39 // IOKit kUSBCapsLockKey = 0x39
        guard IOHIDElementGetUsagePage(element) == capsLockPage && IOHIDElementGetUsage(element) == capsLockUsage
        else { return }
        
        let keyDown = IOHIDValueGetIntegerValue(device) == 1
        if keyDown {
            let capsLock = Unmanaged<CapsLock>.fromOpaque(context!).takeUnretainedValue()
            capsLock.state = !capsLock.state
            print("Caps state:", capsLock.state)
        }
    }
}

