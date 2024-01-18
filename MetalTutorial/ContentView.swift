//
//  ContentView.swift
//  MetalTutorial
//
//  Created by Eugene Dudkin on 18.01.2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink {
                    MetalCircleView()
                } label: {
                    Text("MetalCircleView / Chapter 1")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
