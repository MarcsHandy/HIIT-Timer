import SwiftUI

struct FullScreenAdjuster: View {
    @Binding var isShowing: Bool
    @Binding var value: Int
    @Binding var textInput: String
    @Binding var isEditingText: Bool
    let adjuster: AdjusterType
    let backgroundColor: Color
    let onValueChange: (Int) -> Void
    let onApply: (Int) -> Void
    
    @State private var currentValue: Int
    @State private var isDragging: Bool = false
    @State private var activeInputMethod: InputMethod = .slider
    @State private var showConfetti: Bool = false
    
    enum InputMethod {
        case slider, buttons, keypad
    }
    
    // Time-based quick increments or count-based
    private var quickIncrements: [Int] {
        switch adjuster {
        case .work, .rest, .roundReset, .getReady:
            return [1, 5, 10, 15, 30, 60]
        case .rounds, .exercises:
            return [1, 2, 3, 5, 10]
        }
    }
    
    init(isShowing: Binding<Bool>, value: Binding<Int>, textInput: Binding<String>, isEditingText: Binding<Bool>, adjuster: AdjusterType, backgroundColor: Color, onValueChange: @escaping (Int) -> Void, onApply: @escaping (Int) -> Void) {
        self._isShowing = isShowing
        self._value = value
        self._textInput = textInput
        self._isEditingText = isEditingText
        self.adjuster = adjuster
        self.backgroundColor = backgroundColor
        self.onValueChange = onValueChange
        self.onApply = onApply
        self._currentValue = State(initialValue: value.wrappedValue)
    }
    
    var body: some View {
        ZStack {
            // Modern background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {
                        onApply(currentValue)
                        isShowing = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(Circle().fill(Color.secondary.opacity(0.1)))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Text(adjuster.title.uppercased())
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(adjuster.icon)
                            .font(.system(size: 24))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(dampingFraction: 0.6)) {
                            showConfetti = true
                        }
                        onApply(currentValue)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isShowing = false
                        }
                    }) {
                        Text("Set")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Capsule().fill(backgroundColor))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                Divider()
                
                // Main content
                ScrollView {
                    VStack(spacing: 30) {
                        // Large value display
                        VStack(spacing: 8) {
                            Text(formattedValue(currentValue))
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .contentTransition(.numericText())
                            
                            Text(adjuster.unit.uppercased())
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                                .tracking(1)
                        }
                        .padding(.top, 20)
                        
                        // Input method selector
                        HStack(spacing: 0) {
                            ForEach([InputMethod.slider, .buttons, .keypad], id: \.self) { method in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        activeInputMethod = method
                                    }
                                }) {
                                    Text(methodTitle(method))
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(activeInputMethod == method ? .white : .primary)
                                        .padding(.vertical, 10)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            Capsule()
                                                .fill(activeInputMethod == method ? backgroundColor : Color.clear)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .background(Capsule().fill(Color.secondary.opacity(0.1)))
                        .padding(.horizontal, 24)
                        
                        // Dynamic input area
                        Group {
                            switch activeInputMethod {
                            case .slider:
                                sliderView()
                            case .buttons:
                                buttonsView()
                            case .keypad:
                                keypadView()
                            }
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                    .padding(.bottom, 30)
                }
            }
            
            // Confetti effect
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
        }
        .onChange(of: currentValue) { newValue in
            onValueChange(newValue)
        }
    }
    
    private func methodTitle(_ method: InputMethod) -> String {
        switch method {
        case .slider: return "Slide"
        case .buttons: return "Quick"
        case .keypad: return "Type"
        }
    }
    
    private func formattedValue(_ value: Int) -> String {
        switch adjuster {
        case .work, .rest, .roundReset, .getReady:
            if value >= 60 {
                let minutes = value / 60
                let seconds = value % 60
                return seconds > 0 ? "\(minutes):\(seconds < 10 ? "0" : "")\(seconds)" : "\(minutes)m"
            } else {
                return "\(value)s"
            }
        case .rounds, .exercises:
            return "\(value)"
        }
    }
    
    @ViewBuilder
    private func sliderView() -> some View {
        VStack(spacing: 20) {
            Slider(
                value: Binding(
                    get: { Double(currentValue) },
                    set: { newValue in
                        let steppedValue = (Int(newValue) / adjuster.step) * adjuster.step
                        currentValue = min(max(steppedValue, adjuster.range.lowerBound), adjuster.range.upperBound)
                    }
                ),
                in: Double(adjuster.range.lowerBound)...Double(adjuster.range.upperBound),
                step: Double(adjuster.step)
            )
            .accentColor(backgroundColor)
            .padding(.horizontal, 32)
            
            HStack {
                Text(formattedValue(adjuster.range.lowerBound))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formattedValue(adjuster.range.upperBound))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 40)
        }
    }
    
    @ViewBuilder
    private func buttonsView() -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
            ForEach(quickIncrements, id: \.self) { increment in
                VStack(spacing: 12) {
                    Button(action: {
                        incrementValue(by: increment)
                    }) {
                        Text("+\(increment)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(backgroundColor))
                    }
                    
                    Button(action: {
                        incrementValue(by: -increment)
                    }) {
                        Text("-\(increment)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(backgroundColor)
                            .frame(width: 60, height: 60)
                            .background(Circle().stroke(backgroundColor, lineWidth: 2))
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private func keypadView() -> some View {
        VStack(spacing: 16) {
            TextField("Enter value", text: Binding(
                get: { "\(currentValue)" },
                set: { newValue in
                    if let intValue = Int(newValue) {
                        currentValue = min(max(intValue, adjuster.range.lowerBound), adjuster.range.upperBound)
                    }
                }
            ))
            .font(.system(size: 24, weight: .medium))
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.secondary.opacity(0.1)))
            .padding(.horizontal, 40)
            
            Text("Range: \(formattedValue(adjuster.range.lowerBound)) - \(formattedValue(adjuster.range.upperBound))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func incrementValue(by increment: Int) {
        let newValue = currentValue + increment
        let steppedValue = (newValue / adjuster.step) * adjuster.step
        let clampedValue = min(max(steppedValue, adjuster.range.lowerBound), adjuster.range.upperBound)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            currentValue = clampedValue
        }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// Confetti effect view
struct ConfettiView: View {
    @State private var animate: Bool = false
    
    var body: some View {
        ZStack {
            ForEach(0..<50) { i in
                ConfettiPiece(index: i)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animate = true
            }
        }
    }
}

struct ConfettiPiece: View {
    let index: Int
    @State private var position: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Circle()
            .fill([Color.red, .blue, .green, .yellow, .orange, .purple].randomElement()!)
            .frame(width: 8, height: 8)
            .offset(position)
            .rotationEffect(.degrees(rotation))
            .opacity(opacity)
            .onAppear {
                let angle = Double.random(in: 0...360)
                let distance = CGFloat.random(in: 50...200)
                let duration = Double.random(in: 1.0...2.0)
                
                withAnimation(.easeOut(duration: duration)) {
                    position = CGSize(
                        width: distance * cos(angle * .pi / 180),
                        height: -distance * sin(angle * .pi / 180)
                    )
                    rotation = Double.random(in: 0...720)
                }
                
                withAnimation(.easeOut(duration: duration).delay(0.5)) {
                    opacity = 0
                }
            }
    }
}
