import SwiftUI

struct HistoryView: View {
    @Binding var showHamburgerMenu: Bool
    @Binding var selectedTab: HamburgerMenuView.MenuTab
    @EnvironmentObject private var viewModel: TimerViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Sticky header with hamburger
            HeaderView(title: "Workout History", showHamburgerMenu: $showHamburgerMenu)
                .zIndex(1)
            
            ScrollView {
                VStack(spacing: 20) {
                    if viewModel.workoutHistory.isEmpty {
                        emptyStateView
                    } else {
                        historyListView
                    }
                    
                    Spacer()
                }
                .padding(.vertical)
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("No Workouts Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Complete your first workout to see it here!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    private var historyListView: some View {
        LazyVStack(spacing: 16) {
            ForEach(Array(viewModel.workoutHistory.enumerated()), id: \.element.id) { index, workout in
                WorkoutHistoryCard(
                    workout: workout,
                    onLoad: { loadWorkout(workout) },
                    onRename: { newName in
                        viewModel.renameWorkout(at: index, to: newName)
                    }
                )
                .environmentObject(viewModel)
            }
        }
        .padding(.horizontal)
    }
    
    private func loadWorkout(_ workout: WorkoutHistory) {
        viewModel.loadWorkout(workout)
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation {
            selectedTab = .timer
            showHamburgerMenu = false
        }
    }
}

struct WorkoutHistoryCard: View {
    @State private var isEditingName = false
    @State private var workoutName: String = ""
    @EnvironmentObject var viewModel: TimerViewModel
    
    let workout: WorkoutHistory
    let onLoad: () -> Void
    let onRename: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if isEditingName {
                    TextField("Workout Name", text: $workoutName, onCommit: {
                        onRename(workoutName)
                        isEditingName = false
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.headline)
                    .foregroundColor(.primary)
                } else {
                    Text(workout.name ?? "Workout")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .onTapGesture {
                            workoutName = workout.name ?? ""
                            isEditingName = true
                        }
                }
                
                Spacer()
                
                Button(action: onLoad) {
                    Text("Load")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            Text(workout.formattedDate)
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                detailRow(icon: "⏱️", title: "Duration", value: workout.formattedDuration)
                detailRow(icon: "🔥", title: "Work", value: "\(workout.workTime)s")
                detailRow(icon: "🌴", title: "Rest", value: "\(workout.restTime)s")
                detailRow(icon: "💪", title: "Exercises", value: "\(workout.completedExercises)/\(workout.exercises)")
                detailRow(icon: "🔄", title: "Rounds", value: "\(workout.completedRounds)/\(workout.rounds)")
                
                if workout.roundResetTime > 0 {
                    detailRow(icon: "⏭️", title: "Round Reset", value: "\(workout.roundResetTime)s")
                }
                
                if workout.getReadyTime > 0 {
                    detailRow(icon: "🎯", title: "Get Ready", value: "\(workout.getReadyTime)s")
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
    
    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Text(icon)
                .font(.system(size: 16))
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
