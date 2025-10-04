import SwiftUI

struct NutritionDetailView: View {
    let food: FoodEntry
    @Binding var isPresented: FoodEntry? 
    var onAdd: ((FoodEntry) -> Void)?

    var body: some View {
        NavigationView {
            VStack {
                List {
                    if let nutrition = food.nutrition {
                        Section(header: Text("Calories & Macros")) {
                            if let calories = nutrition.calories {
                                HStack { Text("Calories"); Spacer(); Text("\(Int(calories)) kcal") }
                            }
                            if let protein = nutrition.protein {
                                HStack { Text("Protein"); Spacer(); Text("\(protein, specifier: "%.1f") g") }
                            }
                            if let totalFat = nutrition.totalFat {
                                HStack { Text("Total Fat"); Spacer(); Text("\(totalFat, specifier: "%.1f") g") }
                            }
                            if let saturatedFat = nutrition.saturatedFat {
                                HStack { Text("Saturated Fat"); Spacer(); Text("\(saturatedFat, specifier: "%.1f") g") }
                            }
                            if let totalCarbs = nutrition.totalCarbs {
                                HStack { Text("Carbs"); Spacer(); Text("\(totalCarbs, specifier: "%.1f") g") }
                            }
                            if let fiber = nutrition.fiber {
                                HStack { Text("Fiber"); Spacer(); Text("\(fiber, specifier: "%.1f") g") }
                            }
                            if let sugars = nutrition.sugars {
                                HStack { Text("Sugars"); Spacer(); Text("\(sugars, specifier: "%.1f") g") }
                            }
                        }

                        Section(header: Text("Other")) {
                            if let cholesterol = nutrition.cholesterol {
                                HStack { Text("Cholesterol"); Spacer(); Text("\(cholesterol, specifier: "%.1f") mg") }
                            }
                            if let sodium = nutrition.sodium {
                                HStack { Text("Sodium"); Spacer(); Text("\(sodium, specifier: "%.1f") mg") }
                            }
                        }
                    } else {
                        Text("No nutrition info available")
                    }
                }

                // Add Food Button (permanent at bottom)
                Button(action: {
                    onAdd?(food)
                    isPresented = nil
                }) {
                    Text("Add Food")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding([.leading, .trailing, .bottom])
                }
            }
            .navigationTitle(food.name)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { isPresented = nil }
                }
            }
        }
    }
}
