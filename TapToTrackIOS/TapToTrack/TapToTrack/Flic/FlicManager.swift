//
//  FlicManager.swift
//  TapToTrack
//
//  Created by tor modin on 2025-03-26.
//

import Foundation

class FlicManager: NSObject, ObservableObject {
    static let shared = FlicManager()
    @Published var isButtonConnected: Bool = false
    var onButtonConnected: ((String) -> Void)?

    
    private override init() {
        super.init()
    }

    func configure() {
        FLICManager.configure(with: self, buttonDelegate: self, background: true)
    }

    func startScan() {
        print("📡 Starting Flic scan...")

        FLICManager.shared()?.scanForButtons(
            stateChangeHandler: { event in
                switch event {
                case .discovered:
                    print("🔍 Flic discovered")
                case .connected:
                    print("🔗 Flic connecting")
                case .verified:
                    print("✅ Flic verified")
                case .verificationFailed:
                    print("❌ Flic verification failed")
                @unknown default:
                    break
                }
            },
            completion: { button, error in
                if let error = error {
                    print("⚠️ Scan failed: \(error.localizedDescription)")
                } else {
                    if let button = button {
                        print("🎉 Button verified: \(button.name ?? "Unnamed")")
                        button.triggerMode = .clickAndDoubleClickAndHold
                        button.delegate = self
                        button.connect()
                    }
                }
            }
        )
    }
}

extension FlicManager: FLICManagerDelegate, FLICButtonDelegate {
    func managerDidRestoreState(_ manager: FLICManager) {
        print("✅ Manager restored")
        for button in manager.buttons() {
            print("↩️ Restored button: \(button.name ?? "Unnamed")")
            button.delegate = self
            button.connect()
        }
    }
    func buttonIsReady(_ button: FLICButton) {
        print("✅ Button is ready: \(button.name ?? "Unnamed")")
        self.isButtonConnected = true
    }
    func manager(_ manager: FLICManager, didUpdate state: FLICManagerState) {
        print("⚙️ Manager state updated: \(state.rawValue)")
    }
    func refreshConnectionStatus() {
        let buttons = FLICManager.shared()?.buttons() ?? []
        var anyConnected = false

        for button in buttons {
            if button.isReady {
                anyConnected = true
                break
            }
        }

        DispatchQueue.main.async {
            self.isButtonConnected = anyConnected
        }
    }

    func buttonDidConnect(_ button: FLICButton) {
        let name = button.name ?? "Unnamed"
        print("✅ Connected to: \(name)")
        onButtonConnected?(name)
        self.isButtonConnected = true
    }

    func button(_ button: FLICButton, didFailToConnectWithError error: Error?) {
        print("❌ Failed to connect: \(button.name ?? "Unnamed") – \(error?.localizedDescription ?? "Unknown error")")
    }

    func button(_ button: FLICButton, didDisconnectWithError error: Error?) {
        print("🔌 Disconnected: \(button.name ?? "Unnamed") – \(error?.localizedDescription ?? "Unknown error")")
        self.isButtonConnected = false
    }
    func button(_ button: FLICButton, didReceiveButtonClick queued: Bool, age: Int) {
        print("🟦 Single click received")
        Task { @MainActor in
            TapLogViewModel.shared.addLog(type: "single")
        }
    }

    func button(_ button: FLICButton, didReceiveButtonDoubleClick queued: Bool, age: Int) {
        print("🟩 Double click received")
        Task { @MainActor in
            TapLogViewModel.shared.addLog(type: "double")
        }
    }

    func button(_ button: FLICButton, didReceiveButtonHold queued: Bool, age: Int) {
        print("🟧 Long press received")
        Task { @MainActor in
            TapLogViewModel.shared.addLog(type: "long")
        }
    }
}
