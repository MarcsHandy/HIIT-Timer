import SwiftUI
import AVFoundation

@MainActor
class TimerViewModel: ObservableObject {
    @Published var model = TimerModel()
    @Published var isRunning: Bool = false
    @Published var showingAdjuster: Bool = false
    @Published var currentAdjuster: AdjusterType?
    @Published var tempValue: Int = 0
    @Published var isEditingText: Bool = false
    @Published var textInput: String = ""
    
    // Alert trackers
    @Published var hasPlayedHalfwayAlert: Bool = false
    @Published var hasPlayedCountdownAlert: Bool = false
    @Published var hasPlayedRestCountdown: Bool = false
    @Published var hasPlayedGetReadyCountdown: Bool = false
    @Published var hasPlayedRoundResetCountdown: Bool = false
    
    private var smoothAnimationTimer: Timer?
    private let audioManager = AudioManager()
    
    // For smooth animation across all phases
    private var phaseStartTime: Date?
    private var currentPhaseDuration: TimeInterval = 0.0
    private var smoothProgressValue: Double = 0.0
    
    // Ugandan colors
    let ugandaColors: [Color] = [.black, .yellow, .red]
    let africanPatternColors: [Color] = [.orange, .red, .yellow, .green, .blue, .purple]
    
    // Computed property for smooth progress that's safe to access
    var smoothProgress: Double {
        smoothProgressValue
    }
    
    // Computed properties
    var totalWorkoutTime: Int {
        let totalPlannedTime = calculateTotalPlannedTime()
        let elapsedTime = calculateElapsedTime()
        return max(0, totalPlannedTime - elapsedTime)
    }

    var formattedTotalTime: String {
        let minutes = totalWorkoutTime / 60
        let seconds = totalWorkoutTime % 60
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
    
    private func calculateTotalPlannedTime() -> Int {
        let totalExercisesTime = (model.workTime + model.restTime) * model.exercises * model.rounds
        let totalRoundResets = model.roundResetTime * (model.rounds - 1)
        return totalExercisesTime + totalRoundResets + model.getReadyTime
    }
    
    private func calculateElapsedTime() -> Int {
        let totalPlannedTime = calculateTotalPlannedTime()
        var remainingTime = 0
        
        if model.isGetReadyPhase {
            // Get Ready phase: remaining = current get ready time + full workout
            remainingTime += Int(smoothProgressValue)
            remainingTime += (model.workTime + model.restTime) * model.exercises * model.rounds
            remainingTime += model.roundResetTime * (model.rounds - 1)
        } else if model.isWorkPhase {
            // Work phase: remaining = current work time + rest of workout
            remainingTime += Int(smoothProgressValue)
            remainingTime += model.restTime * (model.exercises - model.currentExercise + 1) * (model.rounds - model.currentRound + 1)
            remainingTime += model.workTime * (model.exercises - model.currentExercise) * (model.rounds - model.currentRound + 1)
            remainingTime += model.roundResetTime * (model.rounds - model.currentRound)
        } else if model.timeRemaining == model.roundResetTime {
            // Round Reset phase: remaining = current round reset time + rest of workout
            remainingTime += Int(smoothProgressValue)
            remainingTime += (model.workTime + model.restTime) * model.exercises * (model.rounds - model.currentRound)
            remainingTime += model.roundResetTime * (model.rounds - model.currentRound - 1)
        } else {
            // Rest phase: remaining = current rest time + rest of workout
            remainingTime += Int(smoothProgressValue)
            remainingTime += model.workTime * (model.exercises - model.currentExercise) * (model.rounds - model.currentRound + 1)
            remainingTime += model.restTime * (model.exercises - model.currentExercise) * (model.rounds - model.currentRound + 1)
            remainingTime += model.roundResetTime * (model.rounds - model.currentRound)
        }
        
        return max(0, totalPlannedTime - remainingTime)
    }
    
    var currentPhase: String {
        if model.isGetReadyPhase {
            return "GET READY"
        } else if model.isWorkPhase {
            return "WORK"
        } else if model.timeRemaining == model.roundResetTime && !model.isWorkPhase && model.currentExercise == model.exercises {
            return "ROUND RESET"
        } else {
            return "REST"
        }
    }
    
    var currentPhaseColor: Color {
        switch currentPhase {
        case "GET READY": return .orange
        case "WORK": return .red
        case "REST": return .green
        case "ROUND RESET": return .yellow
        default: return .orange
        }
    }
    
    var currentMaxTime: Double {
        switch currentPhase {
        case "GET READY": return Double(model.getReadyTime)
        case "WORK": return Double(model.workTime)
        case "REST": return Double(model.restTime)
        case "ROUND RESET": return Double(model.roundResetTime)
        default: return Double(model.workTime)
        }
    }
    
    var currentDisplayTime: Int {
        return max(0, Int(ceil(smoothProgressValue)))
    }
    
    var currentProgressTime: Double {
        return smoothProgressValue
    }
    
    // Timer control methods
    func startTimer() {
        if isRunning {
            stopTimer()
        } else {
            isRunning = true
            resetAllAlertTrackers()
            
            // Start smooth animation timer for all phases
            startSmoothAnimationTimer()
            
            // Set up the current phase
            if model.isGetReadyPhase {
                setupGetReadyPhase()
            } else {
                setupCurrentPhase()
            }
        }
    }
    
    private func setupGetReadyPhase() {
        model.isGetReadyPhase = true
        currentPhaseDuration = Double(model.getReadyTime)
        phaseStartTime = Date()
        smoothProgressValue = currentPhaseDuration
    }
    
    private func setupCurrentPhase() {
        currentPhaseDuration = currentMaxTime
        phaseStartTime = Date()
        smoothProgressValue = currentPhaseDuration
    }
    
    private func startSmoothAnimationTimer() {
        // High-frequency timer for smooth animation (60fps)
        smoothAnimationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Use Task to update on main actor safely
            Task { @MainActor in
                await self.updateSmoothAnimation()
            }
        }
    }
    
