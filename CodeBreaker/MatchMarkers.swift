//
//  MatchMarkers.swift
//  CodeBreaker
//
//  Created by Juan Urdaneta on 28/11/25.
//

import SwiftUI

enum Match: CaseIterable {
    case exact
    case inexact
    case nomatch
}

struct MatchMarkers: View {
    let matches: [Match]

    var body: some View {
        HStack {
            VStack {
                matchMarker(peg: 0)
                matchMarker(peg: 1)
            }
            VStack {
                matchMarker(peg: 2)
                matchMarker(peg: 3)
            }
        }
    }

    func matchMarker(peg: Int) -> some View {
        let exactCount = matches.count { $0 == .exact }
        let foundCount = matches.count { $0 != .nomatch }

        return Circle()
            .fill(exactCount > peg ? Color.primary : Color.clear)
            .strokeBorder(
                foundCount > peg ? Color.primary : Color.clear,
                lineWidth: 2
            )
            .aspectRatio(1, contentMode: .fit)
    }
}

struct MatchMarkersPreview: View {
    let pegs: Int

    let allPossibleMatches = Match.allCases
    let matches: [Match] =
        ({
            return [Match.inexact]
        })()

    var body: some View {
        HStack {
            ForEach(0..<pegs, id: \.self) { _ in
                Circle().frame(width: 45, height: 90)
            }
            Spacer()
            MatchMarkers(matches: [.exact, .inexact, .exact]).frame(
                width: 45,
                height: 45
            )
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        MatchMarkersPreview(pegs: 1)
        MatchMarkersPreview(pegs: 2)
        MatchMarkersPreview(pegs: 3)
        MatchMarkersPreview(pegs: 4)
        MatchMarkersPreview(pegs: 6)
        MatchMarkersPreview(pegs: 6)
        MatchMarkersPreview(pegs: 5)
        MatchMarkersPreview(pegs: 5)
    }.padding()
}
