//
//  Item.swift
//  FlashCard
//
//  Created by furkan gurcay on 3.08.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}