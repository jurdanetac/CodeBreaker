//
//  MatchMarkers.swift
//  CodeBreaker
//
//  Created by Juan Urdaneta on 28/11/25.
//

import SwiftUI

enum Match {
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

#Preview {
    MatchMarkers(matches: [.exact, .inexact, .nomatch])
}