    private func updateSmoothAnimation() async {
        guard let startTime = phaseStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = max(0, currentPhaseDuration - elapsed)
        
        smoothProgressValue = remaining
        model.timeRemaining = Int(ceil(remaining))
        
        // Check for alerts based on the current phase
        checkForAllAlerts()
        
        // Check if current phase is complete
        if remaining <= 0 {
            smoothProgressValue = 0
            model.timeRemaining = 0
            advanceToNextPhase()
        }
    }
    
    func stopTimer() {
        smoothAnimationTimer?.invalidate()
        smoothAnimationTimer = nil
        isRunning = false
        phaseStartTime = nil
    }
    
    func resetTimer() {
        stopTimer()
        model = TimerModel()
        smoothProgressValue = Double(model.getReadyTime)
        resetAllAlertTrackers()
        phaseStartTime = nil
        currentPhaseDuration = 0.0
    }
    
    // Alert methods
    private func checkForAllAlerts() {
        checkForHalfwayAlert()
        checkForWorkCountdownAlert()
        checkForRestCountdownAlert()
        checkForRoundResetCountdownAlert()
        checkForGetReadyCountdownAlert()
    }
    
    private func checkForHalfwayAlert() {
        if model.isWorkPhase && !model.isGetReadyPhase && !hasPlayedHalfwayAlert {
            let halfwayPoint = model.workTime / 2
            if Int(ceil(smoothProgressValue)) == halfwayPoint {
                audioManager.playSound(named: "halfway_alert")
                hasPlayedHalfwayAlert = true
            }
        }
    }
    
    private func checkForWorkCountdownAlert() {
        if model.isWorkPhase && !model.isGetReadyPhase && !hasPlayedCountdownAlert {
            if Int(ceil(smoothProgressValue)) == 3 {
                audioManager.playSound(named: "countdown_alert")
                hasPlayedCountdownAlert = true
            }
        }
    }
    
    private func checkForRestCountdownAlert() {
        if !model.isWorkPhase && !model.isGetReadyPhase && model.timeRemaining != model.roundResetTime && !hasPlayedRestCountdown {
            if Int(ceil(smoothProgressValue)) == 3 {
                audioManager.playSound(named: "countdown_alert_321")
                hasPlayedRestCountdown = true
            }
        }
    }
    
