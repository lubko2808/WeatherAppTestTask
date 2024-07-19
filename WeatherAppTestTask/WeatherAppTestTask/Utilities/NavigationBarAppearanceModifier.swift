//
//  NavigationBarAppearanceModifier.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import SwiftUI

struct NavigationBarAppearanceModifier: ViewModifier {
    
    init(fontSize: CGFloat) {
        let appearance = UINavigationBarAppearance()
        let textColor = UIColor.white
        
        appearance.configureWithTransparentBackground()
        appearance.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: textColor,
        ]
        
        appearance.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
            .foregroundColor: textColor,
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func navigationAppearance(fontSize: CGFloat) -> some View {
        self.modifier(NavigationBarAppearanceModifier(fontSize: fontSize))
    }
}
