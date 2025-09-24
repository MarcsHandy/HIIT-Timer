import SwiftUI

struct HamburgerMenuView: View {
    @Binding var isShowing: Bool
    @Binding var selectedTab: MenuTab
    @State private var localSelectedTab: MenuTab
    
    init(isShowing: Binding<Bool>, selectedTab: Binding<MenuTab>) {
        self._isShowing = isShowing
        self._selectedTab = selectedTab
        self._localSelectedTab = State(initialValue: selectedTab.wrappedValue)
    }
    
    enum MenuTab: String, CaseIterable {
        case timer = "Timer"
        case history = "History"
        case settings = "Settings"
        case statistics = "Statistics"
        
        var icon: String {
            switch self {
            case .timer: return "⏱️"
            case .history: return "📊"
            case .settings: return "⚙️"
            case .statistics: return "📈"
            }
        }
        
        // Add theme color for each tab
        var themeColor: Color {
            switch self {
            case .timer: return .orange
            case .history: return .red
            case .settings: return .yellow
            case .statistics: return Color.orange.opacity(0.8)
            }
        }
    }
    
    // App theme gradient
    private var appGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [.orange, .red, .yellow]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent background with app theme colors
            LinearGradient(
                gradient: Gradient(colors: [.orange.opacity(0.2), .red.opacity(0.15), .yellow.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation {
                    isShowing = false
                }
            }
            
            // Menu panel
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    // Header with app theme gradient
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Workout Timer")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Your Fitness Companion")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .padding(.top, 50)
                    .background(appGradient)
                    
                    // Menu items with theme colors
                    ForEach(MenuTab.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTab = tab
                                localSelectedTab = tab
                                isShowing = false // Close menu after selection
                                
                                // Haptic feedback
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                        }) {
                            HStack {
                                Text(tab.icon)
                                    .font(.title3)
                                
                                Text(tab.rawValue)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                
                                Spacer()
                                
                                if localSelectedTab == tab {
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(tab.themeColor)
                                        .fontWeight(.bold)
                                }
                            }
                            .foregroundColor(localSelectedTab == tab ? tab.themeColor : .primary)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(localSelectedTab == tab ? tab.themeColor.opacity(0.15) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(localSelectedTab == tab ? tab.themeColor.opacity(0.3) : Color.clear, lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    
                    Spacer()
                    
                    // Footer with subtle theme colors
                    VStack {
                        Divider()
                            .background(Color.orange.opacity(0.3))
                        
                        HStack {
                            Text("Version 1.0")
                                .font(.caption)
                                .foregroundColor(.orange)
                            
                            Spacer()
                            
                            Text("🔥")
                                .font(.caption)
                        }
                        .padding()
                    }
                    .background(Color.yellow.opacity(0.1))
                }
                .frame(width: 280)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemBackground),
                            Color(.systemBackground).opacity(0.95)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Rectangle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.orange.opacity(0.1), .red.opacity(0.05), .yellow.opacity(0.1)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: 4)
                        .offset(x: 138), // Half of 280 - 2 (half of stroke width)
                    alignment: .trailing
                )
                .offset(x: isShowing ? 0 : -280)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 5, y: 0)
                
                Spacer()
            }
        }
        .ignoresSafeArea()
        .onChange(of: selectedTab) { newValue in
            localSelectedTab = newValue
        }
    }
}
