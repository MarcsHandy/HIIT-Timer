import SwiftUI

struct TimerDisplayView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        ZStack {
            // Outer decorative rings
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        viewModel.africanPatternColors[index % viewModel.africanPatternColors.count].opacity(0.3),
                        lineWidth: CGFloat(8 - index * 2)
                    )
            }
            
            // Main progress circle with smooth animation
            Circle()
                .trim(from: 0.0, to: CGFloat(viewModel.currentProgressTime) / CGFloat(viewModel.currentMaxTime))
                .stroke(style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round))
                .foregroundColor(viewModel.currentPhaseColor)
                .rotationEffect(Angle(degrees: 270))
                .animation(.linear(duration: 0.1), value: viewModel.currentProgressTime) // Faster animation for smoothness
                .shadow(color: viewModel.currentPhaseColor.opacity(0.3), radius: 5, x: 0, y: 0)
            
            VStack(spacing: 8) {
                Text(viewModel.currentPhase)
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundColor(viewModel.currentPhaseColor)
                    .textCase(.uppercase)
                
                Text("\(viewModel.currentDisplayTime)s")
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundColor(.black)
                
                if !viewModel.model.isGetReadyPhase {
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
