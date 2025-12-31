import SwiftUI

enum AppMode: String, CaseIterable {
    case stations = "채널 선택"
    case schedule = "자동 재생"

    var icon: String {
        switch self {
        case .stations: return "radio.fill"
        case .schedule: return "clock.fill"
        }
    }
}

struct ContentView: View {
    @State private var selectedMode: AppMode = .stations
    @Bindable var player = RadioPlayer.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                modePicker

                ZStack(alignment: .bottom) {
                    Group {
                        switch selectedMode {
                        case .stations:
                            RadioStationListView()
                        case .schedule:
                            ScheduleView()
                        }
                    }

                    if selectedMode == .stations {
                        NowPlayingView()
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Simple Radio")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundStyle(.blue)
                            .symbolEffect(.variableColor.iterative, options: .repeating, isActive: player.isPlaying)
                        Text("Simple Radio")
                            .font(.headline)
                    }
                }
            }
        }
    }

    private var modePicker: some View {
        HStack(spacing: 0) {
            ForEach(AppMode.allCases, id: \.self) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMode = mode
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: mode.icon)
                            .font(.subheadline)
                        Text(mode.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(selectedMode == mode ? Color.blue : Color.clear)
                    )
                    .foregroundStyle(selectedMode == mode ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
}
