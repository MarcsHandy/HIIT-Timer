import SwiftUI

struct SettingsMenuView: View {
    @Binding var showHamburgerMenu: Bool
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Sticky header with hamburger
            HeaderView(title: "Settings", showHamburgerMenu: $showHamburgerMenu)
                .zIndex(1)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("App Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    // Settings content
                    VStack(spacing: 16) {
                        Toggle("Sound Effects", isOn: $soundEnabled)
                        Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
        }
    }
}
