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
        let halfMatchCount = Double(matches.count) / 2.0
        let columns = Int(halfMatchCount.rounded())

        HStack {
            ForEach(0..<columns, id: \.self) { index in
                VStack {
                    let _ = print(
                        "halfMatchCount \(halfMatchCount) colums \(columns) index \(index)"
                    )

                    matchMarker(peg: index)

                    if !(Int(halfMatchCount) == index) {
                        matchMarker(peg: index)
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
    let circleRadius = CGFloat(45)

    var body: some View {
        HStack {
            ForEach(0..<pegs, id: \.self) { _ in
                Circle().frame(width: circleRadius, height: 90)
            }

            Spacer()

            let matches = {
                let allMatches = Match.allCases
                var matchesForPegs: [Match] = []

                for _ in 0..<pegs {
                    if let randomElement = allMatches.randomElement() {
                        matchesForPegs.append(randomElement)
                    }
                }

                return matchesForPegs
            }()

            MatchMarkers(matches: matches).frame(
                width: circleRadius,
                height: circleRadius
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
