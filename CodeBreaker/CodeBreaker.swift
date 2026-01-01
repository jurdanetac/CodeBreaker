//
//  CodeBreaker.swift
//  CodeBreaker
//
//  Created by Juan Urdaneta on 26/12/25.
//

import SwiftUI

typealias Peg = Color

let availablePegs: [Color] = [
    .red,
    .orange,
    .yellow,
    .green,
    .mint,
    .teal,
    .cyan,
    .blue,
    .indigo,
    .purple,
    .pink,
    .brown,
    .gray,
    .black,
    .white,
]

enum Guess {
    case successful
    case duplicated
    case missing
}

struct CodeBreaker {
    var masterCode: Code = Code(kind: .master)
    var guess: Code = Code(kind: .guess)
    var attempts: [Code] = []
    var pegChoices: [Peg]

    init(pegChoices: [Peg] = [.red, .green, .blue, .yellow]) {
        self.pegChoices = pegChoices
        masterCode.randomize(from: pegChoices)
        print(masterCode)
    }

    mutating func restartGame() {
        for index in 0..<4 {
            pegChoices[index] = availablePegs.randomElement() ?? Code.missing
            masterCode.randomize(from: pegChoices)
            print(masterCode)
            attempts = []
            for index in 0..<guess.pegs.count {
                guess.pegs[index] = Code.missing
            }
        }
    }

    mutating func attemptGuess() -> Guess {
        var attempt = guess
        attempt.kind = .attempt(guess.match(against: masterCode))

        // RT2: Ignore attempts by the user that they’ve already tried
        // before or which have no pegs chosen at all.
        if attempts.contains(where: { $0 == attempt }) {
            return Guess.duplicated
        } else if attempt.pegs.contains(where: { $0 == Code.missing }) {
            return Guess.missing
        }

        attempts.append(attempt)

        return Guess.successful
    }

    mutating func changeGuessPeg(at index: Int) {
        let existingPeg = guess.pegs[index]
        if let indexOfExistingPegInPegChoices = pegChoices.firstIndex(
            of: existingPeg
        ) {
            let newPeg = pegChoices[
                (indexOfExistingPegInPegChoices + 1) % pegChoices.count
            ]
            guess.pegs[index] = newPeg
        } else {
            guess.pegs[index] = pegChoices.first ?? Code.missing
        }
    }
}

struct Code: Equatable {
    var kind: Kind
    var pegs: [Peg] = Array(repeating: Code.missing, count: 4)

    static let missing: Peg = .clear

    enum Kind: Equatable {
        case master
        case guess
        case attempt([Match])
        case unknown
    }

    mutating func randomize(from pegChoices: [Peg]) {
        for index in pegChoices.indices {
            pegs[index] = pegChoices.randomElement() ?? Code.missing
        }
    }

    var matches: [Match] {
        switch kind {
        case .attempt(let matches): return matches
        default: return []
        }
    }

    func match(against otherCode: Code) -> [Match] {
        var results: [Match] = Array(repeating: .nomatch, count: pegs.count)
        var pegsToMatch = otherCode.pegs
        for index in pegs.indices.reversed() {
            if pegsToMatch.count > index, pegsToMatch[index] == pegs[index] {
                results[index] = .exact
                pegsToMatch.remove(at: index)
            }
        }
        for index in pegs.indices {
            if results[index] != .exact {
                if let matchIndex = pegsToMatch.firstIndex(of: pegs[index]) {
                    results[index] = .inexact
                    pegsToMatch.remove(at: matchIndex)
                }
            }
        }
        return results
    }
}
