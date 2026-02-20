//
//  CodeBreaker.swift
//  CodeBreaker
//
//  Created by Juan Urdaneta on 26/12/25.
//

import SwiftUI

typealias Peg = String

extension Peg {
    static let missing = "clear"
}

enum Guess {
    case successful
    case duplicated
    case missing
}

struct CodeBreaker {
    static let minPegs = 3
    static let maxPegs = 6

    var masterCode: Code
    var guess: Code
    var attempts: [Code] = []
    var pegChoices: [Peg]

    init(from pegChoices: [Peg]) {
        // choose a random peg count in allowed range
        let randomPegCount = Int.random(
            in: CodeBreaker.minPegs...CodeBreaker.maxPegs
        )

        // random `randomPegCount` choosed from the provided choices
        let randomPegs: [Peg] = Array(
            pegChoices.shuffled().prefix(randomPegCount)
        )

        masterCode = Code(kind: .master, pegCount: randomPegCount)
        guess = Code(kind: .guess, pegCount: randomPegCount)

        self.pegChoices = randomPegs
        masterCode.randomize(from: randomPegs)
        // print(masterCode)
    }

    mutating func attemptGuess() -> Guess {
        var attempt = guess
        attempt.kind = .attempt(guess.match(against: masterCode))

        // RT2: Ignore attempts by the user that they’ve already tried
        // before or which have no pegs chosen at all.
        if attempts.contains(where: { $0 == attempt }) {
            return Guess.duplicated
        } else if attempt.pegs.contains(where: { $0 == Peg.missing }) {
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
            guess.pegs[index] = pegChoices.first ?? Peg.missing
        }
    }
}

struct Code: Equatable {
    var kind: Kind
    var pegs: [Peg]

    init(kind: Kind, pegCount: Int) {
        self.kind = kind
        self.pegs = Array(repeating: Peg.missing, count: pegCount)
    }

    enum Kind: Equatable {
        case master
        case guess
        case attempt([Match])
        case unknown
    }

    mutating func randomize(from pegChoices: [Peg]) {
        for index in pegChoices.indices {
            pegs[index] = pegChoices.randomElement() ?? Peg.missing
        }
    }

    var matches: [Match]? {
        switch kind {
        case .attempt(let matches): return matches
        default: return nil
        }
    }

    func match(against otherCode: Code) -> [Match] {
        var pegsToMatch = otherCode.pegs

        let backwardsExactMatches = pegs.indices.reversed().map { index in
            if pegsToMatch.count > index, pegsToMatch[index] == pegs[index] {
                pegsToMatch.remove(at: index)
                return Match.exact
            }
            return .nomatch
        }

        let exactMatches = Array(backwardsExactMatches.reversed())
        return pegs.indices.map { index in
            if exactMatches[index] != .exact,
                let matchIndex = pegsToMatch.firstIndex(of: pegs[index])
            {
                pegsToMatch.remove(at: matchIndex)
                return .inexact
            }
            return exactMatches[index]
        }
    }
}
