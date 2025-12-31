import SwiftUI

struct NowPlayingView: View {
    @Bindable var player = RadioPlayer.shared
    var scheduleManager = ScheduleManager.shared

    private var isManuallyPlaying: Bool {
        player.isPlaying && !scheduleManager.isScheduleMode
    }

    private var categoryColor: Color {
        guard let category = player.currentStation?.category else { return .blue }
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
        if let station = player.currentStation, !scheduleManager.isScheduleMode {
            VStack(spacing: 0) {
                // Progress indicator line
                if isManuallyPlaying {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [categoryColor.opacity(0.3), categoryColor, categoryColor.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 2)
                }

                HStack(spacing: 14) {
                    // Station icon
                    ZStack {
                        Circle()
                            .fill(categoryColor.opacity(0.15))
                            .frame(width: 50, height: 50)

                        Image(systemName: station.category.icon)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(categoryColor)

                        if isManuallyPlaying {
                            Circle()
                                .strokeBorder(categoryColor.opacity(0.5), lineWidth: 2)
                                .frame(width: 50, height: 50)
                                .scaleEffect(1.0)
                        }
                    }

                    // Station info
                    VStack(alignment: .leading, spacing: 3) {
                        Text(station.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)

                        HStack(spacing: 4) {
                            if isManuallyPlaying {
                                Image(systemName: "waveform")
                                    .symbolEffect(.variableColor.iterative, options: .repeating, isActive: true)
                            } else {
                                Image(systemName: "pause.fill")
                            }
                            Text(isManuallyPlaying ? "재생 중" : "일시정지")
                                .font(.caption)
                        }
                        .foregroundStyle(isManuallyPlaying ? categoryColor : .secondary)
                    }

                    Spacer()

                    // Stop button
                    Button {
                        player.stop()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)

                    // Play/Pause button
                    Button {
                        player.togglePlayPause()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(categoryColor)
                                .frame(width: 50, height: 50)

                            Image(systemName: isManuallyPlaying ? "pause.fill" : "play.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .offset(x: isManuallyPlaying ? 0 : 2)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.1), radius: 10, y: -2)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        NowPlayingView()
    }
    .background(Color(.systemGroupedBackground))
}
