import SwiftUI

struct RadioStationListView: View {
    @Bindable var player = RadioPlayer.shared
    var scheduleManager = ScheduleManager.shared

    private func categoryColor(_ category: RadioStation.StationCategory) -> Color {
        switch category.color {
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "teal": return .teal
        default: return .gray
        }
    }

    var body: some View {
        List {
            ForEach(RadioStation.StationCategory.allCases, id: \.self) { category in
                let stations = RadioStation.stations(for: category)
                if !stations.isEmpty {
                    Section {
                        ForEach(stations) { station in
                            RadioStationRow(
                                station: station,
                                isPlaying: player.isPlaying && !scheduleManager.isScheduleMode,
                                isCurrentStation: player.currentStation?.id == station.id && !scheduleManager.isScheduleMode
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if scheduleManager.isScheduleMode {
                                    scheduleManager.disableScheduleMode()
                                }
                                player.play(station: station)
                            }
                        }
                    } header: {
                        HStack(spacing: 6) {
                            Image(systemName: category.icon)
                                .font(.caption)
                                .foregroundStyle(categoryColor(category))
                            Text(category.rawValue)
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Spacer()

                            Text("\(stations.count)개 채널")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .textCase(nil)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .contentMargins(.bottom, player.currentStation != nil && !scheduleManager.isScheduleMode ? 100 : 0, for: .scrollContent)
    }
}

#Preview {
    RadioStationListView()
}
