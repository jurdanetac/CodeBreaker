//
//  CodeBreakerView.swift
//  CodeBreaker
//
//  Created by Juan Urdaneta on 27/11/25.
//

import SwiftUI

extension Color {
    // all supported colors
    static let allColorsNames: [String] = [
        "red",
        "blue",
        "green",
        "yellow",
        "brown",
        "orange",
        "pink",
        "purple",
        "indigo",
        "teal",
        "mint",
        "cyan",
        "gray",
        "grey",
    ]

    init?(name: String) {
        switch name.lowercased().trimmingCharacters(in: .whitespaces) {
        case "red": self = .red
        case "blue": self = .blue
        case "green": self = .green
        case "yellow": self = .yellow
        case "orange": self = .orange
        case "brown": self = .brown
        case "pink": self = .pink
        case "purple": self = .purple
        case "indigo": self = .indigo
        case "teal": self = .teal
        case "mint": self = .mint
        case "cyan": self = .cyan
        case "gray", "grey": self = .gray
        default:
            return nil  // This makes it failable
        }
    }
}

// peg themes available to use
enum Theme {
    // all supported emojis
    static let supportedEmojis: [String: [String]] = [
        "faces": ["😀", "🤪", "🥳", "😨", "😎", "🤔"],
        "vehicles": ["🚗", "🚲", "🛩", "⛵", "🚀", "🚁"],
        "nature": ["🌲", "🌻", "🌊", "🌋", "🍄", "🌙"],
    ]

    // all supported themes
    static var allPossibleThemes = ["colors"] + Array(supportedEmojis.keys)

    // a default set of pegs to use as fallback
    static let defaultPegChoices = ["red", "blue", "green", "yellow"]

    case emojis(theme: String)
    case colors
}

func getBackground(for peg: Peg) -> Color {
    // case color ? : case missing and emoji
    Color(name: peg) != nil ? Color(name: peg)! : .clear
}

func getForeground(for peg: Peg) -> Text {
    // case emoji
    if peg != Code.missing && (Color(name: peg) == nil) {
        return Text(peg)
    }

    // case missing and color
    return Text("")
}

struct CodeBreakerView: View {
    let pegChoices: [Peg]
    @State var game: CodeBreaker
    @State var theme: Theme

    init(pegChoices: [Peg] = Theme.defaultPegChoices) {
        var pegChoicesToUse = pegChoices

        // check if we're passed either colors or emojis
        let areAllPegChoicesColors: Bool = pegChoices.allSatisfy { pegChoice in
            Color(name: pegChoice) != nil
        }

        if areAllPegChoicesColors {
            self.theme = .colors
        } else {
            // check there's a theme that contains all these pegs
            let themeSet: [String: [Peg]] = Theme.supportedEmojis.filter {
                themeSet in
                themeSet.value.contains(pegChoices)
            }

            if themeSet.isEmpty {
                // use a default when mixed peg choices of themes are passed
                self.theme = .colors
                pegChoicesToUse = Theme.defaultPegChoices
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

            // pick a random theme
            if let randomTheme = Theme.allPossibleThemes.randomElement() {
                if randomTheme == "colors" {
                    self.theme = .colors
                } else {
                    self.theme = .emojis(theme: randomTheme)
                }
            }

            switch self.theme {
            case .emojis(let currentTheme):
                pegsToChooseFrom = Theme.supportedEmojis[currentTheme]!
            case .colors:
                pegsToChooseFrom = Color.allColorsNames
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
    // CodeBreakerView(pegChoices: ["😀", "🤪", "🥳", "😨"])
    // CodeBreakerView(pegChoices: ["🚗", "🚲", "🛩", "⛵"])
    // CodeBreakerView()
}
