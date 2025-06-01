//
//  ResponseGetDust.swift
//  fcst_example
//
//  Created by Hyeok Jung Kwon on 5/28/25.
//

import Foundation
import ObjectMapper

class ResponseGetDust: Mappable {
    var response: Response?

    required init?(map: Map) {}
    func mapping(map: Map) {
        response <- map["response"]
    }

    class Response: Mappable {
        var header: Header?
        var body: Body?

        required init?(map: Map) {}
        func mapping(map: Map) {
            header <- map["header"]
            body <- map["body"]
        }
    }

    class Header: Mappable {
        var resultCode: String?
        var resultMsg: String?

        required init?(map: Map) {}
        func mapping(map: Map) {
            resultCode <- map["resultCode"]
            resultMsg <- map["resultMsg"]
        }
    }

    class Body: Mappable {
        var totalCount: Int?
        var items: [Item]? // ✅ 바로 배열로!

        required init?(map: Map) {}
        func mapping(map: Map) {
            totalCount <- map["totalCount"]
            items <- map["items"]
        }
    }

    class Item: Mappable {
        var stationName: String?
        var pm10Value: String?
        var pm25Value: String?
        var dataTime: String?

        required init?(map: Map) {}
        func mapping(map: Map) {
            stationName <- map["stationName"]
            pm10Value <- map["pm10Value"]
            pm25Value <- map["pm25Value"]
            dataTime <- map["dataTime"]
        }
    }
}
