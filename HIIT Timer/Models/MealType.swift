import Foundation

// MARK: - MealType Enum
enum MealType: String, Codable, CaseIterable, Identifiable {
    case water = "Water"
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snacks = "Snacks"
    
    var id: String { self.rawValue }
}
