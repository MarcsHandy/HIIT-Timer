import SwiftUI

struct StatisticsView: View {
    @Binding var showHamburgerMenu: Bool
    @EnvironmentObject private var viewModel: TimerViewModel
    
    private var totalWorkouts: Int {
        viewModel.workoutHistory.count
    }
    
    private var totalTime: Int {
        viewModel.workoutHistory.reduce(0) { $0 + $1.totalDuration }
    }
    
    private var averageDuration: Int {
        guard totalWorkouts > 0 else { return 0 }
        return totalTime / totalWorkouts
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Sticky header with hamburger
            HeaderView(title: "Statistics", showHamburgerMenu: $showHamburgerMenu)
                .zIndex(1)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Workout Statistics")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    // Statistics content
                    VStack(spacing: 16) {
                        StatCard(title: "Total Workouts", value: "\(totalWorkouts)", color: .blue)
                        StatCard(title: "Total Time", value: formatTime(totalTime), color: .green)
                        StatCard(title: "Avg. Duration", value: formatTime(averageDuration), color: .orange)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView(showHamburgerMenu: .constant(false))
            .environmentObject(TimerViewModel())
    }
}
