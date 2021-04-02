//
//  ObservableType+Utils.swift
//  MVVM-Pratice
//
//  Created by Roger on 2021/4/2.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    
    func asDriverOnErrorJustComplete() -> Driver<Element> {
        return asDriver { error in
            return Driver.empty()
        }
    }
    
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
}
