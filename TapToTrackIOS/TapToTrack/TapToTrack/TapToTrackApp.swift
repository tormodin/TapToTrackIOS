//
//  TapToTrackApp.swift
//  TapToTrack
//
//  Created by tor modin on 2025-03-26.
//

import SwiftUI

@main
struct TapToTrackApp: App {
    @StateObject private var viewModel = TapLogViewModel.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(viewModel)
                .onOpenURL { url in
                    handleIncomingURL(url)
                    
                }
                .onAppear {
                    viewModel.processQueuedPushes()
                }

        }
    }

    private func handleIncomingURL(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme == "taptrack",
              components.host == "log",
              let type = components.queryItems?.first(where: { $0.name == "type" })?.value
        else {
            print("Invalid or missing data in URL")
            return
        }

        print("📡 Received tap of type: \(type)")
        TapLogViewModel.shared.queuePush(type: type)
    }

}


