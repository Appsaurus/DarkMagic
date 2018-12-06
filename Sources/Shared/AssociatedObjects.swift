//
//  AssociatedObjects.swift
//  Pods
//
//  Created by Brian Strobach on 10/20/17.
//

import Foundation

//Based on https://github.com/lukaskollmer/RuntimeKit/blob/master/RuntimeKit/Sources/AssociatedObject.swift

public class AssociatedObjectKeys{
	fileprivate let value: [CChar]
	fileprivate let policy: objc_AssociationPolicy
	public init(_ key: String, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
		self.value = key.cString(using: .utf8)!
		self.policy = policy
	}
}

public class AssociatedObjectKey<T>: AssociatedObjectKeys{}
public class AssociatedOptionalObjectKey<T>: AssociatedObjectKeys {}

public extension NSObject {

	//MARK: Required values

	/// Sets an associated value for a given object using a given key and association policy.
	///
	/// - Parameters:
	///   - value: The value to associate with the key for object.
	///   - key: The key for the association
	///   - policy: The policy for the association. Default value is OBJC_ASSOCIATION_RETAIN_NONATOMIC
	public func setAssociatedObject<T>(_ value: T, forKey key: AssociatedObjectKey<T>) {
		objc_setAssociatedObject(self, key.value, value, key.policy)
	}

	/// Returns the value associated with a given object for a given key.
	///
	/// - Parameter key: The key for the association
	/// - Returns: The value associated with the key `key` for the object.
	public func getAssociatedObject<T>(forKey key: AssociatedObjectKey<T>, initialValue: @autoclosure () -> T) -> T {
		var currentObj = objc_getAssociatedObject(self, key.value) as? T
		if currentObj == nil{
			setAssociatedObject(initialValue(), forKey: key)
			currentObj = objc_getAssociatedObject(self, key.value) as? T
		}
		return currentObj!
	}

	public subscript <T>(key: AssociatedObjectKey<T>, initialValue: @autoclosure () -> T) -> T {
		get {
			return self.getAssociatedObject(forKey: key, initialValue: initialValue)
		}
		set {
			self.setAssociatedObject(newValue, forKey: key)
		}
	}

	//MARK: Optionals

	/// Sets an associated value for a given object using a given key and association policy.
	///
	/// - Parameters:
	///   - value: The value to associate with the key for object. Pass `nil` to clear an existing association.
	///   - key: The key for the association
	///   - policy: The policy for the association. Default value is OBJC_ASSOCIATION_RETAIN_NONATOMIC
	public func setAssociatedObject<T>(_ value: T?, forKey key: AssociatedOptionalObjectKey<T>) {
		objc_setAssociatedObject(self, key.value, value, key.policy)
	}

	/// Returns the value associated with a given object for a given key.
	///
	/// - Parameter key: The key for the association
	/// - Returns: The value associated with the key `key` for the object.
	public func getAssociatedObject<T>(forKey key: AssociatedOptionalObjectKey<T>, initialValue: (() -> T?)? = nil) -> T? {
		var currentObj = objc_getAssociatedObject(self, key.value) as? T
		if let initializer = initialValue, currentObj == nil{
			setAssociatedObject(initializer(), forKey: key)
			currentObj = objc_getAssociatedObject(self, key.value) as? T
		}
		return currentObj
	}

	/// Remove an associated valye for a given object
	///
	/// - Parameter key: The key for the association
	/// - Returns: The old value associated with the key `key` for the object.
	@discardableResult
	public func removeAssociatedObject<T>(forKey key: AssociatedOptionalObjectKey<T>) -> T? {
		let value = self.getAssociatedObject(forKey: key)

		self.setAssociatedObject(nil, forKey: key)

		return value
	}

	public subscript <T>(key: AssociatedOptionalObjectKey<T>, initialValue: (() -> T)?) -> T? {
		get {
			return self.getAssociatedObject(forKey: key, initialValue: initialValue)
		}
		set {
			self.setAssociatedObject(newValue, forKey: key)
		}
	}
	
	public subscript <T>(key: AssociatedOptionalObjectKey<T>) -> T? {
		get {
			return self.getAssociatedObject(forKey: key, initialValue: nil)
		}
		set {
			self.setAssociatedObject(newValue, forKey: key)
		}
	}


	/// Removes all associations for a given object.
	public func removeAllAssociatedObjects() {
		objc_removeAssociatedObjects(self)
	}
}
