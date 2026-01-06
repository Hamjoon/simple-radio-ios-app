import SwiftUI

struct RadioStationListView: View {
    @Bindable var player = RadioPlayer.shared
    @Bindable var repository = StationRepository.shared
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
        Group {
            if repository.isLoading && repository.stations.isEmpty {
                loadingView
            } else if let error = repository.error, repository.stations.isEmpty {
                errorView(error)
            } else {
                stationListView
            }
        }
        .task {
            await repository.loadStations()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("방송국 목록 불러오는 중...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ error: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("방송국 목록을 불러올 수 없습니다")
                .font(.headline)

            Text(error)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await repository.refreshStations()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("다시 시도")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(Capsule())
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var stationListView: some View {
        List {
            ForEach(RadioStation.StationCategory.allCases, id: \.self) { category in
                let stations = repository.stations(for: category)
                if !stations.isEmpty {
                    Section {
                        ForEach(stations) { station in
                            let isCurrentStation = player.currentStation?.id == station.id && !scheduleManager.isScheduleMode
                            RadioStationRow(
                                station: station,
                                isPlaying: player.isPlaying && !scheduleManager.isScheduleMode,
                                isCurrentStation: isCurrentStation,
                                isLoading: isCurrentStation && player.isLoading,
                                hasError: isCurrentStation && player.error != nil
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
        .refreshable {
            await repository.refreshStations()
        }
        .contentMargins(.bottom, player.currentStation != nil && !scheduleManager.isScheduleMode ? 100 : 0, for: .scrollContent)
    }
}

#Preview {
    RadioStationListView()
}
