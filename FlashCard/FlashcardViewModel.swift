import SwiftUI
import Combine

class FlashcardViewModel: ObservableObject {
    @Published var flashcards: [Flashcard] = []
    @Published var currentIndex: Int = 0
    @Published var showingAnswer: Bool = false
    @Published var resultMessage: String? = nil
    @Published var currentQuestions: [Flashcard] = []
    @Published var correctAnswersCount: Int = 0
    @Published var loadingNewQuestions: Bool = false
    @Published var heartsRemaining: Int = 5 // Kalp simgeleri için
    @Published var gameOver: Bool = false // Oyun bitişi durumu
    
    private var allFlashcards: [Flashcard] = []
    private var wrongQuestions: [Flashcard] = []
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadFlashcards()
    }
    
    func loadFlashcards() {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            print("JSON file not found")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Flashcard].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to load JSON data: \(error.localizedDescription)")
                }
            }, receiveValue: { flashcards in
                self.allFlashcards = flashcards
                self.loadNewQuestions()
            })
            .store(in: &cancellables)
    }
    
    func loadNewQuestions() {
        guard !gameOver, allFlashcards.count >= 10 else {
            print("Not enough flashcards available or game is over.")
            return
        }
        
        loadingNewQuestions = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // 0.5 saniye bekle
            var newQuestions = Array(self.allFlashcards.shuffled().prefix(10))
            
            if !self.wrongQuestions.isEmpty {
                newQuestions.append(contentsOf: self.wrongQuestions)
                self.wrongQuestions.removeAll()
            }
            
            withAnimation(.easeInOut) {
                self.currentQuestions = newQuestions
                self.currentIndex = 0
                self.loadingNewQuestions = false
            }
        }
    }
    
    func checkAnswer(_ choice: String, for flashcard: Flashcard) {
        let isCorrect = choice == flashcard.answer
        resultMessage = isCorrect ? "Doğru!" : "Yanlış"
        showingAnswer = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut) {
                self.showingAnswer = false
                
                if isCorrect {
                    self.correctAnswersCount += 1
                } else {
                    self.heartsRemaining -= 1 // Kalp eksilt
                    self.wrongQuestions.append(flashcard)
                    
                    if self.heartsRemaining <= 0 {
                        self.heartsRemaining = 0
                        self.gameOver = true // Oyun bitişi
                    }
                }
                
                self.currentIndex += 1
                
                if self.currentIndex >= self.currentQuestions.count && !self.gameOver {
                    if !self.allFlashcards.isEmpty || !self.wrongQuestions.isEmpty {
                        self.loadNewQuestions()
                    } else {
                        self.resultMessage = nil
                        self.gameOver = true // Oyun bitişi, tüm sorular tamamlandığında
                    }
                }
            }
        }
    }
    
    func restartGame() {
        withAnimation(.easeInOut) {
            correctAnswersCount = 0
            heartsRemaining = 5
            gameOver = false
        }
        loadNewQuestions()
    }
}
