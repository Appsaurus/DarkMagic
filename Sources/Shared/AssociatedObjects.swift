//
//  AssociatedObjects.swift
//  Pods
//
//  Created by Brian Strobach on 10/20/17.
//

import Foundation

public enum AssociatedObjectPolicy: UInt{
    /**< Specifies a weak reference to the associated object. */
    //AKA OBJC_ASSOCIATION_ASSIGN
    case weak
    
    /**< Specifies a strong reference to the associated object.
     *   The association is not made atomically. */
    //AKA OBJC_ASSOCIATION_RETAIN_NONATOMIC
    case strong
    
    /**< Specifies that the associated object is copied.
     *   The association is not made atomically. */
    //AKA OBJC_ASSOCIATION_COPY_NONATOMIC
    case copy
    
    /**< Specifies a strong reference to the associated object.
     *   The association is made atomically. */
    //AKA OBJC_ASSOCIATION_RETAIN
    case strongAtomic
    
    /**< Specifies that the associated object is copied.
     *   The association is made atomically. */
    //AKA OBJC_ASSOCIATION_COPY
    case copyAtomic
    
    public var objc: objc_AssociationPolicy{
        switch self{
            
        case .weak:
            return .OBJC_ASSOCIATION_ASSIGN
        case .strong:
            return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        case .copy:
            return .OBJC_ASSOCIATION_COPY_NONATOMIC
        case .strongAtomic:
            return .OBJC_ASSOCIATION_RETAIN
        case .copyAtomic:
            return .OBJC_ASSOCIATION_COPY
        }
    }
}
public class AssociatedObjectKeys{
    public let value: [CChar]
    public let policy: AssociatedObjectPolicy
    public init(_ key: String, policy: AssociatedObjectPolicy = .strong) {
        self.value = key.cString(using: .utf8)!
        self.policy = policy
    }
}

public class AssociatedObjectKey<V>: AssociatedObjectKeys{}

public extension NSObject {
    
    func getAssociatedObject<V>(for key: AssociatedObjectKey<V>,
                                       initialValue: @escaping @autoclosure () -> V) -> V {
        return AssociatedUtils.getAssociatedObject(for: key,
                                                   of: self,
                                                   initialValue: initialValue())
    }
    
    func getAssociatedObject<V>(for key: AssociatedObjectKey<V>,
                                       optionalValue: (() -> V?)? = nil) -> V? {
        return AssociatedUtils.getAssociatedObject(for: key,
                                                   of: self,
                                                   optionalValue: optionalValue)
    }
    
    func setAssociatedObject<V>(_ value: V,
                                       for key: AssociatedObjectKey<V>){
        AssociatedUtils.setAssociatedObject(value,
                                            for: key,
                                            of: self)
    }
    func setAssociatedObject<V>(_ value: V?,
                                       for key: AssociatedObjectKey<V>){
        AssociatedUtils.setAssociatedObject(value,
                                            for: key,
                                            of: self)
    }
    
    /// Remove an associated valye for a given object
    ///
    /// - Parameter key: The key for the association
    /// - Returns: The old value associated with the key `key` for the object.
    @discardableResult
    func removeAssociatedObject<V>(for key: AssociatedObjectKey<V>) -> V? {
        let value = self.getAssociatedObject(for: key)
        self.setAssociatedObject(nil, for: key)
        return value
    }
    
    subscript <V>(key: AssociatedObjectKey<V>, initialValue: @escaping @autoclosure () -> V) -> V {
        get {
            return self.getAssociatedObject(for: key, initialValue: initialValue())
        }
        set {
            self.setAssociatedObject(newValue, for: key)
        }
    }
    
    subscript <V>(key: AssociatedObjectKey<V>) -> V? {
        get {
            return self.getAssociatedObject(for: key)
        }
        set {
            self.setAssociatedObject(newValue, for: key)
        }
    }
    
    subscript <V>(key: AssociatedObjectKey<V>, optionalValue: (() -> V?)?) -> V? {
        get {
            return self.getAssociatedObject(for: key, optionalValue: optionalValue)
        }
        set {
            self.setAssociatedObject(newValue, for: key)
        }
    }
    
