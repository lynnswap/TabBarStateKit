//
//  UITabBar+Extension.swift
//  TabBarStateKit
//
//  Created by lynnswap on 2025/09/13.
//

import UIKit
import ObjectiveC

extension UITabBar{
    /// Updates UITabBar's `_minimized` state
    @discardableResult
    public func _setTabBarMinimized(_ newValue: Bool, animated: Bool = false) -> Bool {
        let tabBar = self

        let call2: (AnyObject, Selector, Bool, Bool) -> Bool = { obj, sel, a, b in
            guard obj.responds(to: sel) else { return false }
            guard let imp = class_getMethodImplementation(object_getClass(obj), sel) else { return false }
            typealias Fn = @convention(c) (AnyObject, Selector, Bool, Bool) -> Void
            let fn = unsafeBitCast(imp, to: Fn.self)
            fn(obj, sel, a, b)
            return true
        }
        let call1: (AnyObject, Selector, Bool) -> Bool = { obj, sel, a in
            guard obj.responds(to: sel) else { return false }
            guard let imp = class_getMethodImplementation(object_getClass(obj), sel) else { return false }
            typealias Fn = @convention(c) (AnyObject, Selector, Bool) -> Void
            let fn = unsafeBitCast(imp, to: Fn.self)
            fn(obj, sel, a)
            return true
        }

        let selSetMinAnim = NSSelectorFromString("setMinimized:animated:")
        let selSetMin = NSSelectorFromString("setMinimized:")
        if let provider = _getObjcObjectIvar(target: tabBar, name: "_visualProvider") as AnyObject? {
            if call2(provider, selSetMinAnim, newValue, animated) || call1(provider, selSetMin, newValue) {
                tabBar.setNeedsLayout()
                tabBar.layoutIfNeeded()
                return true
            }
        }

        print("Failed to set minimized")
        return false
    }

    private func _getObjcObjectIvar(target: AnyObject, name: String) -> AnyObject? {
        var current: AnyClass? = object_getClass(target)
        while let cls = current, cls != NSObject.self {
            let obj = name.withCString { cname -> AnyObject? in
                guard let ivar = class_getInstanceVariable(cls, cname) else { return nil }
                return object_getIvar(target, ivar) as AnyObject?
            }
            if let obj { return obj }
            current = class_getSuperclass(cls)
        }
        return nil
    }
}
