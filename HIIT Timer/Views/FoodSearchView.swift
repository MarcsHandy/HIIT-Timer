import SwiftUI

struct FoodSearchView: View {
    let meal: MealType
    let selectedDate: Date
    @Binding var foodEntries: [FoodEntry]
    @Binding var isPresented: Bool
    
    @State private var query: String = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Enter food to search...", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if isLoading {
                    ProgressView("Searching...")
                }
                
                Button("Add Food") {
                    Task {
                        guard !query.isEmpty else { return }
                        isLoading = true
                        if let entry = await fetchCalories(for: query) {
                            foodEntries.append(entry)
                            query = ""
                            isPresented = false
                        }
                        isLoading = false
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
            }
            .navigationTitle("Search \(meal.rawValue)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
    
    private func fetchCalories(for food: String) async -> FoodEntry? {
        guard let appId = ProcessInfo.processInfo.environment["NUTRITIONIX_APP_ID"],
              let apiKey = ProcessInfo.processInfo.environment["NUTRITIONIX_API_KEY"] else {
            print("❌ Missing Nutritionix credentials")
            return nil
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
               let foods = json["foods"] as? [[String: Any]],
               let first = foods.first,
               let calories = first["nf_calories"] as? Double,
               let name = first["food_name"] as? String {
                
                return FoodEntry(
                    id: UUID(),
                    name: name.capitalized,
                    calories: calories,
                    date: selectedDate,
                    mealType: meal
                )
            }
        } catch {
            print("❌ API Error: \(error.localizedDescription)")
        }
        return nil
    }
}
