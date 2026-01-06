import SwiftUI

struct RadioStationRow: View {
    let station: RadioStation
    let isPlaying: Bool
    let isCurrentStation: Bool
    var isLoading: Bool = false
    var hasError: Bool = false

    private var categoryColor: Color {
        switch station.category.color {
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
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(hasError ? Color.red.opacity(0.15) : categoryColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                if isLoading && isCurrentStation {
                    ProgressView()
                        .scaleEffect(0.7)
                } else if hasError && isCurrentStation {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                } else {
                    Image(systemName: station.category.icon)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(categoryColor)
                }
            }

            // Station info
            VStack(alignment: .leading, spacing: 3) {
                Text(station.name)
                    .font(.body)
                    .fontWeight(isCurrentStation ? .semibold : .regular)
                    .foregroundStyle(hasError ? .red : (isCurrentStation ? categoryColor : .primary))

                HStack(spacing: 4) {
                    if isLoading && isCurrentStation {
                        Text("연결 중...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if hasError && isCurrentStation {
                        Text("연결 실패 - 탭하여 재시도")
                            .font(.caption)
                            .foregroundStyle(.red)
                    } else {
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .font(.caption2)
                        Text("실시간 스트리밍")
                            .font(.caption)
                    }
                }
                .foregroundStyle(hasError ? .red : .secondary)
            }

            Spacer()

            // Playing indicator
            if isCurrentStation {
                HStack(spacing: 4) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.6)
                    } else if hasError {
                        Image(systemName: "arrow.clockwise")
                            .font(.caption)
                            .foregroundStyle(.red)
                    } else if isPlaying {
                        WaveformView()
                            .frame(width: 20, height: 16)
                    } else {
                        Image(systemName: "pause.fill")
                            .font(.caption)
                            .foregroundStyle(categoryColor)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(hasError ? Color.red.opacity(0.15) : categoryColor.opacity(0.15))
                .clipShape(Capsule())
            }
        }
        .padding(.vertical, 6)
    }
}

// Animated waveform for playing state
struct WaveformView: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.blue)
                    .frame(width: 3)
                    .frame(height: animating ? CGFloat.random(in: 8...16) : CGFloat.random(in: 4...8))
                    .animation(
                        .easeInOut(duration: 0.4)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.1),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

