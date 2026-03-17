//
//  CodeBreakerView.swift
//  CodeBreakerWord
//
//  Created by CS193p Instructor on 3/31/25.
//

import SwiftUI

struct CodeBreakerWordView: View {
    // MARK: Data In
    @Environment(\.words) var words

    // MARK: Data Owned by Me
    @State private var game = CodeBreakerWord()
    @State private var selection: Int = 0
    @State private var showAlert = false
    @State private var details = ""

    // MARK: - Body

    var body: some View {
        VStack {
            view(for: game.masterCode)
            ScrollView {
                if !game.isOver {
                    view(for: game.guess)
                }
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    view(for: game.attempts[index])
                }
            }
            PegChooser { peg in
                game.setGuessPeg(peg, at: selection)
                selection = (selection + 1) % game.masterCode.pegs.count
            }
        }
        .padding()
        .onChange(of: words.count, initial: true) {
            if game.attempts.count == 0 {  // don’t disrupt a game in progress
                if !(words.count == 0) {  // no words (yet)
                    game = CodeBreakerWord(
                        word: words.random(length: 5) ?? "ERROR"
                    )
                }
            }
        }
        .alert(
            "Alert",
            isPresented: $showAlert,
            actions: {},
            message: {
                Text(details)
            }
        )
    }

    var guessButton: some View {
        Button("Guess") {
            withAnimation {
                // incomplete
                if game.guess.pegs.contains(where: \.isEmpty) {
                    showAlert = true
                    details = "You must pick all letters"
                    return
                }
                // non existent word case
                // already guessed case

                game.attemptGuess()
                selection = 0
            }
        }
        .font(.system(size: GuessButton.maximumFontSize))
        .minimumScaleFactor(GuessButton.scaleFactor)
    }

    func view(for code: Code) -> some View {
        HStack {
            CodeView(code: code, selection: $selection)
            Color.clear.aspectRatio(1, contentMode: .fit)
                .overlay {
                    if code.kind == .guess {
                        guessButton
                    }
                }
        }
    }

    struct GuessButton {
        static let minimumFontSize: CGFloat = 8
        static let maximumFontSize: CGFloat = 80
        static let scaleFactor = minimumFontSize / maximumFontSize
    }
}

extension Color {
    static func gray(_ brightness: CGFloat) -> Color {
        return Color(hue: 148 / 360, saturation: 0, brightness: brightness)
    }
}

#Preview {
    CodeBreakerWordView()
}
