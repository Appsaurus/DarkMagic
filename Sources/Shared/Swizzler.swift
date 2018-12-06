//
//  Swizzler.swift
//  Pods
//
//  Created by Brian Strobach on 10/20/17.
//

import Foundation

// MARK: - Method Swizzling
internal protocol Swizzler {}

extension NSObject {
    static func swizzle(_ original: Selector, with replacement: Selector) {
            guard let originalMethod = class_getInstanceMethod(self, original) else { return }
            guard let swizzledMethod = class_getInstanceMethod(self, replacement) else { return }        
            method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}


public enum MethodType {
    case instance
    case `class`
}

public extension NSObject {
    /// Swizzle a method
    ///
    /// - Parameters:
    ///   - originalSelector: The method's original selector
    ///   - swizzledSelector: The new selector to swizzle with
    ///   - methodType: `MethodType` case determining whether you want to swizzle an instance method (`.instance`) or a class method (`.class`)
    /// - Throws: `DarkMagicError.methodNotFound` if the selectors cannot be found on `self`
    public static func swizzle(_ originalSelector: Selector, with swizzledSelector: Selector, methodType: MethodType = .instance) throws {
        
        let cls: AnyClass = methodType == .instance ? self : object_getClass(self)!
        
        guard let originalMethod = class_getMethod(cls, originalSelector, methodType),
            let swizzledMethod = class_getMethod(cls, swizzledSelector, methodType) else {
            throw DarkMagicError.methodNotFound
        }
        
        
        let didAddMethod = class_addMethod(cls,
                                           originalSelector,
                                           method_getImplementation(swizzledMethod),
                                           method_getTypeEncoding(swizzledMethod))
        
        if didAddMethod {
            class_replaceMethod(cls,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod))
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }
    
    /// Replace a method's implementation with a block
    ///
    /// - Parameters:
    ///   - originalSelector: The selector of the method you want to replace
    ///   - block: The block to be called instead of the method's implementation
    ///   - methodType: `MethodType` case determining whether you want to replace an instance method (`.instance`) or a class method (`.class`)
    /// - Throws: `DarkMagicError.methodNotFound` if the method cannot be found
    public static func replace(_ originalSelector: Selector, withBlock block: Any!, methodType: MethodType = .instance) throws {
        
        let cls: AnyClass = methodType == .instance ? self : object_getClass(self)!
        
        guard let originalMethod = class_getMethod(cls, originalSelector, methodType) else {
            throw DarkMagicError.methodNotFound
        }
        
        
        let swizzledImplementation = imp_implementationWithBlock(block)
        
        method_setImplementation(originalMethod, swizzledImplementation)
        
    }
}


internal func class_getMethod(_ cls: Swift.AnyClass!, _ name: Selector!, _ methodType: MethodType) -> Method! {
    switch methodType {
    case .instance: return class_getInstanceMethod(cls, name)
    case .class: return class_getClassMethod(cls, name)
    }
}
