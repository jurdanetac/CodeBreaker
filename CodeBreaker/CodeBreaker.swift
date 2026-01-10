//
//  CodeBreaker.swift
//  CodeBreaker
//
//  Created by Juan Urdaneta on 26/12/25.
//

import SwiftUI

typealias Peg = String

let minPegCount = 3
let maxPegCount = 6

enum Guess {
    case successful
    case duplicated
    case missing
}

struct Theme {
    let name: String
    let views: [String: any View]
}

struct CodeBreaker {
    let themes: [Theme] = [
        Theme(
            name: "colors",
            views: [
                "red": Color.red,
                "orange": Color.orange,
                "yellow": Color.yellow,
                "green": Color.green,
                "mint": Color.mint,
                "teal": Color.teal,
                "cyan": Color.cyan,
                "blue": Color.blue,
                "indigo": Color.indigo,
                "purple": Color.purple,
                "pink": Color.pink,
                "brown": Color.brown,
                "gray": Color.gray,
            ]

        ),
        Theme(
            name: "emojis",
            views: [
                "rocket": Text("🚀"),
                "rainbow": Text("🌈"),
                "star": Text("⭐"),
                "fire": Text("🔥"),
                "heart": Text("❤️"),
                "crown": Text("👑"),
                "pizza": Text("🍕"),
                "earth": Text("🌍"),
                "alien": Text("👽"),
                "ghost": Text("👻"),
                "robot": Text("🤖"),
                "party": Text("🥳"),
                "check": Text("✅"),
            ]

        ),
    ]

    let numberOfPegs: Int

    var masterCode: Code
    var guess: Code
    var attempts: [Code] = []

    // by default use colors theme
    var pegTheme: Theme
    var pegChoices: [Peg] {
        return Array(pegTheme.views.keys)
    }

    init(of numberOfPegs: Int, with themeName: String) {
        var numberOfPegs = numberOfPegs
        var theme: Theme

        if !themes.filter({ $0.name == "themeName" }).isEmpty {
            let foundTheme = themes.filter({ $0.name == "themeName" }).first!
            if numberOfPegs == foundTheme.views.count {
                theme = foundTheme
            } else {
                // invalid peg count
                if !(numberOfPegs >= minPegCount && numberOfPegs <= maxPegCount)
                {
                    numberOfPegs = Int.random(
                        in: minPegCount..<maxPegCount
                    )
                }

                var randomPegs: [String: any View] = [:]
                repeat {
                    let peg = foundTheme.views.randomElement()!

                    if !randomPegs.contains(where: { $0.key == peg.key }) {
                        randomPegs[peg.key] = peg.value
                    }
                } while randomPegs.count != numberOfPegs

                theme = Theme(name: themeName, views: randomPegs)
            }
        } else {
            // default safe
            theme = themes[0]
            numberOfPegs = themes[0].views.count
        }

        self.pegTheme = theme
        self.numberOfPegs = numberOfPegs

        self.masterCode = Code(kind: .master, pegCount: numberOfPegs)
        self.masterCode.randomize(from: Array(theme.views.keys))

        self.guess = Code(kind: .guess, pegCount: pegTheme.views.count)
    }

    mutating func setTheme(theme: Theme) {
        self.pegTheme = theme
        self.restartGame()
    }

    mutating func restartGame() {
        // new configuration
        let generatedPegCount = Int.random(in: minPegCount..<maxPegCount)
        var generatedPegChoices = [Peg](
            repeating: Code.missing,
            count: generatedPegCount
        )

        for index in 0..<generatedPegCount {
            generatedPegChoices[index] = self.pegChoices.randomElement()!
        }

        var newMasterCode = Code(kind: .master, pegCount: generatedPegCount)
        newMasterCode.randomize(from: generatedPegChoices)
        masterCode = newMasterCode

        let newGuess = Code(kind: .guess, pegCount: generatedPegCount)
        guess = newGuess
        attempts = []
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
        if let indexOfExistingPegInPegChoices = self.pegChoices
            .firstIndex(
                of: existingPeg
            )
        {
            let newPeg = self.pegChoices[
                (indexOfExistingPegInPegChoices + 1)
                    % self.pegChoices.count
            ]
            guess.pegs[index] = newPeg
        } else {
            guess.pegs[index] = self.pegChoices.first ?? Code.missing
        }
    }
}

struct Code: Equatable {
    var kind: Kind
    var pegs: [Peg]

    init(kind: Kind, pegCount: Int) {
        self.kind = kind
        self.pegs = Array(repeating: Code.missing, count: pegCount)
    }

    static let missing: Peg = "clear"

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
