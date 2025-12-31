import SwiftUI

struct NowPlayingView: View {
    @Bindable var player = RadioPlayer.shared

    var body: some View {
        if let station = player.currentStation {
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
                    Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)

                Button {
                    player.stop()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
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
