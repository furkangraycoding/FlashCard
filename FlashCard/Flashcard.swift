import Foundation

struct Flashcard: Identifiable, Codable {
    let id = UUID()
    let question: String
    let choices: [String]
    let answer: String
}
