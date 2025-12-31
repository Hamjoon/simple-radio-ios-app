import SwiftUI

struct SelectedHour: Identifiable {
    let id: Int
    var hour: Int { id }
}

struct ScheduleView: View {
    @Bindable var scheduleManager = ScheduleManager.shared
    @State private var selectedHour: SelectedHour?

    var body: some View {
        VStack(spacing: 0) {
            if scheduleManager.isScheduleMode {
                scheduleActiveHeader
            }

            List {
                ForEach(0..<24, id: \.self) { hour in
                    ScheduleRowView(
                        hour: hour,
                        station: scheduleManager.schedule.station(for: hour),
                        isCurrentHour: hour == scheduleManager.currentHour && scheduleManager.isScheduleMode
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedHour = SelectedHour(id: hour)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .sheet(item: $selectedHour) { selected in
            StationPickerView(
                hour: selected.hour,
                currentStation: scheduleManager.schedule.station(for: selected.hour)
            ) { station in
                scheduleManager.setStation(station, for: selected.hour)
            }
        }
        .safeAreaInset(edge: .bottom) {
            if selectedHour == nil {
                scheduleControlButton
            }
        }
    }

    private var currentStation: RadioStation? {
        scheduleManager.schedule.station(for: scheduleManager.currentHour)
    }

    private var scheduleActiveHeader: some View {
        HStack {
            Image(systemName: currentStation != nil ? "clock.fill" : "speaker.slash.fill")
                .foregroundStyle(currentStation != nil ? .green : .orange)

            VStack(alignment: .leading, spacing: 2) {
                if let station = currentStation {
                    Text("자동 재생 모드 실행 중")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("현재: \(station.name)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("선택된 채널 없음")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("\(String(format: "%02d", scheduleManager.currentHour)):00 시간대에 채널을 선택하세요")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background((currentStation != nil ? Color.green : Color.orange).opacity(0.1))
    }

    private var scheduleControlButton: some View {
        Button {
            if scheduleManager.isScheduleMode {
                scheduleManager.stopScheduleMode()
            } else {
                scheduleManager.startScheduleMode()
            }
        } label: {
            HStack {
                Image(systemName: scheduleManager.isScheduleMode ? "stop.fill" : "play.fill")
                Text(scheduleManager.isScheduleMode ? "자동 재생 중지" : "자동 재생 시작")
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(scheduleManager.isScheduleMode ? Color.red : Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!scheduleManager.schedule.hasAnySchedule && !scheduleManager.isScheduleMode)
        .opacity((!scheduleManager.schedule.hasAnySchedule && !scheduleManager.isScheduleMode) ? 0.5 : 1)
        .padding()
        .background(.ultraThinMaterial)
    }
}

struct ScheduleRowView: View {
    let hour: Int
    let station: RadioStation?
    let isCurrentHour: Bool

    var body: some View {
        HStack {
            Text(String(format: "%02d:00", hour))
                .font(.system(.body, design: .monospaced))
                .fontWeight(isCurrentHour ? .bold : .regular)
                .foregroundStyle(isCurrentHour ? (station != nil ? .blue : .orange) : .primary)
                .frame(width: 60, alignment: .leading)

            if let station = station {
                VStack(alignment: .leading, spacing: 2) {
                    Text(station.name)
                        .font(.subheadline)
                        .fontWeight(isCurrentHour ? .semibold : .regular)

                    Text(station.category.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text("방송국 및 채널을 선택하세요")
                    .font(.subheadline)
                    .foregroundStyle(isCurrentHour ? .orange : .secondary)
            }

            Spacer()

            if isCurrentHour {
                if station != nil {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundStyle(.blue)
                        .symbolEffect(.variableColor.iterative, isActive: true)
                } else {
                    Image(systemName: "speaker.slash.fill")
                        .foregroundStyle(.orange)
                }
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StationPickerView: View {
    let hour: Int
    let currentStation: RadioStation?
    let onSelect: (RadioStation?) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        onSelect(nil)
                        dismiss()
                    } label: {
                        HStack {
                            Text("선택 안함")
                                .foregroundStyle(.primary)
                            Spacer()
                            if currentStation == nil {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }

                ForEach(RadioStation.StationCategory.allCases, id: \.self) { category in
                    let stations = RadioStation.stations(for: category)
                    if !stations.isEmpty {
                        Section(category.rawValue) {
                            ForEach(stations) { station in
                                Button {
                                    onSelect(station)
                                    dismiss()
                                } label: {
                                    HStack {
                                        Text(station.name)
                                            .foregroundStyle(.primary)
                                        Spacer()
                                        if currentStation?.name == station.name {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(String(format: "%02d:00 채널 선택", hour))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    ScheduleView()
}
