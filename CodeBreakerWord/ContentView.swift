//
//  ContentView.swift
//  CodeBreakerWord
//
//  Created by Juan Urdaneta on 25/2/26.
//

import SwiftUI

struct ContentView: View {
    // MARK: Data In
    @Environment(\.words) var words

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
