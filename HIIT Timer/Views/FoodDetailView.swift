import SwiftUI

struct FoodDetailView: View {
    let food: Food
    
    // Recommended Daily Allowances (adjustable)
    private let nutrientRDA: [String: Double] = [
        "nf_total_fat": 70,
        "nf_saturated_fat": 20,
        "nf_total_carbohydrate": 310,
        "nf_sugars": 50,
        "nf_dietary_fiber": 30,
        "nf_protein": 50,
        "nf_sodium": 2300,
        "nf_potassium": 3500,
        "nf_cholesterol": 300
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(food.name)
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 8)
                
                Divider()
                
                // Basic Info
                VStack(alignment: .leading, spacing: 6) {
                    Text("Calories: \(food.calories, specifier: "%.0f") kcal")
                        .font(.headline)
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Macronutrients
                Text("Macronutrients")
                    .font(.headline)
                    .padding(.vertical, 4)
                
                ForEach(["nf_total_fat", "nf_saturated_fat", "nf_total_carbohydrate", "nf_sugars", "nf_dietary_fiber", "nf_protein"], id: \.self) { key in
                    if let amount = food.nutrients[key] {
                        NutrientRowView(
                            name: displayName(for: key),
                            amount: amount,
                            rda: nutrientRDA[key]
                        )
                    }
                }
                
                Divider()
                
                // Micronutrients
                Text("Micronutrients")
                    .font(.headline)
                    .padding(.vertical, 4)
                
                ForEach(["nf_sodium", "nf_potassium", "nf_cholesterol"], id: \.self) { key in
                    if let amount = food.nutrients[key] {
                        NutrientRowView(
                            name: displayName(for: key),
                            amount: amount,
                            rda: nutrientRDA[key]
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Nutrition Facts")
    }
    
    // Helper function to make readable labels
    private func displayName(for key: String) -> String {
        switch key {
        case "nf_total_fat": return "Fat"
        case "nf_saturated_fat": return "Saturated Fat"
        case "nf_total_carbohydrate": return "Carbohydrates"
        case "nf_sugars": return "Sugar"
        case "nf_dietary_fiber": return "Fiber"
        case "nf_protein": return "Protein"
        case "nf_sodium": return "Sodium"
        case "nf_potassium": return "Potassium"
        case "nf_cholesterol": return "Cholesterol"
        default: return key
        }
    }
}
