import Foundation
import Observation

@Observable
final class ScheduleManager {
    static let shared = ScheduleManager()

    private(set) var schedule: HourlySchedule
    private(set) var isScheduleMode = false
    private(set) var activeHour: Int = -1
    private var timer: Timer?

    private init() {
        schedule = HourlySchedule.load()
    }

    var currentHour: Int {
        Calendar.current.component(.hour, from: Date())
    }

    func updateSchedule(_ newSchedule: HourlySchedule) {
        schedule = newSchedule
        schedule.save()

        if isScheduleMode {
            playStationForCurrentHour()
        }
    }

    func setStation(_ station: RadioStation?, for hour: Int) {
        schedule.setStation(station, for: hour)
        schedule.save()

        if isScheduleMode && hour == currentHour {
            playStationForCurrentHour()
        }
    }

    func startScheduleMode() {
        guard schedule.hasAnySchedule else { return }

        isScheduleMode = true
        activeHour = -1
        playStationForCurrentHour()
        startTimer()
    }

    func stopScheduleMode() {
        isScheduleMode = false
        stopTimer()
        RadioPlayer.shared.stop()
    }

    func disableScheduleMode() {
        isScheduleMode = false
        stopTimer()
    }

    private func startTimer() {
        stopTimer()

        // Calculate seconds until next minute boundary
        let now = Date()
        let seconds = Calendar.current.component(.second, from: now)
        let delayToNextMinute = Double(60 - seconds)

        // Fire at the start of next minute, then every 60 seconds
        timer = Timer.scheduledTimer(withTimeInterval: delayToNextMinute, repeats: false) { [weak self] _ in
            self?.checkHourChange()
            self?.startRepeatingTimer()
        }
    }

    private func startRepeatingTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.checkHourChange()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func checkHourChange() {
        let hour = currentHour
        if hour != activeHour {
            playStationForCurrentHour()
        }
    }

    private func playStationForCurrentHour() {
        let hour = currentHour
        activeHour = hour

        let player = RadioPlayer.shared
        if let station = schedule.station(for: hour) {
            if player.currentStation?.name != station.name || !player.isPlaying {
                player.play(station: station)
            }
        } else {
            player.stop()
        }
    }
}
