import SwiftUI

struct HeaderView: View {
    let title: String
    @Binding var showHamburgerMenu: Bool
    
    var body: some View {
        HStack {
            // Hamburger menu button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showHamburgerMenu.toggle()
                }
            }) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.primary)
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    )
            }
            
            Spacer()
            
            // App title
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Invisible spacer for symmetry
            Circle()
                .fill(Color.clear)
                .frame(width: 44, height: 44)
        }
        .padding(.horizontal)
    }
}
