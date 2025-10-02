import Foundation

// MARK: - FoodEntry Model
struct FoodEntry: Identifiable, Codable {
    let id: UUID
    let name: String
    let calories: Double
    let date: Date
    let mealType: MealType
}

