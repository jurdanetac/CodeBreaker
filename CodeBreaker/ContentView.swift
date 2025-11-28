//
//  ContentView.swift
//  CodeBreaker
//
//  Created by Juan Urdaneta on 27/11/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            pegs(colors: [.brown, .blue, .red, .yellow])
            pegs(colors: [.red, .blue, .orange, .yellow])
            pegs(colors: [.red, .blue, .red, .yellow])
            pegs(colors: [.red, .green, .red, .yellow])
        }.padding()
    }

    func pegs(colors: [Color]) -> some View {
        HStack {
            ForEach(colors.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 10)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(colors[index])
            }
            MatchMarkers(matches: [.exact, .inexact, .nomatch, .exact])
        }
    }
}

#Preview {
    ContentView()
}
