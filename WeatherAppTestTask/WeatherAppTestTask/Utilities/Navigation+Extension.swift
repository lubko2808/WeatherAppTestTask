//
//  Navigation+Extension.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    func hideNavBarOnSwipe(_ isHidden: Bool) -> some View {
        self
            .modifier(NavBarModifier(isHidden: isHidden))
    }
    
}

private struct NavBarModifier: ViewModifier {
    
    var isHidden: Bool
    
    func body(content: Content) -> some View {
        content
            .background(NavigationControllerExtractor(isHidden: isHidden))
    }
    
}


private struct NavigationControllerExtractor: UIViewRepresentable {
    
    var isHidden: Bool
    
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if let hostView = uiView.superview?.superview, let parentController = hostView.parentController {
                parentController.navigationController?.hidesBarsOnSwipe = isHidden
            }
        }
    }
    
}



