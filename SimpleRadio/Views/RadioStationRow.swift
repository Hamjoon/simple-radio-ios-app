import SwiftUI

struct RadioStationRow: View {
    let station: RadioStation
    let isPlaying: Bool
    let isCurrentStation: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(station.name)
                    .font(.headline)
                    .foregroundStyle(isCurrentStation ? .blue : .primary)

                Text(station.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isCurrentStation {
                Image(systemName: isPlaying ? "speaker.wave.2.fill" : "speaker.fill")
                    .foregroundStyle(.blue)
                    .symbolEffect(.variableColor.iterative, isActive: isPlaying)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        RadioStationRow(
            station: RadioStation.allStations[0],
            isPlaying: true,
            isCurrentStation: true
        )
        RadioStationRow(
            station: RadioStation.allStations[1],
            isPlaying: false,
            isCurrentStation: false
        )
    }
}
