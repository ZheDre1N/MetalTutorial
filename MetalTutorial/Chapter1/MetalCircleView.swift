//
//  MetalCircleView.swift
//  MetalTutorial
//
//  Created by Eugene Dudkin on 18.01.2024.
//

import SwiftUI

struct MetalCircleView: UIViewRepresentable {
    func makeUIView(context: Context) -> MetalCircle {
        MetalCircle()
    }
    
    func updateUIView(_ uiView: MetalCircle, context: Context) {
    }
}
