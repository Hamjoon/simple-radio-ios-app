import SwiftUI

struct SelectedHour: Identifiable {
    let id: Int
    var hour: Int { id }
}

struct ScheduleView: View {
    @Bindable var scheduleManager = ScheduleManager.shared
    @Bindable var player = RadioPlayer.shared
    @State private var selectedHour: SelectedHour?

    var body: some View {
        VStack(spacing: 0) {
            if scheduleManager.isScheduleMode {
                scheduleActiveHeader
            }

            ScrollViewReader { proxy in
                List {
                    Section {
                        ForEach(0..<24, id: \.self) { hour in
                            ScheduleRowView(
                                hour: hour,
                                station: scheduleManager.schedule.station(for: hour),
                                isCurrentHour: hour == scheduleManager.activeHour && scheduleManager.isScheduleMode,
                                hasError: hour == scheduleManager.activeHour && scheduleManager.isScheduleMode && player.error != nil
                            )
                            .id(hour)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedHour = SelectedHour(id: hour)
                            }
                        }
                    } header: {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundStyle(.blue)
                            Text("24시간 스케줄")
                                .font(.subheadline)
                                .fontWeight(.semibold)

                            Spacer()

                            let scheduledCount = (0..<24).filter { scheduleManager.schedule.station(for: $0) != nil }.count
                            Text("\(scheduledCount)/24 설정됨")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .textCase(nil)
                    }
                }
                .listStyle(.insetGrouped)
                .onAppear {
                    scrollToCurrentHour(proxy: proxy)
                }
                .onChange(of: scheduleManager.activeHour) { _, newHour in
                    if scheduleManager.isScheduleMode && newHour >= 0 {
                        withAnimation {
                            proxy.scrollTo(newHour, anchor: .center)
                        }
                    }
                }
            }
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

    private func scrollToCurrentHour(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                proxy.scrollTo(scheduleManager.currentHour, anchor: .center)
            }
        }
    }

    private var currentStation: RadioStation? {
        scheduleManager.schedule.station(for: scheduleManager.activeHour)
    }

    private var categoryColor: Color {
        guard let category = currentStation?.category else { return .blue }
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

    private var scheduleActiveHeader: some View {
        VStack(spacing: 0) {
            // Error banner
            if let error = player.error, currentStation != nil {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.white)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Spacer()
                    Button {
                        // Retry current station
                        if let station = currentStation {
                            player.play(station: station)
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("재시도")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.red)
            }

            HStack(spacing: 14) {
                // Icon
                ZStack {
                    Circle()
                        .fill(player.error != nil ? Color.red.opacity(0.15) : (currentStation != nil ? categoryColor : Color.orange).opacity(0.15))
                        .frame(width: 50, height: 50)

                    if player.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else if player.error != nil {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                    } else if let station = currentStation {
                        Image(systemName: station.category.icon)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(categoryColor)
                    } else {
                        Image(systemName: "speaker.slash.fill")
                            .font(.title2)
                            .foregroundStyle(.orange)
                    }
                }

                VStack(alignment: .leading, spacing: 3) {
                    if player.error != nil && currentStation != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                            Text("연결 실패")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.red)

                        Text(currentStation?.name ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if player.isLoading {
                        HStack(spacing: 4) {
                            Image(systemName: "antenna.radiowaves.left.and.right")
                                .font(.caption)
                            Text("연결 중...")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.blue)

                        Text(currentStation?.name ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if let station = currentStation {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.badge.checkmark.fill")
                                .font(.caption)
                            Text("자동 재생 중")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.green)

                        Text(station.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.caption)
                            Text("채널 없음")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.orange)

                        Text("\(String(format: "%02d", scheduleManager.activeHour)):00 시간대 설정 필요")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                // Current time badge
                VStack(spacing: 2) {
                    Text(String(format: "%02d", scheduleManager.activeHour))
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                    Text("시")
                        .font(.caption2)
                }
                .foregroundStyle(player.error != nil ? .red : (currentStation != nil ? categoryColor : .orange))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background((player.error != nil ? Color.red : (currentStation != nil ? categoryColor : Color.orange)).opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
        }
    }

    private var scheduleControlButton: some View {
        VStack(spacing: 12) {
            if !scheduleManager.isScheduleMode && !scheduleManager.schedule.hasAnySchedule {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                    Text("각 시간대를 탭하여 채널을 설정하세요")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if scheduleManager.isScheduleMode {
                        scheduleManager.stopScheduleMode()
                    } else {
                        scheduleManager.startScheduleMode()
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: scheduleManager.isScheduleMode ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title3)
                    Text(scheduleManager.isScheduleMode ? "자동 재생 중지" : "자동 재생 시작")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(scheduleManager.isScheduleMode ? Color.red : Color.blue)
                )
                .foregroundStyle(.white)
            }
            .disabled(!scheduleManager.schedule.hasAnySchedule && !scheduleManager.isScheduleMode)
            .opacity((!scheduleManager.schedule.hasAnySchedule && !scheduleManager.isScheduleMode) ? 0.5 : 1)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}

struct ScheduleRowView: View {
    let hour: Int
    let station: RadioStation?
    let isCurrentHour: Bool
    var hasError: Bool = false

    private var categoryColor: Color {
        guard let category = station?.category else { return .gray }
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

    private var timeOfDayIcon: String {
        switch hour {
        case 5..<12: return "sunrise.fill"
        case 12..<17: return "sun.max.fill"
        case 17..<21: return "sunset.fill"
        default: return "moon.stars.fill"
        }
    }

    private var timeOfDayColor: Color {
        switch hour {
        case 5..<12: return .orange
        case 12..<17: return .yellow
        case 17..<21: return .pink
        default: return .indigo
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            // Time badge
            VStack(spacing: 2) {
                Image(systemName: timeOfDayIcon)
                    .font(.caption2)
                    .foregroundStyle(timeOfDayColor)
                Text(String(format: "%02d", hour))
                    .font(.system(.body, design: .rounded))
                    .fontWeight(isCurrentHour ? .bold : .medium)
                Text("시")
                    .font(.caption2)
            }
            .frame(width: 44)
            .foregroundStyle(isCurrentHour ? (hasError ? .red : (station != nil ? categoryColor : .orange)) : .primary)

            // Divider
            Rectangle()
                .fill(isCurrentHour ? (hasError ? Color.red : (station != nil ? categoryColor : Color.orange)) : Color.secondary.opacity(0.3))
                .frame(width: 2, height: 36)
                .clipShape(Capsule())

            // Station info
            if let station = station {
                HStack(spacing: 10) {
                    if isCurrentHour && hasError {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .frame(width: 24)
                    } else {
                        Image(systemName: station.category.icon)
                            .font(.subheadline)
                            .foregroundStyle(categoryColor)
                            .frame(width: 24)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(station.name)
                            .font(.subheadline)
                            .fontWeight(isCurrentHour ? .semibold : .regular)
                            .foregroundStyle(hasError ? .red : (isCurrentHour ? categoryColor : .primary))

                        if isCurrentHour && hasError {
                            Text("연결 실패")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        } else {
                            Text(station.category.rawValue)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.dashed")
                        .font(.subheadline)
                        .foregroundStyle(isCurrentHour ? .orange : .secondary)

                    Text("탭하여 채널 선택")
                        .font(.subheadline)
                        .foregroundStyle(isCurrentHour ? .orange : .secondary)
                }
            }

            Spacer()

            // Status indicator
            if isCurrentHour {
                if hasError {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                } else if station != nil {
                    HStack(spacing: 4) {
                        Image(systemName: "waveform")
                            .symbolEffect(.variableColor.iterative, options: .repeating, isActive: true)
                    }
                    .font(.caption)
                    .foregroundStyle(categoryColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(categoryColor.opacity(0.15))
                    .clipShape(Capsule())
                } else {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.orange)
                }
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 6)
        .background(
            isCurrentHour ?
                RoundedRectangle(cornerRadius: 8)
                    .fill((hasError ? Color.red : (station != nil ? categoryColor : Color.orange)).opacity(0.08))
                    .padding(.horizontal, -12)
                : nil
        )
    }
}

struct StationPickerView: View {
    let hour: Int
    let currentStation: RadioStation?
    let onSelect: (RadioStation?) -> Void

    @Environment(\.dismiss) private var dismiss

    private func categoryColor(_ category: RadioStation.StationCategory) -> Color {
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
        NavigationStack {
            List {
                Section {
                    Button {
                        onSelect(nil)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.secondary.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "minus.circle")
                                    .foregroundStyle(.secondary)
                            }

                            Text("선택 안함")
                                .foregroundStyle(.primary)

                            Spacer()

                            if currentStation == nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }

                ForEach(RadioStation.StationCategory.allCases, id: \.self) { category in
                    let stations = RadioStation.stations(for: category)
                    if !stations.isEmpty {
                        Section {
                            ForEach(stations) { station in
                                Button {
                                    onSelect(station)
                                    dismiss()
                                } label: {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(categoryColor(category).opacity(0.15))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: category.icon)
                                                .foregroundStyle(categoryColor(category))
                                        }

                                        Text(station.name)
                                            .foregroundStyle(.primary)

                                        Spacer()

                                        if currentStation?.name == station.name {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                }
                            }
                        } header: {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                    .font(.caption)
                                    .foregroundStyle(categoryColor(category))
                                Text(category.rawValue)
                            }
                            .textCase(nil)
                        }
                    }
                }
            }
            .navigationTitle(String(format: "%02d:00 채널 선택", hour))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    ScheduleView()
}