    private func checkForRoundResetCountdownAlert() {
        if !model.isWorkPhase && !model.isGetReadyPhase &&
           model.timeRemaining == model.roundResetTime &&
           model.currentExercise == model.exercises &&
           !hasPlayedRoundResetCountdown {
            if Int(ceil(smoothProgressValue)) == 3 {
                audioManager.playSound(named: "countdown_alert_321")
                hasPlayedRoundResetCountdown = true
            }
        }
    }
    
    private func checkForGetReadyCountdownAlert() {
        if model.isGetReadyPhase && !hasPlayedGetReadyCountdown {
            if Int(ceil(smoothProgressValue)) == 3 {
                audioManager.playSound(named: "countdown_alert_321")
                hasPlayedGetReadyCountdown = true
            }
        }
    }
    
    private func resetAllAlertTrackers() {
        hasPlayedHalfwayAlert = false
        hasPlayedCountdownAlert = false
        hasPlayedRestCountdown = false
        hasPlayedGetReadyCountdown = false
        hasPlayedRoundResetCountdown = false
    }
    
    private func advanceToNextPhase() {
        if model.isGetReadyPhase {
            transitionFromGetReadyToWork()
        } else if model.isWorkPhase {
            transitionFromWorkToRest()
        } else {
            transitionFromRestToNext()
        }
        
        // Set up the next phase if timer is still running
        if isRunning {
            setupCurrentPhase()
        }
    }
    
    private func transitionFromGetReadyToWork() {
        model.isGetReadyPhase = false
        model.isWorkPhase = true
        hasPlayedHalfwayAlert = false
        hasPlayedCountdownAlert = false
    }
    
    private func transitionFromWorkToRest() {
        model.isWorkPhase = false
        hasPlayedRestCountdown = false
    }
    
    private func transitionFromRestToNext() {
        if model.currentExercise < model.exercises {
            transitionToNextExercise()
        } else {
            transitionToNextRoundOrComplete()
        }
    }
    
    private func transitionToNextExercise() {
        model.currentExercise += 1
        model.isWorkPhase = true
        hasPlayedHalfwayAlert = false
        hasPlayedCountdownAlert = false
    }
    
    private func transitionToNextRoundOrComplete() {
        if model.currentRound < model.rounds {
            transitionToNextRound()
        } else {
            resetTimer()
        }
    }
    
    private func transitionToNextRound() {
        model.currentRound += 1
        model.currentExercise = 1
        model.isWorkPhase = false
        hasPlayedRoundResetCountdown = false
        
        // After round reset, start the get ready phase for the next round
        if isRunning {
            model.isGetReadyPhase = true
            setupGetReadyPhase()
        }
    }
    
    // NEW METHOD: Start the get ready phase specifically
    func startGetReadyPhase() {
        if !isRunning {
            resetTimer()
            model.isGetReadyPhase = true
            setupGetReadyPhase()
            startTimer()
        }
    }
    
    func applyAdjustment(_ value: Int) {
        guard let adjuster = currentAdjuster else { return }
        
        switch adjuster {
        case .work:
            model.workTime = value
            if model.isWorkPhase && !model.isGetReadyPhase {
                currentPhaseDuration = Double(value)
                smoothProgressValue = Double(value)
                phaseStartTime = Date()
            }
        case .rest:
            model.restTime = value
            if !model.isWorkPhase && !model.isGetReadyPhase && model.timeRemaining != model.roundResetTime {
                currentPhaseDuration = Double(value)
                smoothProgressValue = Double(value)
                phaseStartTime = Date()
            }
        case .rounds:
            model.rounds = value
        case .roundReset:
            model.roundResetTime = value
            if !model.isWorkPhase && !model.isGetReadyPhase && model.timeRemaining == model.roundResetTime {
                currentPhaseDuration = Double(value)
                smoothProgressValue = Double(value)
                phaseStartTime = Date()
            }
        case .exercises:
            model.exercises = value
        case .getReady: // NEW CASE: Handle get ready time adjustment
            model.getReadyTime = value
            if model.isGetReadyPhase {
                currentPhaseDuration = Double(value)
                smoothProgressValue = Double(value)
                phaseStartTime = Date()
            }
        }
    }
}
