import SwiftUI

enum AppMode: String, CaseIterable {
    case stations = "채널 선택 모드"
    case schedule = "자동 재생 모드"
}

struct ContentView: View {
    @State private var selectedMode: AppMode = .stations
    @Bindable var player = RadioPlayer.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("모드", selection: $selectedMode) {
                    ForEach(AppMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

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
            .navigationTitle("Garibong Radio")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
