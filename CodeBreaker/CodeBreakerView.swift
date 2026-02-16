//
//  CodeBreakerView.swift
//  CodeBreaker
//
//  Created by Juan Urdaneta on 27/11/25.
//

import SwiftUI

// peg themes available to use
enum Theme {
    case emojis(theme: String)
    case colors
}

// a default set of earth tones to use as fallback
let defaultPegChoices = ["red", "blue", "green", "yellow"]
// ["brown", "yellow", "orange", "black"]

let supportedColors: [Peg: Color] = [
    "red": .red, "blue": .blue, "green": .green,
    "yellow": .yellow, "brown": .brown, "orange": .orange,
        // "pink": .orange, "purple": .purple, "black": .black,
]

let supportedEmojis: [String: [String]] = [
    "faces": ["😀", "🤪", "🥳", "😨", "😎", "🤔"],
    "vehicles": ["🚗", "🚲", "🛩", "⛵", "🚀", "🚁"],
    "nature": ["🌲", "🌻", "🌊", "🌋", "🍄", "🌙"],
]

func getBackground(for peg: Peg) -> Color {
    // case color
    if supportedColors.keys.contains(peg) {
        let color = supportedColors.first { $0.key == peg }!.value
        return color
    }

    // case missing and emoji
    return Color.clear
}

func getForeground(for peg: Peg) -> Text {
    // case emoji
    if peg != Code.missing && !supportedColors.keys.contains(peg) {
        return Text(peg)
    }

    // case missing and color
    return Text("")
}

struct CodeBreakerView: View {
    let pegChoices: [Peg]
    @State var game: CodeBreaker
    @State var theme: Theme

    init(pegChoices: [Peg] = defaultPegChoices) {
        var pegChoicesToUse = pegChoices

        // check if we're passed either colors or emojis
        let areAllPegChoicesColors: Bool = pegChoices.allSatisfy { pegChoice in
            supportedColors.keys.contains { $0 == pegChoice }
        }

        if areAllPegChoicesColors {
            self.theme = .colors
        } else {
            // check there's a theme that contains all these pegs
            let themeSet: [String: [Peg]] = supportedEmojis.filter { themeSet in
                themeSet.value.contains(pegChoices)
            }

            if themeSet.isEmpty {
                // use a default when mixed peg choices of themes are passed
                self.theme = .colors
                pegChoicesToUse = defaultPegChoices
            } else {
                // emojis (strings)
                self.theme = .emojis(theme: themeSet.first!.key)
            }
        }

        self.pegChoices = pegChoicesToUse
        game = CodeBreaker(pegChoices: pegChoicesToUse)
    }

    @State private var showAlert = false
    @State private var errorAlertTitle = "Error"
    @State private var errorAlertMessage = "Error attempting guess"

    var body: some View {
        VStack {
            view(for: game.masterCode)
            ScrollView {
                view(for: game.guess)
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    view(for: game.attempts[index])
                }
            }
            restartGameButton
        }.padding()
    }

    var restartGameButton: some View {
        Button("Restart Game") {
            // choose a random peg count in allowed range
            let randomPegCount = Int.random(in: minPegs...maxPegs)
            // array that holds the pegs to pick from
            var pegsToChooseFrom: [Peg]

            switch self.theme {
            case .emojis(let currentTheme):
                pegsToChooseFrom = supportedEmojis[currentTheme]!
            case .colors:
                pegsToChooseFrom = Array(supportedColors.keys)
            }

            // array that will hold the selected pegs
            var randomPegs: [Peg] = []

            // populate random pegs
            for _ in 0..<randomPegCount {
                // mix pegs
                pegsToChooseFrom = pegsToChooseFrom.shuffled()
                // take a random
                let randomPeg = pegsToChooseFrom.popLast()!
                // append to array
                randomPegs.append(randomPeg)
            }

            withAnimation {
                game = CodeBreaker(pegChoices: randomPegs)
            }
        }
    }

    var guessButton: some View {
        Button("Guess") {
            withAnimation {
                switch game.attemptGuess() {
                case .duplicated:
                    showAlert = true
                    errorAlertMessage = "Guess has been tried already"
                case .missing:
                    showAlert = true
                    errorAlertMessage = "You must choose all pegs"
                case .successful:
                    break
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(errorAlertTitle),
                message: Text(errorAlertMessage)
            )
        }
        .font(.system(size: 80))
        .minimumScaleFactor(0.1)
    }

    func view(for code: Code) -> some View {
        HStack {
            ForEach(code.pegs.indices, id: \.self) { index in
                let peg = code.pegs[index]

                RoundedRectangle(cornerRadius: 10)
                    .overlay {
                        if peg == Code.missing {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(
                        ({
                            let pegBackground = getBackground(for: peg)
                            return pegBackground
                        })()
                    )
                    .overlay {
                        ({
                            let pegForeground = getForeground(for: peg)
                            return
                                pegForeground
                                .font(.system(size: 120))
                                .minimumScaleFactor(9 / 120)
                        })()
                    }
                    .onTapGesture {
                        if code.kind == .guess {
                            game.changeGuessPeg(at: index)
                        }
                    }
            }
            MatchMarkers(matches: code.matches).overlay {
                if code.kind == .guess {
                    guessButton
                }
            }
        }
    }
}

#Preview {
    CodeBreakerView(pegChoices: ["red", "blue", "green", "yellow"])
    CodeBreakerView(pegChoices: ["😀", "🤪", "🥳", "😨"])
    // CodeBreakerView(pegChoices: ["🚗", "🚲", "🛩", "⛵"])
    // CodeBreakerView()
}
