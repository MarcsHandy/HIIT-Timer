import SwiftUI

// MARK: - CalorieTrackerView
struct CalorieTrackerView: View {
    @Binding var showHamburgerMenu: Bool
    
    @State private var selectedDate: Date = Date()
    @State private var foodEntries: [FoodEntry] = []
    
    @State private var showCustomFoodSheet = false
    @State private var customFoodName = ""
    @State private var customCalories = ""
    @State private var selectedMeal: MealType = .breakfast
    
    @State private var showSearchSheet = false
    @State private var searchMeal: MealType = .breakfast
    
    // MARK: - Computed
    private var totalCalories: Double {
        foodEntries
            .filter { Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
            .map(\.calories)
            .reduce(0, +)
    }
    
    private var nutritionScore: Int {
        let goal = 2000.0
        let diff = abs(goal - totalCalories)
        return max(0, 100 - Int(diff / 20))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HeaderView(title: "Calorie Tracker", showHamburgerMenu: $showHamburgerMenu)
                .zIndex(1)
            
            // Date Navigation
            HStack {
                Button(action: { changeDay(by: -1) }) { Image(systemName: "chevron.left") }
                Text(selectedDate, style: .date)
                    .font(.headline)
                Button(action: { changeDay(by: 1) }) { Image(systemName: "chevron.right") }
            }
            
            // Nutrition Score
            VStack {
                Text("Nutrition Score").font(.headline)
                Text("\(nutritionScore)/100")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(nutritionScore > 70 ? .green : .orange)
            }
            
            // Meal Sections
            List {
                ForEach(MealType.allCases, id: \.self) { meal in
                    Section(header: Text(meal.rawValue)) {
                        let entries = foodEntries.filter {
                            $0.mealType == meal &&
                            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                        }
                        
                        if entries.isEmpty {
                            Text("No items logged").foregroundColor(.gray)
                        } else {
                            ForEach(entries) { entry in
                                HStack {
                                    Text(entry.name)
                                    Spacer()
                                    Text("\(entry.calories, specifier: "%.0f") kcal")
                                        .foregroundColor(.red)
                                }
                            }
                            .onDelete { offsets in deleteEntry(at: offsets, in: meal) }
                        }
                        
                        // Search button
                        HStack(spacing: 16) {
                            // Add Custom Food Button
                            Button(action: {
                                selectedMeal = meal
                                showCustomFoodSheet = true
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                            }
                            .foregroundColor(.blue)
                            .buttonStyle(PlainButtonStyle()) // ensures tap area is just the icon

                            // Search Button
                            Button(action: {
                                searchMeal = meal
                                showSearchSheet = true
                            }) {
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                            }
                            .foregroundColor(.green)
                            .buttonStyle(PlainButtonStyle()) // ensures tap area is just the icon

                            Spacer() // push buttons to the left
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            Text("Total: \(totalCalories, specifier: "%.0f") kcal")
                .font(.headline)
                .padding()
        }
        // MARK: - Custom Food Sheet
        .sheet(isPresented: $showCustomFoodSheet) {
            VStack(spacing: 20) {
                Text("Add \(selectedMeal.rawValue)").font(.headline)
                
                TextField("Food Name", text: $customFoodName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Calories", text: $customCalories)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Button("Save") {
                        guard let calories = Double(customCalories),
                              !customFoodName.isEmpty else { return }
                        
                        let entry = FoodEntry(
                            id: UUID(),
                            name: customFoodName,
                            calories: calories,
                            date: selectedDate,
                            mealType: selectedMeal
                        )
                        foodEntries.append(entry)
                        customFoodName = ""
                        customCalories = ""
                        showCustomFoodSheet = false
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Cancel") { showCustomFoodSheet = false }
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        // MARK: - Search Sheet
        .sheet(isPresented: $showSearchSheet) {
            FoodSearchView(
                meal: searchMeal,
                selectedDate: selectedDate,
                foodEntries: $foodEntries,
                isPresented: $showSearchSheet
            )
        }
    }
    
    // MARK: - Functions
    private func changeDay(by value: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: value, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func deleteEntry(at offsets: IndexSet, in meal: MealType) {
        let entriesForMeal = foodEntries.enumerated().filter { _, entry in
            entry.mealType == meal &&
            Calendar.current.isDate(entry.date, inSameDayAs: selectedDate)
        }
        for index in offsets {
            let entryIndex = entriesForMeal[index].0
            foodEntries.remove(at: entryIndex)
        }
    }
}

struct CalorieTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        CalorieTrackerView(showHamburgerMenu: .constant(false))
            .previewDevice("iPhone 14")
    }
}
