//
//  CustomNavigationViewStyle.swift
//  MVVM-Pratice
//
//  Created by Roger on 2021/4/2.
//

import Foundation
import UIKit

enum CustomNavigationViewStyle {
    case big
    case small
    
    var customNavigationViewFrameY: CGFloat {
        switch self {
        
        case .big:
            return CustomNavigationViewStyle.bigCustomNavigationViewY
        case .small:
            return CustomNavigationViewStyle.smallCustomNavigationViewY
        }
    }
    
    var NavigationHeight: CGFloat {
        switch self {
        
        case .big:
            return 200.0
        case .small:
            return 44.0
        }
    }
    
    var tableViewContentSizeY: CGFloat {
        return self.NavigationHeight * -1
    }
 
    static var threshold: CGFloat {
        return (CustomNavigationViewStyle.big.NavigationHeight - CustomNavigationViewStyle.small.NavigationHeight) / 2.0 * -1
    }
    
    static var bigCustomNavigationViewY: CGFloat {
        return 0.0
    }
    
    static var smallCustomNavigationViewY: CGFloat {
        return CustomNavigationViewStyle.small.NavigationHeight - CustomNavigationViewStyle.big.NavigationHeight
    }
    
    static var NavigationAndStatusBarHeight: CGFloat {
        return CustomNavigationViewStyle.big.NavigationHeight + UIStatusBarManager.statusBarHeight
    }
       

}
