import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var viewModel = TimerViewModel()
    @State private var showHamburgerMenu = false
    @State private var selectedTab: HamburgerMenuView.MenuTab = .timer

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [.orange.opacity(0.3), .red.opacity(0.2), .yellow.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Main content
                Group {
                    switch selectedTab {
                    case .timer:
                        timerContentView()
                    case .history:
                        HistoryView(showHamburgerMenu: $showHamburgerMenu, selectedTab: $selectedTab)
                            .environmentObject(viewModel)
                    case .settings:
                        SettingsMenuView(showHamburgerMenu: $showHamburgerMenu)
                    case .statistics:
                        StatisticsView(showHamburgerMenu: $showHamburgerMenu)
                            .environmentObject(viewModel)
                    }
                }
                .blur(radius: (viewModel.showingAdjuster || showHamburgerMenu) ? 10 : 0)
                .animation(.easeInOut(duration: 0.3), value: viewModel.showingAdjuster)
                .animation(.easeInOut(duration: 0.3), value: showHamburgerMenu)
                
                // Hamburger Menu Overlay
                if showHamburgerMenu {
                    HamburgerMenuView(isShowing: $showHamburgerMenu, selectedTab: $selectedTab)
                        .zIndex(2)
                }
                
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
                    .zIndex(3)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    @ViewBuilder
    private func timerContentView() -> some View {
        VStack(spacing: 0) {
            // Sticky header with hamburger (same as HistoryView)
            HeaderView(title: "Workout Timer", showHamburgerMenu: $showHamburgerMenu)
                .zIndex(1) // ensure it stays above the scroll content

            ScrollView {
                VStack(spacing: 20) {
                    TotalTimeView(viewModel: viewModel)

                    SettingsView(viewModel: viewModel)

                    TimerDisplayView(viewModel: viewModel)

                    ControlButtonsView(viewModel: viewModel)

                    Spacer()
                }
                .padding(.vertical)
            }
        }
    }
}

// MARK: - TotalTimeView
struct TotalTimeView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        VStack {
            Text("TOTAL WORKOUT TIME")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.black)
            
            Text(viewModel.formattedTotalTime) // dynamically updates
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
            .previewDevice("iPhone 14")
    }
}

