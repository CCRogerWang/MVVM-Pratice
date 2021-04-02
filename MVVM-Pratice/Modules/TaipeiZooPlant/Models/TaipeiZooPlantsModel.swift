//
//  TaipeiZooPlantsModel.swift
//  MVVM-Pratice
//
//  Created by Roger on 2021/4/2.
//

import Foundation

struct TaipeiZooPlant: Codable {
    var result: PlantList
}

struct PlantList: Codable {
    var limit: Int
    var offset: Int
    var count: Int
    var sort: String
    var results: [Plant]
}

struct Plant: Codable {
    var F_Name_Ch: String
    var F_Location: String
    var F_Feature: String
    var F_Pic01_URL: String
    
}
