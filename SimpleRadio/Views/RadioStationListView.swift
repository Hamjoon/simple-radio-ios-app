import SwiftUI

struct RadioStationListView: View {
    @Bindable var player = RadioPlayer.shared

    var body: some View {
        List {
            ForEach(RadioStation.StationCategory.allCases, id: \.self) { category in
                let stations = RadioStation.stations(for: category)
                if !stations.isEmpty {
                    Section(category.rawValue) {
                        ForEach(stations) { station in
                            RadioStationRow(
                                station: station,
                                isPlaying: player.isPlaying,
                                isCurrentStation: player.currentStation?.id == station.id
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                player.play(station: station)
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .contentMargins(.bottom, player.currentStation != nil ? 80 : 0, for: .scrollContent)
    }
}

#Preview {
    RadioStationListView()
}
