//
//  PieChartsView.swift
//  TapToTrack
//
//  Created by tor modin on 2025-04-23.
//

import SwiftUI
import Charts

struct PieChartsView: View {
    @ObservedObject var viewModel: TapLogViewModel

    private enum TimeRange: String, CaseIterable {
        case day = "Today", week = "This Week", month = "This Month"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    VStack(alignment: .leading) {
                        Text(range.rawValue)
                            .font(.headline)

                        Chart(dataFor(range: range)) { entry in
                            SectorMark(
                                angle: .value("Count", entry.count),
                                innerRadius: .ratio(0.5),
                                angularInset: 1
                            )
                            .foregroundStyle(by: .value("Type", entry.type))
                        }
                        .frame(height: 200)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Pie Charts")
    }

    private func dataFor(range: TimeRange) -> [PressTypeCount] {
        let calendar = Calendar.current
        let now = Date()
        let filtered = viewModel.logs.filter { log in
            switch range {
            case .day:
                return calendar.isDate(log.timestamp, inSameDayAs: now)
            case .week:
                return calendar.isDate(log.timestamp, equalTo: now, toGranularity: .weekOfYear)
            case .month:
                return calendar.isDate(log.timestamp, equalTo: now, toGranularity: .month)
            }
        }

        let grouped = Dictionary(grouping: filtered, by: { $0.type })
        return grouped.map { PressTypeCount(type: $0.key.capitalized, count: $0.value.count) }
    }

    struct PressTypeCount: Identifiable {
        var id: String { type }
        let type: String
        let count: Int
    }
}
