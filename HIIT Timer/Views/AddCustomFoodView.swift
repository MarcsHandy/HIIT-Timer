import SwiftUI

struct AddCustomFoodView: View {
    let meal: MealType
    let selectedDate: Date
    @Binding var foodEntries: [FoodEntry]
    
    @Binding var customFoodName: String
    @Binding var customCalories: String
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add \(meal.rawValue)")
                    .font(.headline)
                
                TextField("Food Name", text: $customFoodName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Calories", text: $customCalories)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Button("Save") {
                        saveFoodEntry()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Cancel") {
                        isPresented = false
                    }
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Custom Food")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
    
    // MARK: - Functions
    private func saveFoodEntry() {
        guard let calories = Double(customCalories),
              !customFoodName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let entry = FoodEntry(
            id: UUID(),
            name: customFoodName.trimmingCharacters(in: .whitespaces),
            calories: calories,
            date: selectedDate,
            mealType: meal
        )
        
        foodEntries.append(entry)
        
        // Reset fields and close sheet
        customFoodName = ""
        customCalories = ""
        isPresented = false
    }
}

struct AddCustomFoodView_Previews: PreviewProvider {
    @State static var foodEntries: [FoodEntry] = []
    @State static var foodName = ""
    @State static var calories = ""
    @State static var isPresented = true
    
    static var previews: some View {
        AddCustomFoodView(
            meal: .breakfast,
            selectedDate: Date(),
            foodEntries: $foodEntries,
            customFoodName: $foodName,
            customCalories: $calories,
            isPresented: $isPresented
        )
    }
}
