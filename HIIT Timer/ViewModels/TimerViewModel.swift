import Foundation
import SwiftUI
import AVFoundation

@MainActor
class TimerViewModel: ObservableObject {
    @Published private(set) var model = TimerModel()
    
    // Background Timer
    private var startDate: Date?
    
    // Adjustment UI state
    @Published var showingAdjuster: Bool = false
    @Published var currentAdjuster: AdjusterType?
    @Published var tempValue: Int = 0
    @Published var textInput: String = ""
    @Published var isEditingText: Bool = false
    
    // Smooth UI updates
    @Published var smoothProgressValue: Double = 0.0
    
    // Timer running state
    @Published var isRunning: Bool = false
    @Published var totalTimeRemaining: Int = 0
    private var totalWorkoutTimeAtStart: Int = 0
    private var totalPausedDuration: TimeInterval = 0
    private var pauseStartTime: Date?
    
    // Audio manager
    private let audioManager = AudioManager()
    
    // Timer
    private var timer: Timer?
    private var phaseEndTime: Date?
    private var phaseTimeRemainingExact: TimeInterval = 0
    
    // Workout tracking
    private var workoutStartTime: Date?
    @Published private(set) var workoutHistory: [WorkoutHistory] = []
    @Published var currentWorkoutName: String? = nil
    
    // Alert trackers
    private var hasPlayedHalfwayAlert = false
    private var hasPlayedCountdownAlert = false
    private var hasPlayedRoundResetCountdown = false
    
    // MARK: - Colors
    let ugandaColors: [Color] = [.black, .yellow, .red]
    let africanPatternColors: [Color] = [.orange, .red, .yellow, .green, .blue, .purple]
    
    // MARK: - Computed Phase Info
    var currentPhase: String {
        switch model.phase {
        case .getReady: return "GET READY"
        case .work: return "WORK"
        case .rest: return "REST"
        case .roundReset: return "ROUND RESET"
        case .finished: return "FINISHED"
        }
    }
    
    var currentPhaseColor: Color {
        switch model.phase {
        case .getReady: return .orange
        case .work: return .red
        case .rest: return .green
        case .roundReset: return .yellow
        case .finished: return .gray
        }
    }
    
    var currentMaxTime: Double {
        switch model.phase {
        case .getReady: return Double(model.getReadyTime)
        case .work: return Double(model.workTime)
        case .rest: return Double(model.restTime)
        case .roundReset: return Double(model.roundResetTime)
        case .finished: return 0
        }
    }
    
    var currentDisplayTime: Int {
        return model.timeRemaining
    }
    
    var formattedTotalTime: String {
        let minutes = totalTimeRemaining / 60
        let seconds = totalTimeRemaining % 60
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
    
    // MARK: - Public API (for Views)
    func toggleTimer() {
        if isRunning {
            // Pause
            isRunning = false
            timer?.invalidate()
            pauseStartTime = Date() // track pause start

            // Allow screen to sleep when paused
            UIApplication.shared.isIdleTimerDisabled = false
        } else {
            // Resume
            isRunning = true

            if workoutStartTime == nil { // first start
                workoutStartTime = Date()
                totalWorkoutTimeAtStart = calculateTotalPlannedTime()
                totalTimeRemaining = totalWorkoutTimeAtStart
            }

            // Adjust total paused duration
            if let pauseStart = pauseStartTime {
                totalPausedDuration += Date().timeIntervalSince(pauseStart)
                pauseStartTime = nil
            }

            // Resume phase with exact remaining time
            phaseEndTime = Date().addingTimeInterval(phaseTimeRemainingExact)

            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.tick()
                }
            }

            // Prevent screen from sleeping while timer is running
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }
    
