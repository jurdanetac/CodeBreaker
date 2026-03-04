//
//  PegView.swift
//  CodeBreaker
//
//  Created by CS193p Instructor on 4/16/25.
//

import SwiftUI

struct PegView: View {
    // MARK: Data In
    let peg: Peg

    // MARK: - Body

    let pegShape = Circle()

    var body: some View {
        pegShape
            .stroke()
            .overlay { Text(peg) }
    }
}

#Preview {
    PegView(peg: "A")
        .padding()
}
