//
//  HomeView.swift
//  TapToTrack
//
//  Created by tor modin on 2025-03-26.
// test

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: TapLogViewModel
    @ObservedObject private var flicManager = FlicManager.shared

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text(flicManager.isButtonConnected
                     ? "✅ Your Flic button is connected!"
                     : "⚠️ You are not connected to a Flic button.")
                    .font(.headline)
                    .foregroundColor(flicManager.isButtonConnected ? .green : .red)
                    .padding(.bottom)

                // Top: Three press buttons
                HStack(spacing: 16) {
                    PressButton(title: "Single", color: .blue) {
                        logPress(type: "single")
                    }

                    PressButton(title: "Double", color: .green) {
                        logPress(type: "double")
                    }

                    PressButton(title: "Long", color: .orange) {
                        logPress(type: "long")
                    }
                }

                Spacer()

                // Bottom row: Settings and Pushes
                HStack {
                    NavigationLink(destination: SettingsView()) {
                        Label("Settings", systemImage: "gearshape")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    NavigationLink(destination: PushLogView(viewModel: viewModel)) {
                        Label("Your Pushes", systemImage: "list.bullet")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                .buttonStyle(.bordered)
            }
            .navigationTitle("TapToTrack")
            .padding()
        }
        .onAppear {
            viewModel.processQueuedPushes()
            viewModel.loadLogs()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            viewModel.processQueuedPushes()
        }
    }

    private func logPress(type: String) {
        viewModel.logPush(type: type)
    }
    
}

struct PressButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(width: 80, height: 80)
                .background(color)
                .foregroundColor(.white)
                .clipShape(Circle())
        }
    }
}
