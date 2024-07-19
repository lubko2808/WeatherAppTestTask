//
//  UIView+Extension.swift
//  WeatherAppTestTask
//
//  Created by Lubomyr Chorniak on 19.07.2024.
//

import UIKit

extension UIView {
    
    var navigationController: UINavigationController?  {
        sequence(first: self) { view in
            view.next
        }
        .first { responder in
            return responder is UINavigationController
        } as? UINavigationController
    }
    
}
