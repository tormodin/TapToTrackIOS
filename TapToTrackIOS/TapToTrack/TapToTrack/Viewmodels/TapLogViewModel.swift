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
    private let fileQueue = DispatchQueue(label: "com.tapToTrack.fileQueue")
    
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

    func logPush(type: String) {
        if logs.isEmpty {
            print("⏳ Not ready yet, queuing push")
            queuePush(type: type)
        } else {
            addLog(type: type)
        }
    }

    func queuePush(type: String) {
        let suite = UserDefaults(suiteName: "group.com.dittnamn.TapToTrack")
        var pending = suite?.stringArray(forKey: "pendingPushes") ?? []
        pending.append(type)
        suite?.set(pending, forKey: "pendingPushes")
        print("📥 Queued push: \(type)")
    }

    func processQueuedPushes() {
        let suite = UserDefaults(suiteName: "group.com.dittnamn.TapToTrack")
        let saved = suite?.stringArray(forKey: "pendingPushes") ?? []

        for type in saved {
            addLog(type: type)
            print("📤 Processed queued push from App Group: \(type)")
        }

        suite?.removeObject(forKey: "pendingPushes")
    }


}
