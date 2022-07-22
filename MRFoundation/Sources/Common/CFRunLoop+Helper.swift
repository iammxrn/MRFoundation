//
//  CFRunLoop+Helper.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 22.07.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import CoreFoundation

/// Enqueues a work item on the main runloop in default mode.
///
/// This method can be used when you highly cares about UI performance and want to execute operation without affecting your interface update.
///
/// - Parameter work: A work item to be executed.
///
/// - Attention: Unlike **asyncOnMain** the execution of work item will be delayed for execution whenever user interaction occurs.
///
public func performSafelyOnMain(execute work: @escaping @convention(block) () -> Void) {
    performOnMain(
        using: .defaultMode,
        execute: work
    )
}

/// Enqueues a work item on the main runloop to be executed as the runloop cycles in specified modes.
///
/// - Parameters:
///   - runLoopMode: Determines what events are processed by the run loop during a given iteration.
///   - work: A work item to be executed.
///   
public func performOnMain(
    using runLoopMode: CFRunLoopMode,
    execute work: @escaping @convention(block) () -> Void
) {
    CFRunLoopPerformBlock(
        CFRunLoopGetMain(),
        runLoopMode.rawValue,
        work
    )
}
