import SwiftUI

struct ContentView: View {
    @StateObject private var flashcardViewModel = FlashcardViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    // Sabit "Doğru Cevaplar" kutucuğu
                    Text("Doğru Cevaplar: \(flashcardViewModel.correctAnswersCount)")
                        .font(.headline)
                        .padding()
                        .background(Color.green) // Arka plan rengini yeşil yap
                        .foregroundColor(.white) // Metin rengini beyaz yap
                        .cornerRadius(10) // Kutunun köşelerini yuvarlat
                        .shadow(radius: 5) // Gölge ekle
                }
                .padding()
                .padding(.top, 20) // Üstten boşluk ekleyerek yukarıya sabitle
                .padding(.trailing, 20) // Sağdan boşluk ekleyerek sağa sabitle
                
                Spacer()
                
                if flashcardViewModel.gameOver {
                    VStack {
                        Text("Oyun Bitti!")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        
                        Button(action: {
                            flashcardViewModel.restartGame()
                        }) {
                            Text("Tekrar Oyna")
                                .font(.title2)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    if flashcardViewModel.loadingNewQuestions {
                        ProgressView("Yeni sorular geliyor...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.5))
                    } else if flashcardViewModel.currentQuestions.isEmpty {
                        Text("Yükleniyor...")
                            .font(.title)
                            .padding()
                    } else if flashcardViewModel.currentIndex < flashcardViewModel.currentQuestions.count {
                        let flashcard = flashcardViewModel.currentQuestions[flashcardViewModel.currentIndex]
                        
                        VStack {
                            if flashcardViewModel.showingAnswer {
                                Text(flashcardViewModel.resultMessage ?? "Doğru!")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(flashcardViewModel.resultMessage == "Doğru!" ? .green : .red)
                                    .transition(.opacity)
                                    .padding()
                                    .animation(.easeInOut)
                            } else {
                                Text(flashcard.question)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .padding()
                                    .transition(.move(edge: .top))
                                
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
                                    }
                                }
                                .transition(.scale)
                            }
                        }
                        .padding()
                        .animation(.easeInOut)
                    }
                }
                
                Spacer()
                
                // Kalp simgeleri
                if !flashcardViewModel.gameOver {
                    HStack {
                        ForEach(0..<flashcardViewModel.heartsRemaining, id: \.self) { _ in
                            Image(systemName: "heart.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.red)
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
