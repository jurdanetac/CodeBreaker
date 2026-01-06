//
//  CodeBreakerView.swift
//  CodeBreaker
//
//  Created by Juan Urdaneta on 27/11/25.
//

import SwiftUI

func createButton(
    label: String,
    iconSystemName: String,
    action: @escaping () -> Void
)
    -> some View
{
    Button(
        action: {
            withAnimation {
                action()
            }
        },
        label: {
            VStack {
                Image(systemName: iconSystemName).imageScale(.large)
                Text(label).font(.headline)
            }
        }
    )
}

struct CodeBreakerView: View {
    @State var game = CodeBreaker(pegChoices: [
        .brown, .yellow, .orange, .black, .red,
    ])
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
            HStack {
                restartGameButton
                Spacer()
                colorsVariantButton
                Spacer()
                emojiVariantButton
            }
        }.padding()
    }

    var restartGameButton: some View {
        createButton(
            label: "Restart Game",
            iconSystemName: "restart.circle"
        ) {
            withAnimation {
                game.restartGame()
            }
        }
    }

    var emojiVariantButton: some View {
        createButton(
            label: "Emoji theme",
            iconSystemName: "face.smiling",
        ) {
            let _ = print("emoji variant button pressed")
        }
    }

    var colorsVariantButton: some View {
        createButton(
            label: "Colors theme",
            iconSystemName: "paintpalette",
        ) {
            let _ = print("colors variant button pressed")
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
                RoundedRectangle(cornerRadius: 10)
                    .overlay {
                        if code.pegs[index] == Code.missing {
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.gray)
                        }
                    }
                    .contentShape(Rectangle())
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(code.pegs[index])
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
}
