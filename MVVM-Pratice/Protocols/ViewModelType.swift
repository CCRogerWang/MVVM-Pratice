//
//  ViewModelType.swift
//  MVVM-Pratice
//
//  Created by Roger on 2021/4/2.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
