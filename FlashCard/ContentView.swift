import SwiftUI

struct ContentView: View {
    @StateObject private var flashcardViewModel = FlashcardViewModel()
    
    @State private var backgroundColor: Color = .white  // Arka plan rengi
    @State private var showMessage = false
    @State private var messagePosition: [CGPoint] = [
        CGPoint(x: 0.5, y: 0.5) // Dairenin merkezi
    ]
    @State private var currentMessage: String = "Doğru!"  // Veya "Yanlış"
    @State private var showCorrectMessage: Bool = false // Doğru cevap için
    @State private var showWrongMessage: Bool = false // Yanlış cevap için
    
    let originalBackgroundColor: Color = .white  // Orijinal arka plan rengi
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Doğru Cevaplar: \(flashcardViewModel.correctAnswersCount)")
                        .font(.headline)
                        .padding()
                        .background(backgroundColor)
                        .foregroundColor(.black) // Metin rengi siyah
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding()
                .padding(.top, 40) // "Doğru Cevaplar" kutusunu biraz aşağıya kaydırdım.
                
                Spacer()
                
                if flashcardViewModel.gameOver {
                    VStack {
                        // Oyun Bitti animasyonu
                        Text("Oyun Bitti!")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        
                        HStack(spacing: 40) {
                            Button(action: {
                                flashcardViewModel.restartGame()
                            }) {
                                Image(systemName: "goforward")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            }
                            .accessibilityLabel("Oyun Yenile")
                            
                            Button(action: {
                                flashcardViewModel.restoreHearts()
                            }) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 42)) // %20 küçültüldü
                                    .foregroundColor(.red)
                                    .padding()
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                                    .offset(y: -10) // Yukarıya taşındı
                            }
                            .accessibilityLabel("Kalpleri Yenile")
                        }
                    }
                    .padding()
                } else {
                    if flashcardViewModel.loadingNewQuestions {
                        // Kum saati animasyonu
                        VStack {
                            Image(systemName: "hourglass.fill") // Kum saati simgesi
                                .font(.system(size: 50))
                                .rotationEffect(.degrees(showMessage ? 360 : 0)) // 360 derece döndürme
                                .animation(.linear(duration: 0.5).repeatForever(autoreverses: false), value: showMessage) // Hızlandırıldı
                                .padding()
                            Text("Yeni Sorular Yükleniyor...")
                                .font(.headline)
                                .padding()
                        }
                        .onAppear {
                            showMessage = true
                        }
                    } else if flashcardViewModel.currentQuestions.isEmpty {
                        Text("Yükleniyor...")
                            .font(.title)
                            .padding()
                    } else if flashcardViewModel.currentIndex < flashcardViewModel.currentQuestions.count {
                        let flashcard = flashcardViewModel.currentQuestions[flashcardViewModel.currentIndex]
                        
                        VStack {
                            if flashcardViewModel.showingAnswer {
                                // Animasyonlu Metin Yayılma
                                GeometryReader { geometry in
                                    ForEach(0..<messagePosition.count, id: \.self) { index in
                                        Text(currentMessage)
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(
                                                showCorrectMessage ? .green : (showWrongMessage ? .red : .clear)
                                            )  // Doğru için yeşil, yanlış için kırmızı
                                            .position(
                                                x: geometry.size.width * messagePosition[index].x,
                                                y: geometry.size.height * messagePosition[index].y
                                            )
                                            .scaleEffect(showMessage ? 3 : 0.7)  // Daha küçük ve hızla büyüyen metin
                                            .opacity(showMessage ? 1 : 0)
                                            .animation(
                                                .easeInOut(duration: 0.3)  // Kısa süreli animasyon
                                                    .repeatCount(2, autoreverses: true),  // İki kez tekrar et
                                                value: showMessage
                                            )
                                    }
                                }
                                .onAppear {
                                    if flashcardViewModel.resultMessage == "Doğru!" {
                                        showCorrectMessage = true
                                        currentMessage = "Doğru!"
                                        backgroundColor = .green.opacity(0.3) // Doğru ise açık yeşil
                                    } else {
                                        showWrongMessage = true
                                        currentMessage = "Yanlış"
                                        backgroundColor = .pink.opacity(0.3) // Yanlış ise açık pembe
                                    }
                                    
                                    showMessage = true
                                    
                                    // 1 saniye sonra animasyonu sonlandır ve arka planı eski haline getir
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        showMessage = false
                                        showCorrectMessage = false
                                        showWrongMessage = false
                                        backgroundColor = originalBackgroundColor // Arka planı eski haline getir
                                    }
                                }
                            } else {
                                Text(flashcard.question)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .padding()
                                    .transition(.scale)
                                    .animation(.easeInOut(duration: 0.5))
                                
                                VStack(spacing: 10) {
                                    ForEach(flashcard.choices, id: \.self) { choice in
                                        Button(action: {
                                            flashcardViewModel.checkAnswer(choice, for: flashcard)
                                        }) {
                                            Text(choice)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(10)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                        .transition(.scale)
                                        .animation(.easeInOut(duration: 0.5))
                                    }
                                }
                                .transition(.scale)
                                .animation(.easeInOut(duration: 0.5))
                            }
                        }
                        .padding()
                        .animation(.easeInOut)
                    }
                }
                
                Spacer()
                
                if !flashcardViewModel.gameOver {
                    HStack {
                        ForEach(0..<flashcardViewModel.heartsRemaining, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .font(.system(size: 42)) // %20 küçültüldü
                                .foregroundColor(.red)
                                .offset(y: -10) // Yukarıya taşındı
                        }
                    }
                    .padding()
                }
            }
            .background(backgroundColor)  // Arka plan rengini ayarlıyoruz
            .edgesIgnoringSafeArea(.all)  // Arka planın tüm ekranı kaplaması için
        }
    }
}
