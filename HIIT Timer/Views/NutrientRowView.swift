import SwiftUI

struct NutrientRowView: View {
    let name: String
    let amount: Double
    let rda: Double? // Recommended daily allowance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Row with name, amount / RDA, and percent
            HStack {
                if let rda = rda {
                    Text("\(name) \(amount, specifier: "%.1f") / \(rda, specifier: "%.1f")\(unit(for: name))")
                        .font(.subheadline)
                } else {
                    Text("\(name) \(amount, specifier: "%.1f")\(unit(for: name))")
                        .font(.subheadline)
                }
                
                Spacer()
                
                if let rda = rda {
                    let percent = (amount / rda) * 100
                    Text("\(percent, specifier: "%.0f")%")
                        .font(.subheadline)
                }
            }
            
            // Progress bar underneath
            if let rda = rda {
                let fraction = min(amount / rda, 1.0)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geo.size.width, height: 8)
                            .foregroundColor(Color.gray.opacity(0.3))
                            .cornerRadius(4)
                        Rectangle()
                            .frame(width: geo.size.width * fraction, height: 8)
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(.vertical, 4)
    }
    
    // Optional: unit per nutrient
    private func unit(for nutrient: String) -> String {
        switch nutrient.lowercased() {
        case "sodium", "potassium", "cholesterol":
            return " mg"
        default:
            return " g"
        }
    }
}
