import SwiftUI

struct FoodSearchView: View {
    let meal: MealType
    let selectedDate: Date
    @Binding var foodEntries: [FoodEntry]
    @Binding var isPresented: Bool
    
    @State private var query: String = ""
    @State private var isLoading = false
    @State private var searchResults: [FoodEntry] = []
    @State private var selectedFood: FoodEntry?
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Field
                TextField("Enter food to search...", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: query) { newValue in
                        searchFood(query: newValue)
                    }
                
                // Loading Indicator
                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                }
                
                // Search Results
                List(searchResults) { food in
                    Button {
                        selectedFood = food
                    } label: {
                        HStack {
                            Text(food.name)
                            Spacer()
                            Text("\(Int(food.calories)) cal")
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Search \(meal.rawValue)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
            // Nutrition Detail Sheet
            .sheet(item: $selectedFood) { food in
                NutritionDetailView(food: food, isPresented: $selectedFood) { selectedFood in
                    // Add the food when pressed in the detail view
                    foodEntries.append(selectedFood)
                    isPresented = false // dismiss search view
                }
            }
        }
    }
    
    private func searchFood(query: String) {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        Task {
            isLoading = true
            searchResults = await fetchCalories(for: query)
            isLoading = false
        }
    }
    
    private func fetchCalories(for food: String) async -> [FoodEntry] {
        guard let appId = ProcessInfo.processInfo.environment["NUTRITIONIX_APP_ID"],
              let apiKey = ProcessInfo.processInfo.environment["NUTRITIONIX_API_KEY"] else {
            print("❌ Missing Nutritionix credentials")
            return []
        }
        
        let url = URL(string: "https://trackapi.nutritionix.com/v2/natural/nutrients")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(appId, forHTTPHeaderField: "x-app-id")
        request.setValue(apiKey, forHTTPHeaderField: "x-app-key")
        
        let body: [String: Any] = ["query": food]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let foods = json["foods"] as? [[String: Any]] {
                
                return foods.map { item in
                    let name = item["food_name"] as? String ?? "Unknown"
                    let calories = item["nf_calories"] as? Double ?? 0
                    let nutrition = Nutrition(from: item)
                    
                    return FoodEntry(
                        id: UUID(),
                        name: name.capitalized,
                        calories: calories,
                        date: selectedDate,
                        mealType: meal,
                        nutrition: nutrition
                    )
                }
            }
        } catch {
            print("❌ API Error: \(error.localizedDescription)")
        }
        return []
    }
}
