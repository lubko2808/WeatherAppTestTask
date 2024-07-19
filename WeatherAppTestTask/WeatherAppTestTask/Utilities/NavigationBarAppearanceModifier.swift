//
//  NavigationBarAppearanceModifier.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import SwiftUI


extension View {
    
    @ViewBuilder
    func navigationBarAppearance(fontSize: CGFloat) -> some View {
        self
            .modifier(navigationBarAppearanceModifier(fontSize: fontSize))
    }
    
}

private struct navigationBarAppearanceModifier: ViewModifier {
    
    let fontSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(NavigationController(fontSize: fontSize))
    }
    
}


//struct NavigationBarAppearanceModifier: ViewModifier {
//    
//    init(fontSize: CGFloat) {
//        let appearance = UINavigationBarAppearance()
//        let textColor = UIColor.white
//        
//        appearance.configureWithTransparentBackground()
//        appearance.largeTitleTextAttributes = [
//            .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
//            .foregroundColor: textColor,
//        ]
//        
//        appearance.titleTextAttributes = [
//            .font: UIFont.systemFont(ofSize: fontSize, weight: .semibold),
//            .foregroundColor: textColor,
//        ]
//        
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().compactAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//    }
//    
//    func body(content: Content) -> some View {
//        content
//    }
//}

private struct NavigationController: UIViewRepresentable {
    
    let fontSize: CGFloat
    
    func makeUIView(context: Context) -> some UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            if let hostView = uiView.superview?.superview, let navigationController = hostView.navigationController {
    
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
                
                navigationController.navigationBar.standardAppearance = appearance
                navigationController.navigationBar.scrollEdgeAppearance = appearance
                navigationController.navigationBar.compactAppearance = appearance

            }
        }
    }
    
}

//extension View {
//    func navigationAppearance(fontSize: CGFloat) -> some View {
//        self.modifier(NavigationBarAppearanceModifier(fontSize: fontSize))
//    }
//}
