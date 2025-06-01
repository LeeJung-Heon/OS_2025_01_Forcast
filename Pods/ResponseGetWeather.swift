//
//  ResponseGetWeather.swift
//  fcst_example
//
//  Created by Hyeok Jung Kwon on 5/11/25.
//

import Foundation
import ObjectMapper

//MARK: getWeather - 날씨//ResponseGetFarmVilliage
class ResponseGetWeather : Mappable{
    var response : Response? = nil
    
    required init?(map: Map) {
    }
    func mapping(map: Map) {
        self.response <- map["response"]
    }
    
    class Response: Mappable {
        var header: Header?
        var body: Body?

        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            self.header <- map["header"]
            self.body <- map["body"]
        }
    }
    //MARK: - head
    class Header: Mappable {
        var resultCode, resultMsg: String?
        required init?(map: Map) {
            
        }
        func mapping(map: Map) {
            self.resultCode <- map["resultCode"]
            self.resultMsg <- map["resultMsg"]
        }
    }
    // MARK: - Body
    class Body: Mappable {
        var dataType: String?
        var items: Items?
        var pageNo, numOfRows, totalCount: Int?

        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            self.dataType <- map["dataType"]
            self.items <- map["items"]
            self.pageNo <- map["pageNo"]
            self.numOfRows <- map["numOfRows"]
            self.totalCount <- map["totalCount"]
        }
    }

    // MARK: - Items
    class Items: Mappable {
        var item: [Item]?
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            self.item <- map["item"]
        }
    }

    // MARK: - Item
    class Item: Mappable {
        var baseDate, baseTime: String?
        var category: String?
        var fcstDate, fcstTime, fcstValue: String?
        var nx, ny: Int?

        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            self.baseDate <- map["baseDate"]
            self.baseTime <- map["baseTime"]
            self.category <- map["category"]
            self.fcstDate <- map["fcstDate"]
            self.fcstTime <- map["fcstTime"]
            self.fcstValue <- map["fcstValue"]
            self.nx <- map["nx"]
            self.ny <- map["ny"]
        }
    }
}
