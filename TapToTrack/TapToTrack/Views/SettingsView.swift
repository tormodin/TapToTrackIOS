//
//  SettingsView.swift
//  TapToTrack
//
//  Created by tor modin on 2025-03-26.
//
import SwiftUI

struct SettingsView: View {
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @EnvironmentObject var viewModel: TapLogViewModel
    @State private var showConfirmation = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Toggle("Vibrate on Push", isOn: $hapticsEnabled)
                    .padding(.horizontal)
                
                // MARK: - Navigation to Pairing Screen
                NavigationLink(destination: FlicScanView()) {
                    Label("Pair Flic Button", systemImage: "dot.radiowaves.left.and.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)

                // MARK: - Clear Pushes Button
                Button(role: .destructive) {
                    showConfirmation = true
                } label: {
                    Label("Clear Pushes", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)

                Spacer()
            }
            .padding()
            .navigationTitle("Settings")
            .alert("Are you sure?", isPresented: $showConfirmation) {
                Button("Delete", role: .destructive) {
                    viewModel.clearLogs()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will remove all your pushes.")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(TapLogViewModel.shared)
}
