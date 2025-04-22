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
    var note: String?

    init(id: UUID = UUID(), timestamp: Date, type: String, note: String?=nil) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.note = note
    }
}
  
 
