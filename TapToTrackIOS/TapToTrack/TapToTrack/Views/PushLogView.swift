//
//  PushLogView.swift
//  TapToTrack
//
//  Created by tor modin on 2025-03-26.
//

import Foundation
import SwiftUI

struct PushLogView: View {
    @ObservedObject var viewModel: TapLogViewModel

    private enum TimeRange {
        case day, week, month
    }

    var body: some View {
        VStack(spacing: 16) {
            // Summary bars
            HStack {
                StatBox(title: "Today", count: count(for: .day))
                StatBox(title: "Week", count: count(for: .week))
                StatBox(title: "Month", count: count(for: .month))
            }
            .padding(.horizontal)

            // Log list
            List(viewModel.logs) { log in
                VStack(alignment: .leading) {
                    Text("Type: \(log.type.capitalized)")
                    Text(log.timestamp.formatted(date: .abbreviated, time: .standard))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Your Pushes")
        .onAppear {
            viewModel.loadLogs()
        }
    }

    // MARK: - Summary logic
    private func count(for range: TimeRange) -> Int {
        let calendar = Calendar.current
        let now = Date()

        return viewModel.logs.filter { log in
            switch range {
            case .day:
                return calendar.isDate(log.timestamp, inSameDayAs: now)
            case .week:
                return calendar.isDate(log.timestamp, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(log.timestamp, equalTo: now, toGranularity: .month)
            }
        }.count
    }
}

// MARK: - UI for stat box
struct StatBox: View {
    let title: String
    let count: Int

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.largeTitle)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}
