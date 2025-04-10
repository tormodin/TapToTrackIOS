//
//  HomeView.swift
//  TapToTrack
//
//  Created by tor modin on 2025-03-26.
// test

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: TapLogViewModel

    var body: some View {
        NavigationView {
            VStack {
                Spacer()

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
        }
        .onAppear {
            viewModel.loadLogs()
        }
    }

    private func logPress(type: String) {
        viewModel.addLog(type: type)
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
