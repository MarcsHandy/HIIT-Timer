import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var workTime: Int = 30
    @State private var restTime: Int = 15
    @State private var rounds: Int = 5
    @State private var roundResetTime: Int = 60
    @State private var exercises: Int = 3
    @State private var currentRound: Int = 1
    @State private var currentExercise: Int = 1
    @State private var timeRemaining: Int = 30
    @State private var isWorkPhase: Bool = true
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil
    @State private var showingAdjuster: Bool = false
    @State private var currentAdjuster: AdjusterType? = nil
    @State private var tempValue: Int = 0
    @State private var isEditingText: Bool = false
    @State private var textInput: String = ""
    @State private var isGetReadyPhase: Bool = false
    @State private var getReadyTime: Int = 10
    @State private var audioPlayer: AVAudioPlayer?
    @State private var hasPlayedHalfwayAlert: Bool = false
    @State private var hasPlayedCountdownAlert: Bool = false
    @State private var hasPlayedRestCountdown: Bool = false
    @State private var hasPlayedGetReadyCountdown: Bool = false
    @State private var hasPlayedRoundResetCountdown: Bool = false
    @State private var smoothProgress: Double = 30.0 // For smooth animation
    
    enum AdjusterType {
        case work, rest, rounds, roundReset, exercises
        
        var title: String {
            switch self {
            case .work: return "Work Time"
            case .rest: return "Rest Time"
            case .rounds: return "Number of Rounds"
            case .roundReset: return "Round Reset Time"
            case .exercises: return "Number of Exercises"
            }
        }
        
        var unit: String {
            switch self {
            case .work, .rest, .roundReset: return "seconds"
            case .rounds, .exercises: return "rounds"
            }
        }
        
        var icon: String {
            switch self {
            case .work: return "🔥"
            case .rest: return "🌴"
            case .rounds: return "🔄"
            case .roundReset: return "⏱️"
            case .exercises: return "💪"
            }
        }
        
        var color: Color {
            switch self {
            case .work: return .red
            case .rest: return .green
            case .rounds: return .yellow
            case .roundReset: return .orange
            case .exercises: return .blue
            }
        }
        
        var range: ClosedRange<Int> {
            switch self {
            case .work: return 5...120
            case .rest: return 5...60
            case .rounds: return 1...20
            case .roundReset: return 0...180
            case .exercises: return 1...10
            }
        }
        
        var step: Int {
            switch self {
            case .work, .rest, .roundReset: return 5
            case .rounds, .exercises: return 1
            }
        }
    }
    
    // Ugandan colors: Black, Yellow, Red - from the flag
    let ugandaColors: [Color] = [.black, .yellow, .red]
    let africanPatternColors: [Color] = [.orange, .red, .yellow, .green, .blue, .purple]
    
    // Computed properties
    private var totalWorkoutTime: Int {
        let totalExercisesTime = (workTime + restTime) * exercises * rounds
        let totalRoundResets = roundResetTime * (rounds - 1)
        return totalExercisesTime + totalRoundResets + getReadyTime
    }
    
    private var formattedTotalTime: String {
        let minutes = totalWorkoutTime / 60
        let seconds = totalWorkoutTime % 60
        return "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)"
    }
    
    private var currentPhase: String {
        if isGetReadyPhase {
            return "GET READY"
        } else if isWorkPhase {
            return "WORK"
        } else if timeRemaining == roundResetTime && !isWorkPhase {
            return "ROUND RESET"
        } else {
            return "REST"
        }
    }
    
    private var currentPhaseColor: Color {
        switch currentPhase {
        case "GET READY": return .orange
        case "WORK": return .red
        case "REST": return .green
        case "ROUND RESET": return .yellow
        default: return .orange
        }
    }
    
    private var currentMaxTime: Double {
        switch currentPhase {
        case "GET READY": return Double(getReadyTime)
        case "WORK": return Double(workTime)
        case "REST": return Double(restTime)
        case "ROUND RESET": return Double(roundResetTime)
        default: return Double(workTime)
        }
    }
    
    private var currentDisplayTime: Int {
        if isGetReadyPhase {
            return getReadyTime
        } else {
            return timeRemaining
        }
    }
    
    private var currentProgressTime: Double {
        return smoothProgress
    }

    var body: some View {
        ZStack {
            // African pattern background
            LinearGradient(
                gradient: Gradient(colors: [.orange.opacity(0.3), .red.opacity(0.2), .yellow.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header with Ugandan flag colors
                VStack {
                    Text("🇺🇬 UGANDAN")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .yellow, .black],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("HIIT WARRIOR")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.black)
                }
                .padding(.top)
                
                // Total Time Display with African pattern border
                VStack {
                    Text("TOTAL WORKOUT TIME")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text(formattedTotalTime)
                        .font(.title2)
                        .fontWeight(.heavy)
                        .foregroundColor(.red)
                }
                .padding()
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.yellow.opacity(0.2))
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [.red, .yellow, .black],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    }
                )
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Settings with vibrant colors
                VStack(spacing: 15) {
                    AdjusterRow(icon: "🔥", title: "Work: \(workTime)s", value: workTime, color: .red) {
                        currentAdjuster = .work
                        tempValue = workTime
                        textInput = "\(workTime)"
                        showingAdjuster = true
                    }
                    
                    AdjusterRow(icon: "🌴", title: "Rest: \(restTime)s", value: restTime, color: .green) {
                        currentAdjuster = .rest
                        tempValue = restTime
                        textInput = "\(restTime)"
                        showingAdjuster = true
                    }
                    
                    AdjusterRow(icon: "🔄", title: "Rounds: \(rounds)", value: rounds, color: .yellow) {
                        currentAdjuster = .rounds
                        tempValue = rounds
                        textInput = "\(rounds)"
                        showingAdjuster = true
                    }
                    
                    AdjusterRow(icon: "⏱️", title: "Round Reset: \(roundResetTime)s", value: roundResetTime, color: .orange) {
                        currentAdjuster = .roundReset
                        tempValue = roundResetTime
                        textInput = "\(roundResetTime)"
                        showingAdjuster = true
                    }
                    
                    AdjusterRow(icon: "💪", title: "Exercises: \(exercises)", value: exercises, color: .blue) {
                        currentAdjuster = .exercises
                        tempValue = exercises
                        textInput = "\(exercises)"
                        showingAdjuster = true
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.black.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(LinearGradient(colors: [.red, .yellow], startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                        )
                )
                .padding(.horizontal)
                
                // Timer Display with African drum design
                ZStack {
                    // Outer decorative rings
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(
                                africanPatternColors[index % africanPatternColors.count].opacity(0.3),
                                lineWidth: CGFloat(8 - index * 2)
                            )
                    }
                    
                    // Main progress circle - SMOOTH ANIMATION
                    Circle()
                        .trim(from: 0.0, to: CGFloat(currentProgressTime) / CGFloat(currentMaxTime))
                        .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                        .foregroundColor(currentPhaseColor)
                        .rotationEffect(Angle(degrees: 270))
                        .animation(.linear(duration: 1.0), value: currentProgressTime)
                        .shadow(color: currentPhaseColor.opacity(0.3), radius: 5, x: 0, y: 0)
                    
                    VStack(spacing: 8) {
                        Text(currentPhase)
                            .font(.title3)
                            .fontWeight(.heavy)
                            .foregroundColor(currentPhaseColor)
                            .textCase(.uppercase)
                        
                        Text("\(currentDisplayTime)s")
                            .font(.system(size: 42, weight: .black, design: .rounded))
                            .foregroundColor(.black)
                        
                        if !isGetReadyPhase {
                            HStack(spacing: 15) {
                                Label("Ex \(currentExercise)/\(exercises)", systemImage: "figure.run")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.red)
                                
                                Label("Rd \(currentRound)/\(rounds)", systemImage: "repeat")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                }
                .frame(width: 280, height: 280)
                .padding()
                
                // Control Buttons with African theme
                HStack(spacing: 20) {
                    Button(action: startTimer) {
                        HStack {
                            Image(systemName: isRunning ? "pause.circle.fill" : "play.circle.fill")
                            Text(isRunning ? "Pause" : "Start")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: isRunning ? [.orange, .red] : [.green, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    }
                    
                    Button(action: resetTimer) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                            Text("Reset")
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [.red, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                .fontWeight(.bold)
                
                Spacer()
                
                // Footer with Ugandan motto
                Text("For God and My Country")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.black.opacity(0.6))
                    .padding(.bottom, 5)
            }
            .blur(radius: showingAdjuster ? 10 : 0)
            .animation(.easeInOut(duration: 0.3), value: showingAdjuster)
            
            // Full Screen Adjuster
            if showingAdjuster, let adjuster = currentAdjuster {
                FullScreenAdjuster(
                    isShowing: $showingAdjuster,
                    value: $tempValue,
                    textInput: $textInput,
                    isEditingText: $isEditingText,
                    adjuster: adjuster,
                    backgroundColor: adjuster.color,
                    onValueChange: { newValue in
                        tempValue = newValue
                        textInput = "\(newValue)"
                        applyAdjustment(newValue)
                    },
                    onApply: { finalValue in
                        applyAdjustment(finalValue)
                    }
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .onChange(of: workTime) { resetIfNeeded() }
        .onChange(of: restTime) { resetIfNeeded() }
        .onChange(of: rounds) { resetIfNeeded() }
        .onChange(of: exercises) { resetIfNeeded() }
        .onChange(of: roundResetTime) { resetIfNeeded() }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func applyAdjustment(_ value: Int) {
        guard let adjuster = currentAdjuster else { return }
        
        switch adjuster {
        case .work:
            workTime = value
        case .rest:
            restTime = value
        case .rounds:
            rounds = value
        case .roundReset:
            roundResetTime = value
        case .exercises:
            exercises = value
        }
    }
    
    private func startTimer() {
        if isRunning {
            timer?.invalidate()
            isRunning = false
        } else {
            isRunning = true
            resetAllAlertTrackers()
            
            if !isGetReadyPhase && currentDisplayTime == workTime {
                isGetReadyPhase = true
                getReadyTime = 10
                smoothProgress = 10.0
            } else {
                smoothProgress = isGetReadyPhase ? Double(getReadyTime) : Double(timeRemaining)
            }
            
            // Use 1-second timer for proper timing
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                // Check for alerts
                checkForAllAlerts()
                
                if isGetReadyPhase {
                    getReadyTime -= 1
                    smoothProgress = Double(getReadyTime)
                    
                    if getReadyTime <= 0 {
                        getReadyTime = 0
                        smoothProgress = 0.0
                        advanceToNextPhase()
                    }
                } else {
                    timeRemaining -= 1
                    smoothProgress = Double(timeRemaining)
                    
                    if timeRemaining <= 0 {
                        timeRemaining = 0
                        smoothProgress = 0.0
                        advanceToNextPhase()
                    }
                }
            }
        }
    }
    
    private func checkForAllAlerts() {
        checkForHalfwayAlert()
        checkForWorkCountdownAlert()
        checkForRestCountdownAlert()
        checkForGetReadyCountdownAlert()
        checkForRoundResetCountdownAlert()
    }
    
    private func resetAllAlertTrackers() {
        hasPlayedHalfwayAlert = false
        hasPlayedCountdownAlert = false
        hasPlayedRestCountdown = false
        hasPlayedGetReadyCountdown = false
        hasPlayedRoundResetCountdown = false
    }
    
    private func checkForHalfwayAlert() {
        if isWorkPhase && !isGetReadyPhase && !hasPlayedHalfwayAlert {
            let halfwayPoint = workTime / 2
            if timeRemaining == halfwayPoint {
                playSound(named: "halfway_alert")
                hasPlayedHalfwayAlert = true
            }
        }
    }
    
    private func checkForWorkCountdownAlert() {
        if isWorkPhase && !isGetReadyPhase && !hasPlayedCountdownAlert {
            if timeRemaining == 3 {
                playSound(named: "countdown_alert")
                hasPlayedCountdownAlert = true
            }
        }
    }
    
    private func checkForRestCountdownAlert() {
        if !isWorkPhase && !isGetReadyPhase && timeRemaining != roundResetTime && !hasPlayedRestCountdown {
            if timeRemaining == 3 {
                playSound(named: "countdown_alert_321")
                hasPlayedRestCountdown = true
            }
        }
    }
    
    private func checkForGetReadyCountdownAlert() {
        if isGetReadyPhase && !hasPlayedGetReadyCountdown {
            if getReadyTime == 3 {
                playSound(named: "countdown_alert_321")
                hasPlayedGetReadyCountdown = true
            }
        }
    }
    
    private func checkForRoundResetCountdownAlert() {
        if !isWorkPhase && !isGetReadyPhase && timeRemaining == roundResetTime && !hasPlayedRoundResetCountdown {
            if timeRemaining == 3 {
                playSound(named: "countdown_alert_321")
                hasPlayedRoundResetCountdown = true
            }
        }
    }
    
    private func playSound(named soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "m4a") else {
            print("Sound file not found: \(soundName).m4a")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
    
    private func advanceToNextPhase() {
        if isGetReadyPhase {
            isGetReadyPhase = false
            isWorkPhase = true
            timeRemaining = workTime
            smoothProgress = Double(workTime)
            hasPlayedHalfwayAlert = false
            hasPlayedCountdownAlert = false
            
        } else if isWorkPhase {
            isWorkPhase = false
            timeRemaining = restTime
            smoothProgress = Double(restTime)
            hasPlayedRestCountdown = false
            
        } else {
            if currentExercise < exercises {
                currentExercise += 1
                isWorkPhase = true
                timeRemaining = workTime
                smoothProgress = Double(workTime)
                hasPlayedHalfwayAlert = false
                hasPlayedCountdownAlert = false
                
            } else {
                if currentRound < rounds {
                    currentRound += 1
                    currentExercise = 1
                    isWorkPhase = false
                    timeRemaining = roundResetTime
                    smoothProgress = Double(roundResetTime)
                    hasPlayedRoundResetCountdown = false
                    
                } else {
                    resetTimer()
                    return
                }
            }
        }
    }
    
    private func resetTimer() {
        timer?.invalidate()
        isRunning = false
        isGetReadyPhase = false
        currentRound = 1
        currentExercise = 1
        isWorkPhase = true
        timeRemaining = workTime
        getReadyTime = 10
        smoothProgress = Double(workTime)
        resetAllAlertTrackers()
    }
    
    private func resetIfNeeded() {
        if !isRunning {
            resetTimer()
        }
    }
}

// Custom adjuster row view
struct AdjusterRow: View {
    let icon: String
    let title: String
    let value: Int
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(icon)
                    .font(.title3)
                    .frame(width: 30)
                
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(value)")
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(color.opacity(0.2))
                    .cornerRadius(8)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Full Screen Adjuster
struct FullScreenAdjuster: View {
    @Binding var isShowing: Bool
    @Binding var value: Int
    @Binding var textInput: String
    @Binding var isEditingText: Bool
    let adjuster: ContentView.AdjusterType
    let backgroundColor: Color
    let onValueChange: (Int) -> Void
    let onApply: (Int) -> Void
    
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    
    var body: some View {
        ZStack {
            // Background with the adjuster's color
            LinearGradient(
                gradient: Gradient(colors: [
                    backgroundColor,
                    backgroundColor.opacity(0.9),
                    backgroundColor.opacity(0.8)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header with back button
                HStack {
                    Button(action: {
                        onApply(value)
                        isShowing = false
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                    
                    Spacer()
                    
                    Text(adjuster.icon)
                        .font(.system(size: 40))
                    
                    Text(adjuster.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        applyTextInput()
                        onApply(value)
                        isShowing = false
                    }) {
                        Text("Done")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(Color.white.opacity(0.3)))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 50)
                
                Spacer()
                
                // Large value display with pencil edit button
                VStack(spacing: 20) {
                    if isEditingText {
                        TextField("", text: $textInput)
                            .font(.system(size: 80, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                            .frame(width: 200)
                            .onSubmit {
                                applyTextInput()
                            }
                    } else {
                        Text("\(value)")
                            .font(.system(size: 100, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .contentTransition(.numericText())
                            .onTapGesture {
                                withAnimation {
                                    isEditingText = true
                                }
                            }
                    }
                    
                    HStack {
                        Text(adjuster.unit)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                isEditingText.toggle()
                                if !isEditingText {
                                    applyTextInput()
                                }
                            }
                        }) {
                            Image(systemName: isEditingText ? "checkmark.circle.fill" : "pencil.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                    }
                }
                
                Spacer()
                
                // Vertical slider
                VStack(spacing: 15) {
                    Text("Slide to adjust")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    ZStack {
                        // Background track
                        Capsule()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 80, height: 300)
                        
                        // Draggable handle
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.title2)
                                    .foregroundColor(backgroundColor)
                            )
                            .offset(y: dragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        isDragging = true
                                        let newPosition = gesture.translation.height
                                        let maxY = 115.0
                                        let minY = -115.0
                                        dragOffset = min(max(newPosition, minY), maxY)
                                        updateValueFromPosition()
                                    }
                                    .onEnded { _ in
                                        isDragging = false
                                        withAnimation(.spring()) {
                                            dragOffset = 0
                                        }
                                    }
                            )
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    
                    HStack {
                        Text("\(adjuster.range.lowerBound)")
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("\(adjuster.range.upperBound)")
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .frame(width: 200)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            dragOffset = 0
        }
    }
    
    private func updateValueFromPosition() {
        let normalizedPosition = (dragOffset + 115) / 230.0
        let totalRange = adjuster.range.upperBound - adjuster.range.lowerBound
        let newValue = adjuster.range.lowerBound + Int(normalizedPosition * CGFloat(totalRange))
        
        let steppedValue = (newValue / adjuster.step) * adjuster.step
        let clampedValue = min(max(steppedValue, adjuster.range.lowerBound), adjuster.range.upperBound)
        
        value = clampedValue
        textInput = "\(clampedValue)"
        onValueChange(clampedValue)
    }
    
    private func applyTextInput() {
        if let newValue = Int(textInput) {
            let clampedValue = min(max(newValue, adjuster.range.lowerBound), adjuster.range.upperBound)
            let steppedValue = (clampedValue / adjuster.step) * adjuster.step
            value = steppedValue
            textInput = "\(steppedValue)"
            onValueChange(steppedValue)
        } else {
            textInput = "\(value)"
        }
        isEditingText = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
