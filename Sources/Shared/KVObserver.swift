//
//  KVObserver.swift
//  AppsaurusUIKit
//
//  Created by Brian Strobach on 2/1/18.
//

import Foundation

public protocol KVObserver: class{}

private extension AssociatedObjectKeys{
	static let observations = AssociatedObjectKey<Set<NSKeyValueObservation>>("observations")
}
extension KVObserver where Self: NSObject{
	public var observations: Set<NSKeyValueObservation>{
		get{
			return getAssociatedObject(for: .observations, initialValue: Set<NSKeyValueObservation>())
		}
		set{
			setAssociatedObject(newValue, for: .observations)
		}
	}


	/// Managed observations. Balance with call to clearObservations() in deinit{}
	///
	/// - Parameters:
	///   - object: Object to observe
	///   - keyPath: Keypath to observe
	///   - options: What type of changes you want to obsere
	///   - changeHandler: What to do when it changes.
	/// - Returns: The observation. Discardable as it is held in the .observations Set.
	@discardableResult
	public func observe<O: NSObject, V>(object: O,
                                        _ keyPath: KeyPath<O, V>,
                                        options: NSKeyValueObservingOptions = [.new, .old, .initial],
                                        changeHandler: @escaping (O, NSKeyValueObservedChange<V>) -> Void) -> NSKeyValueObservation{
		let observation = object.observe(keyPath, options: options, changeHandler: changeHandler)
		observations.insert(observation)
		return observation
	}
    
	public func clearObservations(){
		observations.removeAll()
	}
}
