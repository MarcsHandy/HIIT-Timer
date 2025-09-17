import SwiftUI

struct ControlButtonsView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            Button(action: viewModel.startTimer) {
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
            
            Button(action: viewModel.resetTimer) {
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
