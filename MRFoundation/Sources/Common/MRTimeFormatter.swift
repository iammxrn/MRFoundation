//
//  MRTimeFormatter.swift
//  MRFoundation
//
//  Created by Roman Mogutnov on 17.02.2022.
//  Copyright © 2022 Roman Mogutnov. All rights reserved.
//

import Foundation


enum MRTimeFormatter {
    
    static func timeData(from seconds: Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
