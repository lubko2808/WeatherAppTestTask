//
//  NavigationBarAppearanceModifier.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import SwiftUI


extension View {
    
    @ViewBuilder
    func navigationBarAppearance(largeFontSize: CGFloat = 45, inlineFontSize: CGFloat = 20, isTransperentBackground: Bool = false, backgroundColor: UIColor = .quaternaryLabel) -> some View {
        self
            .modifier(navigationBarAppearanceModifier(largeFontSize: largeFontSize, inlineFontSize: inlineFontSize, isTransperentBackground: isTransperentBackground, backgroundColor: backgroundColor))
    }
    
}

private struct navigationBarAppearanceModifier: ViewModifier {
    
    let largeFontSize: CGFloat
    let inlineFontSize: CGFloat
    let isTransperentBackground: Bool
    let backgroundColor: UIColor
    
    func body(content: Content) -> some View {
        content
            .background(NavigationController(largeFontSize: largeFontSize, inlineFontSize: inlineFontSize, isTransperentBackground: isTransperentBackground, backgroundColor: backgroundColor))
    }
    
}

private struct NavigationController: UIViewRepresentable {
    
    let largeFontSize: CGFloat
    let inlineFontSize: CGFloat
    let isTransperentBackground: Bool
    let backgroundColor: UIColor
    
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            if let hostView = uiView.superview?.superview, let navigationController = hostView.navigationController {
                
                let appearance = UINavigationBarAppearance()
                let textColor = UIColor.white
                
                isTransperentBackground ? appearance.configureWithTransparentBackground() : appearance.configureWithOpaqueBackground()

                appearance.backgroundColor = backgroundColor
                appearance.largeTitleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: largeFontSize, weight: .semibold),
                    .foregroundColor: textColor,
                ]

                appearance.titleTextAttributes = [
                    .font: UIFont.systemFont(ofSize: inlineFontSize, weight: .semibold),
                    .foregroundColor: textColor,
                ]
                
                navigationController.navigationBar.standardAppearance = appearance
                navigationController.navigationBar.scrollEdgeAppearance = appearance
                navigationController.navigationBar.compactAppearance = appearance
                
            }
        }
    }
    
}
