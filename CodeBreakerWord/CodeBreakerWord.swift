//
//  CodeBreakerWord.swift
//  CodeBreakerWord
//
//  Created by CS193p Instructor on 4/9/25.
//

import Foundation

typealias Peg = String

struct CodeBreakerWord {
    static let minPegs = 3
    static let maxPegs = 6

    //    static func generateRandomNumberOfPegs() -> Int {
    //        Int.random(in: CodeBreakerWord.minPegs...CodeBreakerWord.maxPegs)
    //    }

    let pegChoices: [Peg] = "QWERTYUIOPASDFGHJKLZXCVBNM".map { String($0) }

    init(word: String = "AWAIT") {
        let wordArray = word.map { String($0) }
        masterCode = Code(kind: .master(isHidden: false), pegs: wordArray)
        guess = Code(kind: .guess, pegs: wordArray)
    }

    var masterCode: Code
    var guess: Code
    var attempts: [Code] = []

    var isOver: Bool {
        attempts.last?.pegs == masterCode.pegs
    }

    mutating func attemptGuess() {
        var attempt = guess
        attempt.kind = .attempt(guess.match(against: masterCode))
        attempts.append(attempt)
        guess.reset()
        if isOver {
            masterCode.kind = .master(isHidden: false)
        }
    }

    mutating func setGuessPeg(_ peg: Peg, at index: Int) {
        guard guess.pegs.indices.contains(index) else { return }
        guess.pegs[index] = peg
    }
}
