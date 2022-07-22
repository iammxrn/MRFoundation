//
//  GCD+Helper.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 09.02.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation

/// Submits a work item to a main queue if needed.
///
/// - Parameter work: The work item to be invoked on the main queue.
public func asyncOnMainIfNeeded(execute work: @escaping @convention(block) () -> Void) {
    if Thread.isMainThread {
        work()
    } else {
        DispatchQueue.main.async(execute: work)
    }
}

/// Submits a work item to a main queue.
///
/// - Parameter work: The work item to be invoked on the main queue.
public func asyncOnMain(execute work: @escaping @convention(block) () -> Void) {
    DispatchQueue.main.async(execute: work)
}

/// Submits a work item to a main queue with the time at which to schedule the block for execution.
/// - Parameter deadline: The time at which to schedule the block for execution.
/// Specifying the current time is less efficient than calling the async(execute:) method directly.
/// Do not specify the value in distantFuture; doing so is undefined.
/// - Parameter work: The work item to be invoked on the main queue.
public func asyncOnMainAfter(deadline: Double, execute work: @escaping @convention(block) () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + deadline, execute: work)
}
