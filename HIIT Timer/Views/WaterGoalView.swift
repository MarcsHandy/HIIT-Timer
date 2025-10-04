import SwiftUI

struct WaterGoalView: View {
    @State private var cupsDrank: Int = 0
    @State private var dailyGoalOunces: Double = 64 // default daily goal
    private let totalCups = 8
    @State private var showingGoalEditor = false
    @State private var newGoalText = ""

    var body: some View {
        HStack(spacing: 8) {
            Text("Water:")
                .font(.subheadline)
                .frame(width: 50, alignment: .leading)
            
            // Drops
            ForEach(0..<totalCups, id: \.self) { index in
                Image(systemName: index < cupsDrank ? "drop.fill" : "drop")
                    .resizable()
                    .frame(width: 20, height: 28)
                    .foregroundColor(.blue)
                    .onTapGesture {
                        if index < cupsDrank {
                            cupsDrank = index
                        } else {
                            cupsDrank = index + 1
                        }
                    }
            }
            
            Spacer()
            
            // Ounces consumed / daily goal
            let ouncesPerDrop = dailyGoalOunces / Double(totalCups)
            Text("\(Int(ouncesPerDrop * Double(cupsDrank)))/\(Int(dailyGoalOunces)) oz")
                .font(.subheadline)
                .frame(width: 60, alignment: .trailing)
                .onTapGesture {
                    // Show editor sheet
                    newGoalText = "\(Int(dailyGoalOunces))"
                    showingGoalEditor = true
                }
        }
        .padding(.vertical, 6)
        .padding(.horizontal)
        .sheet(isPresented: $showingGoalEditor) {
            VStack(spacing: 20) {
                Text("Set Daily Water Goal")
                    .font(.headline)
                
                TextField("Ounces", text: $newGoalText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                
                HStack(spacing: 20) {
                    Button("Save") {
                        if let newGoal = Double(newGoalText), newGoal > 0 {
                            dailyGoalOunces = newGoal
                            cupsDrank = 0 // reset progress
                        }
                        showingGoalEditor = false
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Cancel") {
                        showingGoalEditor = false
                    }
                    .padding()
                    .background(Color.gray.opacity(0.3))
                    .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

struct WaterGoalView_Previews: PreviewProvider {
    static var previews: some View {
        WaterGoalView()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
