import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            AdjusterRow(icon: "🔥", title: "Work: \(viewModel.model.workTime)s", value: viewModel.model.workTime, color: .red) {
                viewModel.currentAdjuster = .work
                viewModel.tempValue = viewModel.model.workTime
                viewModel.textInput = "\(viewModel.model.workTime)"
                viewModel.showingAdjuster = true
            }
            
            AdjusterRow(icon: "🌴", title: "Rest: \(viewModel.model.restTime)s", value: viewModel.model.restTime, color: .green) {
                viewModel.currentAdjuster = .rest
                viewModel.tempValue = viewModel.model.restTime
                viewModel.textInput = "\(viewModel.model.restTime)"
                viewModel.showingAdjuster = true
            }
            
            AdjusterRow(icon: "🔄", title: "Rounds: \(viewModel.model.rounds)", value: viewModel.model.rounds, color: .teal) {
                viewModel.currentAdjuster = .rounds
                viewModel.tempValue = viewModel.model.rounds
                viewModel.textInput = "\(viewModel.model.rounds)"
                viewModel.showingAdjuster = true
            }
            
            AdjusterRow(icon: "⏱️", title: "Round Reset: \(viewModel.model.roundResetTime)s", value: viewModel.model.roundResetTime, color: .orange) {
                viewModel.currentAdjuster = .roundReset
                viewModel.tempValue = viewModel.model.roundResetTime
                viewModel.textInput = "\(viewModel.model.roundResetTime)"
                viewModel.showingAdjuster = true
            }
            
            AdjusterRow(icon: "💪", title: "Exercises: \(viewModel.model.exercises)", value: viewModel.model.exercises, color: .blue) {
                viewModel.currentAdjuster = .exercises
                viewModel.tempValue = viewModel.model.exercises
                viewModel.textInput = "\(viewModel.model.exercises)"
                viewModel.showingAdjuster = true
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
    }
}
