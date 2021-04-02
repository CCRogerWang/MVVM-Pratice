//
//  TaipeiZooAPIService.swift
//  MVVM-Pratice
//
//  Created by Roger on 2021/4/2.
//

import Foundation
import RxSwift
import RxCocoa

protocol TaipeiZooPlantAPIs {
    func getPlantList(offset: Int, limit: Int) -> Driver<PlantList>
}

extension TaipeiZooPlantAPIs {
    func getPlantList(offset: Int = 0, limit: Int = 20) -> Driver<PlantList> {
        return getPlantList(offset: offset, limit: limit)
    }
}

class TaipeiZooAPIService: TaipeiZooPlantAPIs {
    static let share = TaipeiZooAPIService()
    
    private var apiService = APIService()
    
    init() {
        
    }
    
    func getPlantList(offset: Int = 0, limit: Int = 20) -> Driver<PlantList> {
        let query = ["scope": "resourceAquire",
                     "rid": "f18de02f-b6c9-47c0-8cda-50efad621c14",
                     "offset": "\(offset)",
                     "limit": "\(limit)"]
        return apiService.get(returnType: TaipeiZooPlant.self, path: "", query: query, token: nil)
            .map { (result) -> PlantList in
                switch result {
                
                case .success(let element):
                    return element.result
                case .failure( _):
                    return PlantList(limit: 0, offset: 0, count: 0, sort: "", results: [])
                }
                
            }
            .asDriver { (error) -> Driver<PlantList> in
                return Driver.empty()
            }
    }
}
