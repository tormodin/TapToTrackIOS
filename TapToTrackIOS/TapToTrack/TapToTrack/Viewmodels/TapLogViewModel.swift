//
//  TapLogViewModel.swift
//  TapToTrack
//
//  Created by tor modin on 2025-03-26.
//

import Foundation
import SwiftUI

@MainActor
class TapLogViewModel: ObservableObject {
    static let shared = TapLogViewModel()
    
    private let pendingPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("pendingLogs.json")

    
    @Published var logs: [TapLog] = []
    
    private init() {
        loadLogs()
    }
    
    private let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tapLogs.json")

    func saveLogs() {
        do {
            let data = try JSONEncoder().encode(logs)
            try data.write(to: savePath)
        } catch {
            print("Failed to save logs: \(error)")
        }
    }

    func loadLogs() {
        do {
            let data = try Data(contentsOf: savePath)
            logs = try JSONDecoder().decode([TapLog].self, from: data)
        } catch {
            print("No saved logs found or failed to load: \(error)")
        }
    }

    func addLog(type: String) {
        let newLog = TapLog(timestamp: Date(), type: type)
        logs.insert(newLog, at: 0)
        print("addLog called with type: \(type), total logs: \(logs.count)")
        saveLogs()
    }


    func clearLogs() {
        logs.removeAll()
        saveLogs()
    }

    func queuePush(type: String) {
        var pending: [String] = []

        // Load existing pending pushes
        if let data = try? Data(contentsOf: pendingPath),
           let saved = try? JSONDecoder().decode([String].self, from: data) {
            pending = saved
        }

        pending.append(type)

        // Save updated list
        if let data = try? JSONEncoder().encode(pending) {
            try? data.write(to: pendingPath)
        }

        print("📥 Queued push: \(type)")
    }
    func processQueuedPushes() {
        guard let data = try? Data(contentsOf: pendingPath),
              let saved = try? JSONDecoder().decode([String].self, from: data) else { return }

        for type in saved {
            addLog(type: type)
            print("📤 Processed queued push: \(type)")
        }

        // Clear pending
        try? FileManager.default.removeItem(at: pendingPath)
    }



}
