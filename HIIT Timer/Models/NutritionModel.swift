import Foundation

struct Nutrition: Codable {
    let calories: Double?
    let totalFat: Double?
    let saturatedFat: Double?
    let protein: Double?
    let totalCarbs: Double?
    let fiber: Double?
    let sugars: Double?
    let cholesterol: Double?
    let sodium: Double?
    
    // Initialize from Nutritionix API dictionary
    init(from dict: [String: Any]) {
        self.calories = dict["nf_calories"] as? Double
        self.totalFat = dict["nf_total_fat"] as? Double
        self.saturatedFat = dict["nf_saturated_fat"] as? Double
        self.protein = dict["nf_protein"] as? Double
        self.totalCarbs = dict["nf_total_carbohydrate"] as? Double
        self.fiber = dict["nf_dietary_fiber"] as? Double
        self.sugars = dict["nf_sugars"] as? Double
        self.cholesterol = dict["nf_cholesterol"] as? Double
        self.sodium = dict["nf_sodium"] as? Double
    }
}
