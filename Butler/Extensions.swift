//
//  Extensions.swift
//  Butler
//
//  Created by Nick O'Neill on 12/11/15.
//  Copyright © 2015 922am Burrito. All rights reserved.
//

import Foundation

// MARK: Graphics and animation

extension CGContext {
    static func currentContext() -> CGContext? {
        return UIGraphicsGetCurrentContext()
    }
}

extension CGColorSpace {
    static let GenericRGB = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB)
}

extension CAMediaTimingFunction {
    @nonobjc static let EaseInEaseOut = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
}

// MARK: GCD

extension dispatch_queue_t {
//    mySerialQueue.sync {
//        print("I’m on the queue!")
//    }
    final func async(block: dispatch_block_t) {
        dispatch_async(self, block)
    }

    final func async(group: dispatch_group_t, _ block: dispatch_block_t) {
        dispatch_group_async(group, self, block)
    }

    // `block` should be @noescape here, but can't be <http://openradar.me/19770770>
    final func sync(block: dispatch_block_t) {
        dispatch_sync(self, block)
    }
}

extension dispatch_group_t {
//    let group = dispatch_group_create()
//
//    concurrentQueue.async(group) {
//        print("I’m part of the group")
//    }
//
//    concurrentQueue.async(group) {
//        print("I’m independent, but part of the same group")
//    }
//    
//    group.waitForever()
    final func waitForever() {
        dispatch_group_wait(self, DISPATCH_TIME_FOREVER)
    }
}

