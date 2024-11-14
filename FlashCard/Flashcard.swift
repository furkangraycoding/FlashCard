import Foundation

struct Flashcard: Identifiable, Codable, Hashable {
    let id = UUID()
    let question: String
    var choices: [String]
    let answer: String
    
    mutating func shuffleChoices() {
        choices.shuffle()
    }
}
