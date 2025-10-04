import Foundation

struct FoodEntry: Identifiable, Codable {
    let id: UUID
    let name: String
    let calories: Double
    let date: Date
    let mealType: MealType
    let nutrition: Nutrition? // now Codable
}
