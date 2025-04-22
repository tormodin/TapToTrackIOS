//
//  TapLog.swift
//  TapToTrack
//
//  Created by tor modin on 2025-03-26.
//
import Foundation

struct TapLog: Identifiable, Codable {
    var id: UUID
    let timestamp: Date
    let type: String

    init(id: UUID = UUID(), timestamp: Date, type: String) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
    }
}
  
 
