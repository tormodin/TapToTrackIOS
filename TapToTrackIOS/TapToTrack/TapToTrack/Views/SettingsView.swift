//
//  SettingsView.swift
//  TapToTrack
//
//  Created by tor modin on 2025-03-26.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: TapLogViewModel
    @State private var showConfirmation = false

    var body: some View {
        VStack(spacing: 20) {
            Button(role: .destructive) {
                showConfirmation = true
            } label: {
                Label("Clear Pushes", systemImage: "trash")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .padding(.top)

            Spacer()
        }
        .padding()
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

#Preview {
    SettingsView()
}
