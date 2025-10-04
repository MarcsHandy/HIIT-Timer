import SwiftUI

struct Food: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let calories: Double
    let nutrients: [String: Double] // full nutrition details if you want them
}
