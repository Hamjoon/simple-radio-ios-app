import SwiftUI

struct NowPlayingView: View {
    @Bindable var player = RadioPlayer.shared
    var scheduleManager = ScheduleManager.shared

    private var isManuallyPlaying: Bool {
        player.isPlaying && !scheduleManager.isScheduleMode
    }

    var body: some View {
        if let station = player.currentStation, !scheduleManager.isScheduleMode {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(station.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Text(station.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    player.togglePlayPause()
                } label: {
                    Image(systemName: isManuallyPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        NowPlayingView()
    }
}
