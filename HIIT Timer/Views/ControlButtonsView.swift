import SwiftUI

// MARK: - ControlButtonsView
struct ControlButtonsView: View {
    @ObservedObject var viewModel: TimerViewModel

    var body: some View {
        HStack(spacing: 20) {
            // Start / Pause Button
            Button(action: { viewModel.toggleTimer() }) {
                HStack {
                    Image(systemName: viewModel.isRunning ? "pause.circle.fill" : "play.circle.fill")
                    Text(viewModel.isRunning ? "Pause" : "Start")
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: viewModel.isRunning ? [.orange, .red] : [.green, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            }

            // Reset Button
            Button {
                viewModel.resetTimer()
            } label: {
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
    }
}
