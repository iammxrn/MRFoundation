//
//  MRDispatchTimer.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 22.07.2022.
//  Copyright © 2022 mxrn. All rights reserved.
//

import Foundation

public final class MRDispatchTimer {

    
    // MARK: - Private Enums
    
    private enum State {
        case suspended
        case resumed
    }
    
    
    // MARK: - Public Properties
    
    public let timeInterval: TimeInterval
    
    public var eventHandler: ((_ timer: MRDispatchTimer) -> Void)?
    
    
    // MARK: - Private Properties
    
    private lazy var timer: DispatchSourceTimer = {
        let timer = DispatchSource.makeTimerSource()
        timer.schedule(deadline: .now() + self.timeInterval, repeating: self.timeInterval)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            self.eventHandler?(self)
        }
        return timer
    }()

    private var state: State = .suspended
    
    
    // MARK: - Init
    
    public init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        resume()
        eventHandler = nil
    }
    
    
    // MARK: - Public Methods
    
    public func resume() {
        guard state != .resumed else { return }
        
        state = .resumed
        timer.resume()
    }

    public func suspend() {
        guard state != .suspended else { return }
       
        state = .suspended
        timer.suspend()
    }
    
}
