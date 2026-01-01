//
//  MatchMarkers.swift
//  CodeBreaker
//
//  Created by Juan Urdaneta on 28/11/25.
//

import SwiftUI

// let circleRadius = CGFloat(45)

enum Match: CaseIterable {
    case exact
    case inexact
    case nomatch
}

struct MatchMarkers: View {
    let matches: [Match]

    var body: some View {
        // if no matches just a placeholder that fills space
        if matches.count == 0 {
            ClearCircle()
        } else {
            let numberOfColumns: Int =
                ({
                    return Int((Double(matches.count) / 2.0).rounded())
                })()

            VStack {
                HStack {
                    ForEach(0..<numberOfColumns, id: \.self) { pegIndex in
                        matchMarker(peg: pegIndex)
                    }
                }
                HStack {
                    if numberOfColumns * 2 > matches.count {
                        ForEach(
                            numberOfColumns..<numberOfColumns * 2 - 1,
                            id: \.self
                        ) {
                            pegIndex in
                            matchMarker(peg: pegIndex)
                        }
                        ClearCircle()
                    } else {
                        ForEach(
                            numberOfColumns..<numberOfColumns * 2,
                            id: \.self
                        ) {
                            pegIndex in
                            matchMarker(peg: pegIndex)
                        }
                    }
                }
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

    var body: some View {
        // random so that it show multiple configurations and not hardcoded
        let matches: [Match] = {
            let allMatches = Match.allCases
            var matchesForPegs: [Match] = []

            for _ in 0..<pegs {
                if let randomElement = allMatches.randomElement() {
                    matchesForPegs.append(randomElement)
                }
            }

            return matchesForPegs
        }()

        HStack {
            ForEach(0..<pegs, id: \.self) { _ in
                Circle().aspectRatio(1, contentMode: .fit)
            }
            MatchMarkers(matches: matches)
        }.padding()
    }
}

struct ClearCircle: View {
    var body: some View {
        Circle()
            .fill(Color.clear)
            .strokeBorder(
                Color.clear,
                lineWidth: 2
            )
            .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    VStack(alignment: .leading) {
        MatchMarkersPreview(pegs: 3)
        MatchMarkersPreview(pegs: 3)
        MatchMarkersPreview(pegs: 4)
        MatchMarkersPreview(pegs: 4)
        MatchMarkersPreview(pegs: 4)
        MatchMarkersPreview(pegs: 6)
        MatchMarkersPreview(pegs: 6)
        MatchMarkersPreview(pegs: 5)
        MatchMarkersPreview(pegs: 5)
    }
}
