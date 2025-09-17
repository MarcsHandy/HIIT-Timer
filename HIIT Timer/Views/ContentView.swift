import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [.orange.opacity(0.3), .red.opacity(0.2), .yellow.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Wrap everything in a ScrollView
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HeaderView()
                    
                    // Total Time Display
                    TotalTimeView(formattedTime: viewModel.formattedTotalTime)
                    
                    // Settings
                    SettingsView(viewModel: viewModel)
                    
                    // Timer Display
                    TimerDisplayView(viewModel: viewModel)
                    
                    // Control Buttons
                    ControlButtonsView(viewModel: viewModel)
                    
                    Spacer()
                }
                .padding(.vertical) // Add some vertical padding for better spacing
            }
            .blur(radius: viewModel.showingAdjuster ? 10 : 0)
            .animation(.easeInOut(duration: 0.3), value: viewModel.showingAdjuster)
            
            // Full Screen Adjuster
            if viewModel.showingAdjuster, let adjuster = viewModel.currentAdjuster {
                FullScreenAdjuster(
                    isShowing: $viewModel.showingAdjuster,
                    value: $viewModel.tempValue,
                    textInput: $viewModel.textInput,
                    isEditingText: $viewModel.isEditingText,
                    adjuster: adjuster,
                    backgroundColor: adjuster.color,
                    onValueChange: { newValue in
                        viewModel.tempValue = newValue
                        viewModel.textInput = "\(newValue)"
                        viewModel.applyAdjustment(newValue)
                    },
                    onApply: { finalValue in
                        viewModel.applyAdjustment(finalValue)
                    }
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
    }
}

// Supporting subviews for ContentView
struct HeaderView: View {
    var body: some View {
        // Your header content here
    }
}

struct TotalTimeView: View {
    let formattedTime: String
    
    var body: some View {
        VStack {
            Text("TOTAL WORKOUT TIME")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(formattedTime)
                .font(.title2)
                .fontWeight(.heavy)
                .foregroundColor(.red)
        }
        .padding()
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.yellow.opacity(0.2))
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(
                        LinearGradient(
                            colors: [.red, .yellow, .black],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            }
        )
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
