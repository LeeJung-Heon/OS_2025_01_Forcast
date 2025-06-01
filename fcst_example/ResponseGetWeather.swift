//
//  ResponseGetWeather.swift
//  fcst_example
//
//  Created by Hyeok Jung Kwon on 5/11/25.
//

import Foundation
import ObjectMapper

// ObjectMapper 를 사용하는 부분
// JSON 응답 전체를 감싸는 최상위 클래스
/*
 ObjectMapper 클래스 -> import 필요, 이거 말고 Codable로도 사용가능 Codable이 내장 기능이라 더 빠르긴 해!
 ObjectMapper 로 Mappable을 사용하는데
 Mappable 클래스에 있는 map 함수를 사용하면 상위 클래스부터 mapping 함수를 호출해서 하위 클래스까지 자동 매칭
 
 */
class ResponseGetWeather : Mappable{
    var response : Response? = nil // 받아온 JSON 파일에서 response라는 키를 받기 위한 값
    
    required init?(map: Map) {
    }
    
    // Mappable의 주요 기능 -> JSON에서 "response" 라는 키 값을 해당 클래스의 response에 매칭
    func mapping(map: Map) {
        self.response <- map["response"]// response라는 키가 가진 value를 ResponseGetWeather 객체의 response에 매핑 이후에 response의 mapping을 자동호출
    }
    
    // 하위 클래스 Response
    // 하위 클래스 Response에는 크게 Header랑 Body에 대한 정보가 담긴다
    class Response: Mappable {
        var header: Header?
        var body: Body?

        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            self.header <- map["header"] // 각각의 키가 가진 value를 객체의 필드에 매핑
            self.body <- map["body"]
        }
    }
    
    // 하위 클래스 Header
    class Header: Mappable {
        var resultCode, resultMsg: String?
        
        required init?(map: Map) {
            
        }
        func mapping(map: Map) {
            self.resultCode <- map["resultCode"]
            self.resultMsg <- map["resultMsg"]
        }
    }
    // 하위 클래스 Body
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

    // 하위 클래스 Items
    class Items: Mappable {
        var item: [Item]?
        required init?(map: Map) {
            
        }
        
        func mapping(map: Map) {
            self.item <- map["item"]
        }
    }

    // 하위 클래스 Item -> 각각의 Item들
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
