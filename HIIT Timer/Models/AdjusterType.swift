import SwiftUI

enum AdjusterType: CaseIterable {
    case work, rest, rounds, roundReset, exercises, getReady
    
    var title: String {
        switch self {
        case .work: return "Work Time"
        case .rest: return "Rest Time"
        case .rounds: return "Number of Rounds"
        case .roundReset: return "Round Reset Time"
        case .exercises: return "Number of Exercises"
        case .getReady: return "Get Ready Time"
        }
    }
    
    var unit: String {
        switch self {
        case .work, .rest, .roundReset, .getReady: return "seconds"
        case .rounds, .exercises: return ""
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "🔥"
        case .rest: return "🌴"
        case .rounds: return "🔄"
        case .roundReset: return "⏱️"
        case .exercises: return "💪"
        case .getReady: return "🎯"
        }
    }
    
    var color: Color {
        switch self {
        case .work: return .red
        case .rest: return .green
        case .rounds: return .yellow
        case .roundReset: return .orange
        case .exercises: return .blue
        case .getReady: return .purple
        }
    }
    
    var range: ClosedRange<Int> {
        switch self {
        case .work: return 5...300        // 5 seconds to 5 minutes
        case .rest: return 5...180        // 5 seconds to 3 minutes
        case .rounds: return 1...20
        case .roundReset: return 0...300  // 0 to 5 minutes
        case .exercises: return 1...30
        case .getReady: return 3...60     // 3 seconds to 1 minute
        }
    }
    
    var step: Int {
        switch self {
        case .work, .rest, .roundReset, .getReady: return 5
        case .rounds, .exercises: return 1
        }
    }
    
    // New: Quick adjustment increments
    var quickIncrements: [Int] {
        switch self {
        case .work, .rest, .roundReset, .getReady:
            return [5, 10, 15, 30, 60] // Common time increments
        case .rounds, .exercises:
            return [1, 2, 5, 10] // Count increments
        }
    }
    
    // New: Format for display
    func formattedValue(_ value: Int) -> String {
        switch self {
        case .work, .rest, .roundReset, .getReady:
            if value >= 60 {
                let minutes = value / 60
                let seconds = value % 60
                return seconds > 0 ? "\(minutes)m \(seconds)s" : "\(minutes)m"
            } else {
                return "\(value)s"
            }
        case .rounds, .exercises:
            return "\(value)"
        }
    }
}
