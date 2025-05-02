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
    @State private var isSharing = false
    @State private var shareURL: URL?

    private enum TimeRange {
        case day, week, month
    }

    var body: some View {
        VStack(spacing: 16) {

            // Share button
            if let shareURL = shareURL {
                ShareLink(item: shareURL) {
                    Label("Share Pushes", systemImage: "square.and.arrow.up")
                }
                .padding()
            } else {
                Button {
                    self.shareURL = generateShareFile()
                } label: {
                    Label("Prepare Share File", systemImage: "doc.text")
                }
                .padding()
            }
            NavigationLink(destination: PieChartsView(viewModel: viewModel)) {
                Label("Pie Charts", systemImage: "chart.pie")
            }
            .padding()

            // Summary bars
            HStack {
                StatBox(title: "Today", count: count(for: .day))
                StatBox(title: "Week", count: count(for: .week))
                StatBox(title: "Month", count: count(for: .month))
            }
            .padding(.horizontal)

            // Log list with editable notes
            List(viewModel.logs) { log in
                VStack(alignment: .leading, spacing: 4) {
                    Text("Type: \(log.type.capitalized)")
                    Text(log.timestamp.formatted(date: .abbreviated, time: .standard))
                        .font(.caption)
                        .foregroundColor(.gray)

                    TextField("Add a note...", text: Binding(
                        get: { log.note ?? "" },
                        set: { newValue in
                            if let index = viewModel.logs.firstIndex(where: { $0.id == log.id }) {
                                viewModel.logs[index].note = newValue
                                viewModel.saveLogs()
                            }
                        }
                    ))
                    .font(.caption)
                    .textFieldStyle(.roundedBorder)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Your Pushes")
        .onAppear {
            viewModel.loadLogs()
        }
    }

    // MARK: - File generation
    private func generateShareFile() -> URL {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short

        let content = viewModel.logs.map { log in
            let note = log.note?.isEmpty == false ? " — Note: \(log.note!)" : ""
            return "\(formatter.string(from: log.timestamp)) — \(log.type.capitalized)\(note)"
        }.joined(separator: "\n")

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("PushLog.txt")

        do {
            try content.write(to: tempURL, atomically: true, encoding: .utf8)
            print("✅ Wrote to: \(tempURL)")
        } catch {
            print("❌ Failed to write file: \(error)")
        }

        return tempURL
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
