//
//  PegChooser.swift
//  CodeBreakerWord
//
//  Created by CS193p Instructor on 4/16/25.
//

import SwiftUI

struct PegChooser: View {
    // MARK: Data Owned by Me
    let choices: [Peg] = "QWERTYUIOPASDFGHJKLZXCVBNM".map { String($0) }

    // MARK: Data Out Function
    var onChoose: ((Peg) -> Void)?

    func keyboardRow(pegs: [Peg]) -> some View {
        return HStack {
            ForEach(pegs, id: \.self) { peg in
                Button {
                    onChoose?(peg)
                } label: {
                    Text(peg).font(
                        .system(size: KeyboardRow.fontSize)
                    )
                    .minimumScaleFactor(
                        KeyboardRow.minimumScaleFactor
                    )
                }
            }
        }
    }

    // MARK: - Body

    var body: some View {
        // MARK: Data Owned by Me
        let topRowChoices = Array(choices[0..<10])
        let middleRowChoices = Array(choices[10..<19])
        let bottomRowChoices = Array(choices[19..<26])

        VStack {
            keyboardRow(pegs: topRowChoices)
            keyboardRow(pegs: middleRowChoices)
            keyboardRow(pegs: bottomRowChoices)
        }
    }

    struct KeyboardRow {
        static let fontSize: CGFloat = 44
        static let minimumScaleFactor: CGFloat = 0.1
    }
}

#Preview {
    PegChooser {
        peg in
        print("chose \(peg)")
    }
    .padding()
}
