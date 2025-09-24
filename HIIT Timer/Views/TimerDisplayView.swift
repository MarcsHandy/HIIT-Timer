import SwiftUI

struct TimerDisplayView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        ZStack {
            // Outer decorative rings
            ForEach(0..<3) { index in
                let color = viewModel.africanPatternColors[index % viewModel.africanPatternColors.count].opacity(0.3)
                let lineWidth = CGFloat(8 - index * 2)
                
                Circle()
                    .stroke(color, lineWidth: lineWidth)
            }
            
            // Main progress circle
            let progress: CGFloat = viewModel.currentMaxTime > 0
                ? CGFloat(viewModel.smoothProgressValue) / CGFloat(viewModel.currentMaxTime)
                : 0

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                )
                .foregroundColor(viewModel.currentPhaseColor)
                .rotationEffect(.degrees(270))
                .animation(.linear(duration: 0.1), value: viewModel.smoothProgressValue)
                .shadow(color: viewModel.currentPhaseColor.opacity(0.3), radius: 5, x: 0, y: 0)
            
            VStack(spacing: 8) {
                // Phase label
                Text(viewModel.currentPhase)
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(viewModel.currentPhaseColor)
                    .textCase(.uppercase)
                
                // Countdown timer
                Text("\(viewModel.currentDisplayTime)s")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                
                // Exercise & round info (hide during GET READY and FINISHED)
                if viewModel.model.phase != .getReady && viewModel.model.phase != .finished {
                    HStack(spacing: 15) {
                        Label("Ex \(viewModel.model.currentExercise)/\(viewModel.model.exercises)", systemImage: "figure.run")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                        
                        Label("Rd \(viewModel.model.currentRound)/\(viewModel.model.rounds)", systemImage: "repeat")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                    }
                }
            }
        }
        .frame(width: 280, height: 280)
        .padding()
    }
}
