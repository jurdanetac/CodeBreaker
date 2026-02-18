//
//  CodeBreakerView.swift
//  CodeBreaker
//
//  Created by Juan Urdaneta on 27/11/25.
//

import SwiftUI

extension Color {
    static let allBuiltInColors: [Color] = [
        .red, .blue, .green, .yellow, .orange, .brown,
        .pink, .purple, .indigo, .teal, .mint, .cyan, .gray,
    ]

    static var allColorNames: [String] {
        return allBuiltInColors.compactMap { $0.name }
    }

    // failable initializer for Color which takes a color name and translates
    // it into one of Color's built-in static colors
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

    // Optional var called name which does the inverse
    var name: String? {
        switch self {
        case .red: return "red"
        case .blue: return "blue"
        case .green: return "green"
        case .yellow: return "yellow"
        case .orange: return "orange"
        case .brown: return "brown"
        case .pink: return "pink"
        case .purple: return "purple"
        case .indigo: return "indigo"
        case .teal: return "teal"
        case .mint: return "mint"
        case .cyan: return "cyan"
        case .gray: return "gray"
        default:
            return nil  // Returns nil for custom RGB or hex colors
        }
    }
}

enum Theme: CaseIterable {
    case colors
    case faces
    case vehicles
    case nature

    var name: String {
        switch self {
        case .colors: return "colors"
        case .faces: return "faces"
        case .vehicles: return "vehicles"
        case .nature: return "nature"
        }
    }

    var icon: String {
        switch self {
        case .colors: return "paintpalette"
        case .faces: return "face.smiling"
        case .vehicles: return "car"
        case .nature: return "tree"
        }
    }

    var pegs: [Peg] {
        switch self {
        case .colors: return Color.allColorNames
        case .faces: return ["😀", "🤪", "🥳", "😨", "😎", "🤔"]
        case .vehicles: return ["🚗", "🚲", "🛩", "⛵", "🚀", "🚁"]
        case .nature: return ["🌲", "🌻", "🌊", "🌋", "🍄", "🌙"]
        }
    }
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
    @State var game: CodeBreaker

    init(using theme: Theme = .colors) {
        self.game = CodeBreaker(from: theme.pegs)
    }

    // Error alert popup
    @State private var showAlert = false
    @State private var errorAlertTitle = "Error"
    @State private var errorAlertMessage = "Error attempting guess"

    var body: some View {
        VStack {
            // view(for: game.masterCode)
            ScrollView {
                view(for: game.guess)
                ForEach(game.attempts.indices.reversed(), id: \.self) { index in
                    view(for: game.attempts[index])
                }
            }
            restartGameButton.padding(.top)
        }.padding()
    }

    var restartGameButton: some View {
        Menu(
            content: {
                ForEach(Theme.allCases, id: \.self) { theme in
                    Button(
                        action: {
                            withAnimation {
                                game = CodeBreaker(from: theme.pegs)
                            }
                        },
                        label: {
                            Image(systemName: theme.icon)
                            Text(theme.name.capitalized)
                        }
                    )
                }
            },
            label: {
                VStack {
                    Image(systemName: "restart.circle")
                        .font(.title)
                    Text("Restart Game")
                        .font(.system(size: 20).bold())
                        .minimumScaleFactor(0.1)
                }
            }
        )
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
    CodeBreakerView()
    // CodeBreakerView(using: .faces)
}
