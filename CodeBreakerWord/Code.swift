//
//  Code.swift
//  CodeBreakerWord
//
//  Created by CS193p Instructor on 4/16/25.
//

import Foundation

enum Match {
    case nomatch
    case exact
    case inexact
}

struct Code {
    static let missingPeg: Peg = ""

    enum Kind: Equatable {
        case master(isHidden: Bool)
        case guess
        case attempt([Match])
        case unknown
    }

    var kind: Kind
    var pegs: [Peg]

    init(kind: Kind, pegs: [Peg]) {
        self.kind = kind
        self.pegs = pegs

        // clear pegs on guess code creation since we pass the game masterCode
        if self.kind == .guess {
            self.reset()
        }
    }

    var word: String {
        get { pegs.joined() }
        set { pegs = newValue.map { String($0) } }
    }

    var isHidden: Bool {
        switch kind {
        case .master(let isHidden): return isHidden
        default: return false
        }
    }

    var matches: [Match]? {
        switch kind {
        case .attempt(let matches): return matches
        default: return nil
        }
    }

    mutating func reset() {
        pegs = Array(repeating: Code.missingPeg, count: self.pegs.count)
    }

    func match(against otherCode: Code) -> [Match] {
        var pegsToMatch = otherCode.pegs

        let backwardsExactMatches = pegs.indices.reversed().map { index in
            if pegsToMatch.count > index, pegsToMatch[index] == pegs[index] {
                pegsToMatch.remove(at: index)
                return Match.exact
            } else {
                return .nomatch
            }
        }
        let exactMatches = Array(backwardsExactMatches.reversed())
        return pegs.indices.map { index in
            if exactMatches[index] != .exact,
                let matchIndex = pegsToMatch.firstIndex(of: pegs[index])
            {
                pegsToMatch.remove(at: matchIndex)
                return .inexact
            } else {
                return exactMatches[index]
            }
        }
    }
}
