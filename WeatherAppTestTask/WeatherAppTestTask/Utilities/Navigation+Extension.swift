//
//  Navigation+Extension.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func hideNavBarOnSwipe() -> some View {
        self
            .modifier(NavBarModifier())
    }
    
}

private struct NavBarModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .background(NavigationControllerExtractor())
    }
    
}


private struct NavigationControllerExtractor: UIViewRepresentable {

    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if let hostView = uiView.superview?.superview, let parentController = hostView.parentController {
                parentController.navigationController?.hidesBarsOnSwipe = true
            }
        }
    }
    
}



