//
//  UIStatusBarManager+Utils.swift
//  MVVM-Pratice
//
//  Created by Roger on 2021/4/2.
//

import Foundation
import UIKit

extension UIStatusBarManager {
    static var statusBarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        }
        else {
            return UIApplication.shared.statusBarFrame.height
        }
    }
}