    /// Removes all associations for a given object.
    func removeAllAssociatedObjects() {
        objc_removeAssociatedObjects(self)
    }
}


//For cases where you might not be able to lock the type down to an
// AssociatedObjectKey, such as an associated type in a protocol
extension NSObject {
    
    public func getAssociatedObject<V>(for key: UnsafeRawPointer,
                                       with policy: AssociatedObjectPolicy = .strong,
                                       initialValue: @escaping @autoclosure () -> V) -> V {
        return AssociatedUtils.getAssociatedObject(for: key,
                                                   of: self,
                                                   with: policy,
                                                   initialValue: initialValue())
    }
    
    public func getAssociatedObject<V>(for key: UnsafeRawPointer,
                                       with policy: AssociatedObjectPolicy = .strong,
                                       optionalValue: (() -> V?)? = nil) -> V? {
        return AssociatedUtils.getAssociatedObject(for: key,
                                                   of: self,
                                                   with: policy,
                                                   optionalValue: optionalValue)
    }
    
    public func setAssociatedObject<V>(_ value: V,
                                       for key: UnsafeRawPointer,
                                       with policy: AssociatedObjectPolicy = .strong){
        AssociatedUtils.setAssociatedObject(value,
                                            for: key,
                                            of: self,
                                            with: policy)
    }
}

public class AssociatedUtils{
    
    //MARK: Getters
    public static func getAssociatedObject<V>(for key: AssociatedObjectKey<V>,
                                              of host: Any,
                                              with policy: AssociatedObjectPolicy = .strong,
                                              initialValue: @escaping @autoclosure () -> V) -> V{
        return AssociatedUtils.getAssociatedObject(for: key.value,
                                                   of: host,
                                                   with: policy,
                                                   initialValue: initialValue())
    }
    
    public static func getAssociatedObject<V>(for key: UnsafeRawPointer,
                                              of host: Any,
                                              with policy: AssociatedObjectPolicy = .strong,
                                              initialValue: @escaping @autoclosure () -> V) -> V {
        return getAssociatedObject(for: key,
                                   of: host,
                                   with: policy,
                                   optionalValue: initialValue)!
    }
    
    
    public static func getAssociatedObject<V: Any>(for key: AssociatedObjectKey<V>,
                                                   of host: Any,
                                                   with policy: AssociatedObjectPolicy = .strong,
                                                   optionalValue: (() -> V?)? = nil) -> V?{
        return getAssociatedObject(for: key.value,
                                   of: host,
                                   with: key.policy,
                                   optionalValue: optionalValue)
        
    }
    public static func getAssociatedObject<V>(for key: UnsafeRawPointer,
                                              of host: Any,
                                              with policy: AssociatedObjectPolicy = .strong,
                                              optionalValue: (() -> V?)? = nil) -> V? {
        var value = objc_getAssociatedObject(host, key) as? V
        if value == nil, let initial = optionalValue?() {
            value = initial
            objc_setAssociatedObject(host, key, value, policy.objc)
        }
        return value
    }
    
    //MARK: Setters
    
    public static func setAssociatedObject<V>(_ value: V,
                                              for key: AssociatedObjectKey<V>,
                                              of host: Any) {
        AssociatedUtils.setAssociatedObject(value,
                                            for: key.value,
                                            of: host,
                                            with: key.policy)
    }
    
    public static func setAssociatedObject<V>(_ value: V?,
                                              for key: AssociatedObjectKey<V>,
                                              of host: Any) {
        AssociatedUtils.setAssociatedObject(value,
                                            for: key.value,
                                            of: host,
                                            with: key.policy)
    }
    
    
    public static func setAssociatedObject<V>(_ value: V,
                                              for key: UnsafeRawPointer,
                                              of host: Any,
                                              with policy: AssociatedObjectPolicy = .strong){
        objc_setAssociatedObject(host, key, value, policy.objc)
    }
}


