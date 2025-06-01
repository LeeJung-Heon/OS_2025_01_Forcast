//
//  ViewController.swift
//  fcst_example
//
//  Created by Hyeok Jung Kwon on 5/11/25.
//

import Foundation
import UIKit
import Alamofire
import CoreLocation
import ObjectMapper

class WeatherBasicViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var gpsLbl: UILabel!
    
    @IBOutlet weak var girdLbl: UILabel!
    
    @IBOutlet weak var valueLbl: UILabel!
    
    @IBOutlet weak var pcpLbl: UILabel!
    @IBOutlet weak var popLbl: UILabel!
    @IBOutlet weak var ptyLbl: UILabel!
    @IBOutlet weak var rehLbl: UILabel!
    @IBOutlet weak var skyLbl: UILabel!
    @IBOutlet weak var snoLbl: UILabel!
    @IBOutlet weak var tmnLbl: UILabel!
    @IBOutlet weak var tmpLbl: UILabel!
    @IBOutlet weak var tmxLbl: UILabel!
    @IBOutlet weak var uuuLbl: UILabel!
    @IBOutlet weak var vecLbl: UILabel!
    @IBOutlet weak var vvvLbl: UILabel!
    @IBOutlet weak var wavLbl: UILabel!
    @IBOutlet weak var wsdLbl: UILabel!
    
    let apiKey = "2zW746AAjo7EZoz+fMGDR+SAFlZ0GZYElOs3oJ35izgQtYuGY3uN4h5Rs2KAX9FlJbGH9ogMa6xqvFfp/XC1yQ=="
    let apiUrl = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?"
    
    var mapManager : CLLocationManager!
    
    var totalURL = ""
    var nowTimeString = ""// 실제시간
    var baseTimeString = ""// 측정 발표 시간
    var fstTimeString = ""//예상 측정 시간
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gpsLbl.text = "위도 , 경도 : \(getGpsLocation())"
        girdLbl.text = "격자  : \(convertGPStoGRID(lat_X: getGpsLocation().0, lng_Y: getGpsLocation().1))"
       
        getThreeTimesByString(getDate: Date.now)
        
        totalURL = getWeatherApiUrl(time: Date.now, grid: convertGPStoGRID(lat_X: getGpsLocation().0, lng_Y: getGpsLocation().1))
        weatherAlamofire()
    }
    
    @IBAction func clickButton(_ sender: Any) {
        weatherAlamofire()
    }
    func weatherAlamofire(){
        print(totalURL)
        AF.request(totalURL).responseData{ response in
            switch response.result {
                case .success(let data):
                    do {
                        print(response.data)
                        let asJSON = try JSONSerialization.jsonObject(with: data)
                        
                        let sample = Mapper<ResponseGetWeather>().map(JSONObject: asJSON)
                        if(sample != nil){
                           
                            self.setAllInfo(item: self.filterTodayWeather(allItems: sample!.response!.body!.items!.item)!)
                        }
                       
                    } catch {
                        print("Error while decoding response: \(error) from: \(String(data: data, encoding: .utf8))")
                    }
                case .failure(let error):
                    print("Error get Value from Server")
                    break
                    // Handle as previously error
                }
        }
    }
    func filterTodayWeather(allItems : [ResponseGetWeather.Item]?) -> [ResponseGetWeather.Item]? {
        let baseDate = self.getIndexString(text: self.baseTimeString, startIndex: 0, endIndex: 8)
        let baseTime = self.getIndexString(text: self.baseTimeString, startIndex: 8, endIndex: 12)
        let fstDate = self.getIndexString(text: self.fstTimeString, startIndex: 0, endIndex: 8)
        let fstTime = self.getIndexString(text: self.fstTimeString, startIndex: 8, endIndex: 12)
        
        if(allItems == nil){
            return nil
        }
        var resultArray: [ResponseGetWeather.Item] = []
        for i in allItems! {
            if(i.baseDate == baseDate && i.baseTime == baseTime && i.fcstDate == fstDate && i.fcstTime == fstTime ){
                resultArray.append(i)
            }
        }
        return resultArray
    }
  
    func setAllInfo(item : [ResponseGetWeather.Item]){
        for i in item {
            if(i.category == "PCP"){
                pcpLbl.text =  "강수량(PCP) : \(i.fcstValue ?? ""))"
            }
            if(i.category == "POP"){
                popLbl.text =  "강수확률(POP) : \(i.fcstValue ?? ""))"
            }
            if(i.category == "PTY"){
                ptyLbl.text =  "강수형태(PTY) : \(i.fcstValue ?? ""))"
            }
            if(i.category == "REH"){
                rehLbl.text =  "습도(REH) : \(i.fcstValue ?? ""))"
            }
            if(i.category == "SKY"){
                skyLbl.text =  "구름양(SKY) : \(i.fcstValue ?? ""))"
            }
            if(i.category == "SNO"){
                snoLbl.text =  "적설량(SNO) : \(i.fcstValue ?? ""))"
            }
            if(i.category == "TMN"){
                tmnLbl.text =  "아침 최저기온(TMN) : \(i.fcstValue ?? ""))"
            }
            if(i.category == "TMP"){
                tmpLbl.text =  "기온(TMP) : \(i.fcstValue ?? ""))"
            }
            if(i.category == "TMX"){
                tmxLbl.text =  "낮 최고기온(TMX) : \(i.fcstValue ?? ""))"
            }
            if(i.category == "UUU"){
                uuuLbl.text =  "동서바람성분(UUU) : \(i.fcstValue ?? ""))"
            }
            if(i.category == "VEC"){
                vecLbl.text =  "풍향(VEC) : \(i.fcstValue ?? ""))"
            }
            if(i.category == "VVV"){
                vvvLbl.text =  "남북바람성분(VVV) : \(i.fcstValue ?? ""))"
            }
            if(i.category == "WAV"){
                wavLbl.text =  "파고(WAV) : \(i.fcstValue ?? ""))"
            }
            if(i.category == "WSD"){
                wsdLbl.text =  "풍속(WSD) : \(i.fcstValue ?? ""))"
            }
        }
    }
    //MARK: - 여기까지는 기본 수식
 
    
    func getWeatherApiUrl(time : Date , grid : (Int,Int))-> String{
        var weatherUrl = apiUrl + "serviceKey=" + apiKey
        weatherUrl += "&pageNo=1&numOfRows=1000&dataType=JSON&base_date="
        weatherUrl += getCheckDate()
        weatherUrl += "&base_time=\(getCheckTime())&nx=\(grid.0)&ny=\(grid.1)"
        return weatherUrl
    }
    func getCheckTime() -> String {
        return getIndexString(text: baseTimeString, startIndex: 8, endIndex: 12)
    }
    func getCheckDate() -> String {
        return getIndexString(text: baseTimeString, startIndex: 0, endIndex: 8)
    }
    func getThreeTimesByString(getDate : Date){
        let dateFormatter = DateFormatter()
        // Set Date Format
        dateFormatter.dateFormat = "YYYYMMddHHmm"
        nowTimeString = dateFormatter.string(from: getDate)
        fstTimeString = getIndexString(text: nowTimeString, startIndex: 0, endIndex: 10) + "00"
        baseTimeString = getBaseTimeString()
    }
    
    func getIndexString(text : String,startIndex : Int , endIndex : Int) -> String {
        let startIndex = text.index(text.startIndex, offsetBy: startIndex)// 사용자지정 시작인덱스
        let endIndex = text.index(text.startIndex, offsetBy: endIndex)// 사용자지정 끝인덱스
        return String(text[startIndex ..< endIndex])
    }
    
    func getBaseTimeString() -> String {
        //ex) 20220517  -> 202205162300, 202205170200, 202205170500
        let nowDateString = getIndexString(text: nowTimeString, startIndex: 0, endIndex: 8)
        let upTimeLine = ["2300","0200","0500","0800","1100","1400","1700","2000"]
        let yesterDayInt = Int(nowDateString)! - 1
        let yesterDayString = String(yesterDayInt)
        var timeArray : [Int] = []
        for i in 0..<upTimeLine.count {
            var newTimeElemt : String
            if(i == 0){
                newTimeElemt = yesterDayString + upTimeLine[i]
            }else{
                newTimeElemt = nowDateString + upTimeLine[i]
            }
            timeArray.append(Int(newTimeElemt)!)
        }
        let nowTimeInt = Int(nowTimeString)!
        for i in 0..<timeArray.count {
            if(timeArray[i] > nowTimeInt){
                if(i > 0){ // 시간차이가 얼마 안날때 i> 0
                    if(nowTimeInt - timeArray[i-1] < 100){
                        return String( timeArray[i-2] )
                    }else{
                        return String( timeArray[i-1] )
                    }
                }else{
                    return String( timeArray[i-1] )
                }
            }
        }
        return String( nowTimeInt )
    }
    
 
    func getGpsLocation() -> (Double,Double){
        mapManager = CLLocationManager()
        mapManager.delegate = self
        mapManager.requestWhenInUseAuthorization()
        mapManager.desiredAccuracy = kCLLocationAccuracyBest
        mapManager.startUpdatingLocation()
        let coor = mapManager.location?.coordinate
        var lat = coor?.latitude
        var long = coor?.longitude
        return (lat,long) as! (Double, Double)
    }
    
    func convertGPStoGRID( lat_X: Double, lng_Y: Double) -> (Int,Int) {
        let RE = 6371.00877 // 지구 반경(km)
        let GRID = 5.0 // 격자 간격(km)
        let SLAT1 = 30.0 // 투영 위도1(degree)
        let SLAT2 = 60.0 // 투영 위도2(degree)
        let OLON = 126.0 // 기준점 경도(degree)
        let OLAT = 38.0 // 기준점 위도(degree)
        let XO:Double = 43 // 기준점 X좌표(GRID)
        let YO:Double = 136 // 기1준점 Y좌표(GRID)
        
        let DEGRAD = Double.pi / 180.0
    
        let re = RE / GRID
        let slat1 = SLAT1 * DEGRAD
        let slat2 = SLAT2 * DEGRAD
        let olon = OLON * DEGRAD
        let olat = OLAT * DEGRAD
        
        var sn = tan(Double.pi * 0.25 + slat2 * 0.5) / tan(Double.pi * 0.25 + slat1 * 0.5)
        sn = log(cos(slat1) / cos(slat2)) / log(sn)
        var sf = tan(Double.pi * 0.25 + slat1 * 0.5)
        sf = pow(sf, sn) * cos(slat1) / sn
        var ro = tan(Double.pi * 0.25 + olat * 0.5)
        ro = re * sf / pow(ro, sn)

        var ra = tan(Double.pi * 0.25 + (lat_X) * DEGRAD * 0.5)
        ra = re * sf / pow(ra, sn)
        var theta = lng_Y * DEGRAD - olon
        if theta > Double.pi {
            theta -= 2.0 * Double.pi
        }
        if theta < -Double.pi {
            theta += 2.0 * Double.pi
        }
        
        theta *= sn
        let x = Int(floor(ra * sin(theta) + XO + 0.5))
        let y = Int(floor(ro - ra * cos(theta) + YO + 0.5))
        return (x,y)
    }
}
