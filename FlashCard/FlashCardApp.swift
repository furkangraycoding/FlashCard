import SwiftUI

@main
struct FlashCardApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
    }
}

struct SplashScreen: View {
    @State private var isActive = false

    var body: some View {
        Group {
            if isActive {
                ContentView() // Ana içerik için yeni isim
            } else {
                splashContent
            }
        }
        .onAppear(perform: startTimer)
    }

    private var splashContent: some View {
        VStack {
            Text("TryKnowladge")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .background(Color.orange)
                .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.orange)
    }

    private func startTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isActive = true
            }
        }
    }
}