    private func startTimer() {
        isRunning = true
        UIApplication.shared.isIdleTimerDisabled = true // keep screen awake
        
        if workoutStartTime == nil {
            workoutStartTime = Date()
            totalWorkoutTimeAtStart = calculateTotalPlannedTime()
            totalTimeRemaining = totalWorkoutTimeAtStart
        }
        
        if let pauseStart = pauseStartTime {
            totalPausedDuration += Date().timeIntervalSince(pauseStart)
            pauseStartTime = nil
        }
        
        scheduleTimer()
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        pauseStartTime = Date()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func resetTimer() {
        timer?.invalidate()
        isRunning = false
        UIApplication.shared.isIdleTimerDisabled = false
        resetToInitialState()
    }
    
    func stopTimer() {
        timer?.invalidate()
        isRunning = false
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    // MARK: - Timer Handling
    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    private func startPhase(_ phase: TimerModel.Phase, duration: Int) {
        model.phase = phase
        model.timeRemaining = duration
        smoothProgressValue = Double(duration)
        
        resetAlertTrackers()
        
        // Set exact remaining time
        phaseTimeRemainingExact = Double(duration)
        phaseEndTime = Date().addingTimeInterval(phaseTimeRemainingExact)
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1/60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }
    
    private func tick() {
        guard let phaseEnd = phaseEndTime else { return }
        
        // Phase timer
        let phaseRemaining = max(phaseEnd.timeIntervalSinceNow, 0)
        phaseTimeRemainingExact = phaseRemaining
        model.timeRemaining = Int(ceil(phaseRemaining))
        smoothProgressValue = phaseRemaining
        
        // Total workout timer
        if let workoutStart = workoutStartTime {
            let elapsed = Date().timeIntervalSince(workoutStart) - totalPausedDuration
            totalTimeRemaining = max(totalWorkoutTimeAtStart - Int(elapsed), 0)
        }
        
        handleAlerts()
        
        if phaseRemaining <= 0 {
            advanceToNextPhase()
        }
    }

    // MARK: - Phase Transitions
    private func advanceToNextPhase() {
        timer?.invalidate()
        
        switch model.phase {
        case .getReady:
            startPhase(.work, duration: model.workTime)
        case .work:
            if model.currentExercise < model.exercises {
                model.currentExercise += 1
                startPhase(.rest, duration: model.restTime)
            } else if model.currentRound < model.rounds {
                startPhase(.roundReset, duration: model.roundResetTime)
            } else {
                stopWorkout()
            }
        case .rest:
            startPhase(.work, duration: model.workTime)
        case .roundReset:
            model.currentRound += 1
            model.currentExercise = 1
            startPhase(.work, duration: model.workTime)
        case .finished:
            stopWorkout()
        }
    }
    
    // MARK: - Alerts
    private func handleAlerts() {
        switch model.phase {
        case .work:
            checkHalfwayAlert()
            checkWorkCountdownAlert()
        case .rest, .getReady, .roundReset:
            checkNonWorkCountdownAlert()
        default:
            break
        }
    }

    private func checkHalfwayAlert() {
        guard !hasPlayedHalfwayAlert else { return }
        if Int(ceil(smoothProgressValue)) == max(1, model.workTime / 2) {
            audioManager.playSound(named: "halfway_alert")
            hasPlayedHalfwayAlert = true
        }
    }

    private func checkWorkCountdownAlert() {
        guard !hasPlayedCountdownAlert else { return }
        if Int(ceil(smoothProgressValue)) <= 3 && Int(ceil(smoothProgressValue)) > 0 {
            audioManager.playSound(named: "countdown_alert") // different sound for work phase
            hasPlayedCountdownAlert = true
        }
    }

    private func checkNonWorkCountdownAlert() {
        guard !hasPlayedCountdownAlert else { return }
        if Int(ceil(smoothProgressValue)) <= 3 && Int(ceil(smoothProgressValue)) > 0 {
            audioManager.playSound(named: "countdown_alert_321") // rest/getReady/roundReset use this
            hasPlayedCountdownAlert = true
        }
    }

    private func resetAlertTrackers() {
        hasPlayedHalfwayAlert = false
        hasPlayedCountdownAlert = false
        hasPlayedRoundResetCountdown = false
    }

    // MARK: - Workout History
    private func stopWorkout() {
        timer?.invalidate()
        isRunning = false
        saveWorkoutHistory()
        model.phase = .finished
        audioManager.playSound(named: "Workout_Complete")
    }
    
    func saveWorkoutHistory(from existingWorkout: WorkoutHistory? = nil, name: String? = nil) {
        guard let start = workoutStartTime else { return }
        let duration = Int(Date().timeIntervalSince(start))
        
        let history = WorkoutHistory(
            id: existingWorkout?.id ?? UUID(),
            date: existingWorkout?.date ?? Date(),
            name: name ?? existingWorkout?.name ?? currentWorkoutName ?? "Workout",
            workTime: model.workTime,
            restTime: model.restTime,
            exercises: model.exercises,
            rounds: model.rounds,
            roundResetTime: model.roundResetTime,
            getReadyTime: model.getReadyTime,
            totalDuration: duration,
            completedRounds: model.currentRound,
            completedExercises: model.currentExercise
        )
        
        workoutHistory.insert(history, at: 0)
        persistWorkoutHistory()
    }

    func persistWorkoutHistory() {
        if let encoded = try? JSONEncoder().encode(workoutHistory) {
            UserDefaults.standard.set(encoded, forKey: "workoutHistory")
        }
    }
    
    func loadWorkoutHistory() {
        if let data = UserDefaults.standard.data(forKey: "workoutHistory"),
           let decoded = try? JSONDecoder().decode([WorkoutHistory].self, from: data) {
            workoutHistory = decoded
        }
    }
    
    func loadWorkout(_ workout: WorkoutHistory) {
        stopTimer()
        
        model.workTime = workout.workTime
        model.restTime = workout.restTime
        model.exercises = workout.exercises
        model.rounds = workout.rounds
        model.roundResetTime = workout.roundResetTime
        model.getReadyTime = workout.getReadyTime
        
        // Preserve the workout name for saving later
        currentWorkoutName = workout.name
        
        resetToInitialState()
        totalWorkoutTimeAtStart = calculateTotalPlannedTime()
        totalTimeRemaining = totalWorkoutTimeAtStart
    }
    
    func renameWorkout(at index: Int, to newName: String) {
        guard index < workoutHistory.count else { return }
        workoutHistory[index].name = newName
        persistWorkoutHistory()
    }
    
    // MARK: - Apply adjustment values from the UI
    func applyAdjustment(_ value: Int) {
        guard let adjuster = currentAdjuster else { return }
        switch adjuster {
        case .work: model.workTime = max(1, value)
        case .rest: model.restTime = max(1, value)
        case .rounds: model.rounds = max(1, value)
        case .roundReset: model.roundResetTime = max(1, value)
        case .exercises: model.exercises = max(1, value)
        case .getReady: model.getReadyTime = max(1, value)
        }
        
        // Recalculate total planned time whenever a phase is changed
        totalWorkoutTimeAtStart = calculateTotalPlannedTime()
        
        // If the workout already started, shift the workout end time
        if let start = workoutStartTime {
            // Recompute remaining based on new total
            let elapsed = Date().timeIntervalSince(start) - totalPausedDuration
            totalTimeRemaining = max(totalWorkoutTimeAtStart - Int(elapsed), 0)
        } else {
            // Before workout starts, just reset remaining to new planned total
            totalTimeRemaining = totalWorkoutTimeAtStart
        }
    }
    
    // MARK: - Helpers
    private func resetToInitialState() {
        model.currentRound = 1
        model.currentExercise = 1
        model.phase = .getReady
        model.timeRemaining = model.getReadyTime
        phaseTimeRemainingExact = Double(model.getReadyTime)
        
        totalWorkoutTimeAtStart = calculateTotalPlannedTime()
        totalTimeRemaining = totalWorkoutTimeAtStart
        
        totalPausedDuration = 0
        pauseStartTime = nil
        workoutStartTime = nil
        phaseEndTime = nil
        
        smoothProgressValue = Double(model.getReadyTime)
        resetAlertTrackers()
        isRunning = false
    }
    
    private func calculateTotalPlannedTime() -> Int {
        let workBlock = model.workTime * model.exercises
        let restBlock = model.restTime * max(0, model.exercises - 1)

        if model.rounds == 1 {
            // (work * exercises) + (rest * (exercises - 1)) + get ready
            return workBlock + restBlock + model.getReadyTime
        }

        if model.rounds == 2 {
            // work*exercises + rest*(exercises-1) + round reset*(rounds-1)
            // + work*exercises + rest*(exercises-1) + get ready
            return (workBlock + restBlock)
                 + (model.roundResetTime * (model.rounds - 1))
                 + (workBlock + restBlock)
                 + model.getReadyTime
        }

        // 3 or more rounds
        // ((work*exercises + rest*(exercises-1) + round reset*(rounds-1))*(rounds-1))
        // + work*exercises + rest*(exercises-1) + get ready
        return ((workBlock + restBlock + (model.roundResetTime * (model.rounds - 1))) * (model.rounds - 1))
             + (workBlock + restBlock)
             + model.getReadyTime
    }

    init() {
            resetToInitialState()
        }
}
