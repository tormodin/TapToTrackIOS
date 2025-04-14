//
//  FlicScanView.swift
//  TapToTrack
//
//  Created by tor modin on 2025-04-12.
//
import SwiftUI

struct FlicScanView: View {
    @State private var isScanning = false
    @State private var scanStatus = "Idle"
    @State private var connectedButtonName: String?

    var body: some View {
        VStack(spacing: 20) {
            if let name = connectedButtonName {
                Text("✅ Connected to: \(name)")
                    .font(.headline)
                    .foregroundColor(.green)
                    .padding(.top)
            }
            Text("Hold your Flic button for at least 6 seconds until it starts blinking rapidly.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()

            Button(action: {
                if isScanning {
                    FLICManager.shared()?.stopScan()
                    scanStatus = "🔴 Scan aborted"
                } else {
                    FlicManager.shared.startScan()
                    scanStatus = "🔍 Scanning for Flic..."
                }
                isScanning.toggle()
            }) {
                Text(isScanning ? "Abort Scan" : "Start Scan")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isScanning ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Text(scanStatus)
                .font(.caption)
                .foregroundColor(.gray)

            Spacer()
        }
        .padding()
        .navigationTitle("Pair Flic Button")
        .onAppear {
            FlicManager.shared.onButtonConnected = { name in
                connectedButtonName = name
            }
        }
    }
}
