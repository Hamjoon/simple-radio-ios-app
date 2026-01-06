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
                // Error banner
                if let error = player.error {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.white)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Spacer()
                        Button {
                            player.clearError()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red)
                }

                // Progress indicator line
                if isManuallyPlaying && player.error == nil {
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
                            .fill(player.error != nil ? Color.red.opacity(0.15) : categoryColor.opacity(0.15))
                            .frame(width: 50, height: 50)

                        if player.isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else if player.error != nil {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title2)
                                .foregroundStyle(.red)
                        } else {
                            Image(systemName: station.category.icon)
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(categoryColor)
                        }

                        if isManuallyPlaying && player.error == nil {
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
                            if player.isLoading {
                                Text("연결 중...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else if player.error != nil {
                                Text("연결 실패")
                                    .font(.caption)
                                    .foregroundStyle(.red)
                            } else if isManuallyPlaying {
                                Image(systemName: "waveform")
                                    .symbolEffect(.variableColor.iterative, options: .repeating, isActive: true)
                                Text("재생 중")
                                    .font(.caption)
                            } else {
                                Image(systemName: "pause.fill")
                                Text("일시정지")
                                    .font(.caption)
                            }
                        }
                        .foregroundStyle(player.error != nil ? .red : (isManuallyPlaying ? categoryColor : .secondary))
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

                    // Play/Pause/Retry button
                    Button {
                        if player.error != nil {
                            // Retry on error
                            player.play(station: station)
                        } else {
                            player.togglePlayPause()
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(player.error != nil ? Color.red : categoryColor)
                                .frame(width: 50, height: 50)

                            if player.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else if player.error != nil {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                            } else {
                                Image(systemName: isManuallyPlaying ? "pause.fill" : "play.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .offset(x: isManuallyPlaying ? 0 : 2)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(player.isLoading)
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
