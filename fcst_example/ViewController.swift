import Foundation
import UIKit
import Alamofire
import CoreLocation
import ObjectMapper
import UserNotifications

class WeatherBasicViewController: UIViewController, CLLocationManagerDelegate {
    // MARK: - IBOutlets
    @IBOutlet weak var gpsLbl: UILabel!
    @IBOutlet weak var gridLbl: UILabel!
    // MARK: - Hour later label
    @IBOutlet weak var one_hourLater: UILabel!          // 1시간 이후
    @IBOutlet weak var two_hourLater: UILabel!          // 1시간 이후
    @IBOutlet weak var three_hourLater: UILabel!          // 1시간 이후
    @IBOutlet weak var four_hourLater: UILabel!          // 1시간 이후
    @IBOutlet weak var five_hourLater: UILabel!          // 1시간 이후
    // MARK: - +1 hour
    @IBOutlet weak var main_tempLbl: UILabel!          // 현재기온
    @IBOutlet weak var one_tempLbl: UILabel!          // 기온 (T1H)
    @IBOutlet weak var one_precipitationLbl: UILabel! // 강수형태 (PTY)
    @IBOutlet weak var one_windSpeedLbl: UILabel!     // 풍속 (WSD)
    @IBOutlet weak var one_skyLbl: UILabel!           // 하늘상태 (SKY)
    
    // MARK: - +2 hour
    @IBOutlet weak var two_tempLbl: UILabel!          // 기온 (T1H)
    @IBOutlet weak var two_precipitationLbl: UILabel! // 강수형태 (PTY)
    @IBOutlet weak var two_windSpeedLbl: UILabel!     // 풍속 (WSD)
    @IBOutlet weak var two_skyLbl: UILabel!           // 하늘상태 (SKY)
    
    // MARK: - +3 hour
    @IBOutlet weak var three_tempLbl: UILabel!          // 기온 (T1H)
    @IBOutlet weak var three_precipitationLbl: UILabel! // 강수형태 (PTY)
    @IBOutlet weak var three_windSpeedLbl: UILabel!     // 풍속 (WSD)
    @IBOutlet weak var three_skyLbl: UILabel!           // 하늘상태 (SKY)
    
    // MARK: - +4 hour
    @IBOutlet weak var four_tempLbl: UILabel!          // 기온 (T1H)
    @IBOutlet weak var four_precipitationLbl: UILabel! // 강수형태 (PTY)
    @IBOutlet weak var four_windSpeedLbl: UILabel!     // 풍속 (WSD)
    @IBOutlet weak var four_skyLbl: UILabel!           // 하늘상태 (SKY)
    
    // MARK: - +5 hour
    @IBOutlet weak var five_tempLbl: UILabel!          // 기온 (T1H)
    @IBOutlet weak var five_precipitationLbl: UILabel! // 강수형태 (PTY)
    @IBOutlet weak var five_windSpeedLbl: UILabel!     // 풍속 (WSD)
    @IBOutlet weak var five_skyLbl: UILabel!           // 하늘상태 (SKY)
    
    // MARK: - Weather Icons
    @IBOutlet weak var one_weatherIcon: UIImageView!
    @IBOutlet weak var two_weatherIcon: UIImageView!
    @IBOutlet weak var three_weatherIcon: UIImageView!
    @IBOutlet weak var four_weatherIcon: UIImageView!
    @IBOutlet weak var five_weatherIcon: UIImageView!
    
    // MARK: - 실제 주소 라벨
    @IBOutlet weak var locationLabel: UILabel!

    
    // MARK: UI for TMN, TMX
    @IBOutlet weak var tminLbl: UILabel!          // 최저기온 (TMN)
    @IBOutlet weak var tmaxLbl: UILabel!          // 최고기온 (TMX)
    @IBOutlet weak var tmaxMinLbl: UILabel!       // 최고, 최저기온 동시에
    
    // MARK: 미세먼지 API 관련키
    //@IBOutlet weak var pm10Value: UILabel!          // PM10 농도
    //@IBOutlet weak var pm25Value: UILabel!          // PM2.5 농도
    
    // MARK: 미세먼지 출력 리벨
    @IBOutlet weak var pm10Label: UILabel!
    @IBOutlet weak var pm25Label: UILabel!
    
    // MARK: - API Endpoints & Key
    private let apiKey = "2zW746AAjo7EZoz%2BfMGDR%2BSAFlZ0GZYElOs3oJ35izgQtYuGY3uN4h5Rs2KAX9FlJbGH9ogMa6xqvFfp%2FXC1yQ%3D%3D"
    private let ultraSrtFcstUrl = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst?"
    private let vilageFcstUrl   = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getVilageFcst?"
    
    private let fineDustKey   = "2zW746AAjo7EZoz%2BfMGDR%2BSAFlZ0GZYElOs3oJ35izgQtYuGY3uN4h5Rs2KAX9FlJbGH9ogMa6xqvFfp%2FXC1yQ%3D%3D"
    private let fineDustURL   = "https://apis.data.go.kr/B552584/ArpltnInforInqireSvc/getCtprvnRItmMesureDnsty?"
    
    // MARK: - Properties
    private var locationManager: CLLocationManager!
    
    // 사용자의 현재 GPS 위치를 받아오는 변수, 옵셔널로 선언했고, 안전하게 꺼내려면 guard let 사용
    // CLLocation~ 구조체는 멤버로 위도, 경도를 갖고 있음
    /*
     swift에서 구조체와 클래스 사용
     - 클래스는 생성자 사용할 때 괄호 필수
     - 구조체도 괄호 써야함 하지만 선언만 할 땐 필요없다.
     - 그리고 선언 시에 옵셔널 쓰면 자동으로 nil로 초기화
     */
    private var lastCoordinate: CLLocationCoordinate2D? // 위도 경도를 멤버로 갖는 구조체
    private var nowTimeString = ""
    private var baseTimeStringForVilage = "" // 당일에 한번만 받아오는 API
    private var baseTimeStringForUltraSrt = "" // 당일에 시간 간격으로 받아오는 API
    private var fstTimeString  = ""
    private var ultraTimer: Timer?
    private var dailyTimer: Timer?
    
    // gif를 넣기위한 이미지 배열
    private var weatherGifImageViews: [UIImageView] = []
    
    // 미세먼지 api에 전달할 시도 이름을 위한 변수
    private var currentSidoName : String? = ""
    
    // 위젯을 추가하기 위해서 AppGroup에서 공유할 값 추가
    var sharedDefaults = UserDefaults(suiteName: "group.com.hyeok.weather")
    
    // MARK: - gif 이미지 뷰
    private let gifImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
        
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("✅ viewDidLoad 진입")
        setupLocationManager()
        
        // 사용하지 않을 라벨들 임시적으로 제거
        gpsLbl.isHidden=true
        gridLbl.isHidden=true
        tmaxLbl.isHidden=true
        tminLbl.isHidden=true
        one_precipitationLbl.isHidden=true
        one_skyLbl.isHidden=true
        two_precipitationLbl.isHidden=true
        two_skyLbl.isHidden=true
        three_precipitationLbl.isHidden=true
        three_skyLbl.isHidden=true
        four_precipitationLbl.isHidden=true
        four_skyLbl.isHidden=true
        five_precipitationLbl.isHidden=true
        five_skyLbl.isHidden=true
        
        // 알림을 위한 코드
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("🔔 알림 권한 허용됨")
            } else {
                print("❌ 알림 권한 거부됨")
            }
        }
        
        // gif 추가
        view.addSubview(gifImageView)
        view.sendSubviewToBack(gifImageView)
            NSLayoutConstraint.activate([
            //gifImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            //gifImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
                
            // 우측 상단에 gif 고정
            gifImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 98),
            gifImageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            gifImageView.widthAnchor.constraint(equalToConstant: 100),
            gifImageView.heightAnchor.constraint(equalToConstant: 100)
            ])
        
        guard
            let gifURL = Bundle.main.url(forResource: "snow", withExtension: "gif"),
            let gifData = try? Data(contentsOf: gifURL),
            let source = CGImageSourceCreateWithData(gifData as CFData, nil)
        else { return }
        
        let frameCount = CGImageSourceGetCount(source)
        var images = [UIImage]()

        (0..<frameCount)
            .compactMap { CGImageSourceCreateImageAtIndex(source, $0, nil) }
            .forEach { images.append(UIImage(cgImage: $0)) }

        gifImageView.animationImages = images
        gifImageView.animationDuration = TimeInterval(frameCount) * 0.05 // 0.05는 임의의 값
        gifImageView.animationRepeatCount = 0
        gifImageView.startAnimating()
    }
    
    // MARK: - gif를 날씨에 맞게 출력
    func updateWeatherGIF(pty: String?, sky: String?) {
        let pty = pty ?? ""
        let sky = sky ?? ""
        
        var imageName = ""
        
        if ["1", "5", "6"].contains(pty) {
            imageName = "rainy"
        } else if ["2", "3", "7"].contains(pty) {
            imageName = "snow"
        } else {
            switch sky {
            case "1":
                imageName = "sunny"
            case "3":
                imageName = "cloudy"
            case "4":
                imageName = "cloudy" // 흐림도 cloudy로 처리
            default:
                imageName = "sunny"
            }
        }
        
        loadGIF(named: imageName)
    }
    
    func loadGIF(named name: String) {
        guard let gifURL = Bundle.main.url(forResource: name, withExtension: "gif"),
              let gifData = try? Data(contentsOf: gifURL),
              let source = CGImageSourceCreateWithData(gifData as CFData, nil)
        else {
            print("❌ \(name).gif 파일을 불러올 수 없습니다.")
            return
        }

        let frameCount = CGImageSourceGetCount(source)
        var images: [UIImage] = []

        for i in 0..<frameCount {
            if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: cgImage))
            }
        }

        gifImageView.animationImages = images
        gifImageView.animationDuration = Double(frameCount) * 0.05
        gifImageView.animationRepeatCount = 0
        gifImageView.startAnimating()
    }
    
    // MARK: - Location Manager
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.startUpdatingLocation()
        } else {
            gpsLbl.text = "위치 권한이 필요합니다."
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        manager.stopUpdatingLocation()
        
        lastCoordinate = location.coordinate
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        gpsLbl.text = String(format: "위도: %.4f, 경도: %.4f", lat, lon)
        
        // 위도 경도를 실제 주소로 변경
        getAddressFromLocation(latitude: lat, longitude: lon)
        
        let grid = convertGPStoGRID(lat_X: lat, lng_Y: lon)
        gridLbl.text = "격자: \(grid.0), \(grid.1)"
        
        setupTimeStrings()
        fetchForecast(type: .ultraSrtFcst)
        fetchForecast(type: .vilageFcst)
        //fetchDustData()
        scheduleUltraTimer()
        scheduleDailyTimer()
    }
    
    // 기상청 api에 요청을 보낼 때 사용할 두 가지 변수!
    private enum ForecastType { case ultraSrtFcst, vilageFcst }
    
    // MARK: - 변환된 좌표를 이용해서 URL을 구성하고 Alamofire에 HTTP 데이터 요청
    // 기상청 api에 요청을 보내는 부분
    // 입력은 ForcastType으로 받는다!
    private func fetchForecast(type: ForecastType) {
        
        // 사용자의 GPS 좌표 반환
        // guard를 통해서 안전하게 바인딩, 이미 location manager로 값을 받아온 상태
        guard let coord = lastCoordinate else { return }
        
        // GPS에서 위도,경도를 입력해서 nx,ny 좌표로 변환
        let grid = convertGPStoGRID(lat_X: coord.latitude, lng_Y: coord.longitude)
        
        //URL 만들기 입력한 type을 넣어서 맞는 api를 호출한다
        let url = buildUrl(for: type, grid: grid)
        
        
        /*
         Alamofire swift 용 HTTP 네트워크 라이브러리
         
         기존방법
         - URL을 String으로 만들고, URL 타입으로 변경
         - URLSession으로 해당 URL에 요청(swift에서 쓰는 기본 클래스)
         - 요청을 보내서 받아온 JSON data는 직접 파싱
         
         */
        
        /*
         클로저 -> 함수 포인터랑 비슷한가..?
         일단 클로저는 익명함수를 변수처럼 다룰 수 있게 한다.
         문법은 { (매개변수)->반환형 in 실행 코드 }
         
         클로저 축약문법 어지럽다.. 일단 넘어가
        
         */
        
        // alamofire에 데이터 요청
        // request 함수를 통해서 DataRequest 리턴 -> responseData는 이 객체의 메소드
        // responseData
        AF.request(url).responseData { response in
            switch response.result { // 성공 시에 response를 매개변수로 바로 switch부터 클로저 실행
            case .success(let data): // 성공할 경우에(response.result는 열거형, suc,fail)
                do {
                    // data는 현재 바이트 -> data를 JSON 객체로 변환
                    // 에러가 생길 수 있으니 try, catch로 에러 핸들링
                    // 이 과정 이후에 JSON 객체는 swift의 딕셔너리가 된다!
                    let json = try JSONSerialization.jsonObject(with: data)
                    
                    //ResponseGetWeather 타입에 맞게 만들어진 Mapper를 이용해서
                    //map 함수로 매칭 -> 이 때 JSON 키 이름과 mapper 내부의 키 이름이 일치해야함
                    //매칭이 완료된 이후에 model에는
                    guard let model = Mapper<ResponseGetWeather>().map(JSONObject: json) else { return }
                    
                    //옵셔널 체이닝 -> 하나라도 nil이면 nil을 반환하고, 마지막 item이 nil인 경우는 []를 반환
                    // ??는 앞의 값이 nil인 경우 다음에 나오는 값을 사용하도록 한다.
                    let items = model.response?.body?.items?.item ?? []
                    
                    /*
                     이 때 열거형이기 때문에 ForecastType.ultra~ 라고 안 쓰고
                     그냥 . 을 사용해도 좋음!
                     */
                    
                    // 필터링하는 과정
                    switch type {
                    case .ultraSrtFcst:
                        let list = self.filterUltraShortTerm(items: items)
                        self.updateUltraSrtUI(with: list)
                    case .vilageFcst:
                        let list = self.filterShortTerm(items: items)
                        self.updateVilageUI(with: list)
                    }
                } catch {
                    print("JSON Decoding Error: \(error)")
                }
            case .failure(let error):
                print("Network Error: \(error)")
            }
        }
    }
    
    //MARK: - alamofire로 dust 데이터 요청
    private func fetchDustData() {
        let url = buildUrlForDust() // sidoName 포함되어 있어야 함
        print("요청 URL: \(url)")
        //print("api에 넘길 sido 이름: " + self?.currentSidoName)

        // 시도 이름별 대표 측정소 이름 매핑
        let sidoToMainStation: [String: String] = [
            "서울": "중구",
            "부산": "연제구",
            "대구": "중구",
            "인천": "남동구",
            "광주": "북구",
            "대전": "서구",
            "울산": "남구",
            "경기": "수원시",
            "강원": "춘천",
            "충북": "청주시",
            "충남": "천안시",
            "전북": "전주시",
            "전남": "목포시",
            "경북": "포항시",
            "경남": "창원시",
            "제주": "제주시",
            "세종": "세종",
            "전국": "중구" // 예외 처리용
        ]

        // 현재 시도 이름을 기반으로 대표 측정소 얻기
        guard let sido = currentSidoName,
              let mainStation = sidoToMainStation[sido] else {
            print("❌ 시도 이름 또는 대표 측정소를 찾을 수 없습니다.")
            return
        }
        
        //print("✅ currentSidoName: \(currentSidoName ?? "없음")")

        AF.request(url).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data)
                    guard let model = Mapper<ResponseGetDust>().map(JSONObject: jsonObject) else { return }
                    let items = model.response?.body?.items ?? []

                    // 해당 대표 측정소 필터링
                    if let selectedItem = items.first(where: { $0.stationName == mainStation }) {
                        DispatchQueue.main.async {
                            self.pm10Label.text = "미세먼지(PM10): \(selectedItem.pm10Value ?? "-") ㎍/㎥"
                            self.pm25Label.text = "초미세먼지(PM2.5): \(selectedItem.pm25Value ?? "-") ㎍/㎥"
                            //self.stationLabel.text = "측정소: \(selectedItem.stationName ?? "-")"
                        }
                    } else {
                        print("⚠️ 해당 시도의 대표 측정소(\(mainStation)) 데이터를 찾을 수 없습니다.")
                    }
                } catch {
                    print("❌ JSON 파싱 에러: \(error)")
                }

            case .failure(let error):
                print("❌ 네트워크 에러: \(error)")
            }
        }
    }
    //MARK: - 예보 URL 제작
    // 날씨 API에 전달할 URL을 생성하는 부분, 어차피 같은 곳에서 받아오니까 하나로 묶자!
    private func buildUrl(for type: ForecastType, grid: (Int, Int)) -> String {
        // 전달할 API에 넘길 URL 만들 때 엔드포인트 + 값들 + ..
        // ForecastType에 따라서 엔드포인트 다르니까 -> base를 설정
        let base = (type == .ultraSrtFcst) ? ultraSrtFcstUrl : vilageFcstUrl
        
        // base를 이용해서 URL만드는 부분
        if(base == ultraSrtFcstUrl)
        {
            var url = base + "serviceKey=" + apiKey
            url += "&pageNo=1&numOfRows=1000&dataType=JSON"
            url += "&base_date=\(getBaseDateUltraSrt())"
            url += "&base_time=\(getBaseTimeUltraSrt())"
            url += "&nx=\(grid.0)&ny=\(grid.1)"
            return url
        }
        
        else // 요청 URL이 단기예보라면 -> swift에선 모든 경우 다 리턴하는 것 체크해야함!
        {
            var url = base + "serviceKey=" + apiKey
            url += "&pageNo=1&numOfRows=1000&dataType=JSON"
            url += "&base_date=\(getBaseDateVilage())"
            url += "&base_time=\(getBaseTimeVilage())" // 단기예보일 경우 최저/최고 기온은 당일에 02시에 한번씩만 받아오도록
            url += "&nx=\(grid.0)&ny=\(grid.1)"
            return url
        }
    }

    // MARK: - 미세먼지 URL 제작
    private func buildUrlForDust() -> String {
        // 전달할 API에 넘길 URL 만들 때 엔드포인트 + 값들 + ..
        let base = fineDustURL
        
        guard let sidoName = currentSidoName else {
            return ""}
        
        // base를 이용해서 URL만드는 부분
            var url = base + "serviceKey=" + fineDustKey
            url += "&returnType=JSON&numOfRows=100&pageNo=1"
            url += "&sidoName=\(sidoName)"
            url += "&ver=1.0"
            //print("요청 URL: \(url)")
        print("✅ fineDustURL: \(fineDustURL)")
        print("✅ fineDustKey: \(fineDustKey)")
        print("✅ currentSidoName: \(currentSidoName ?? "없음")")
            return url
        }
        
    // MARK: - 필터링
        
    // item은 배열이고, 이 매개변수를 이용해서 같은 타입의 배열을 반환하는 메소드 -> 클로저에서 in 생략도 가능..
    // 배열이 가진 filter 메소드 이용해서
        private func filterUltraShortTerm(items: [ResponseGetWeather.Item]) -> [ResponseGetWeather.Item] {
            // 시간 제한 없이 최신 카테고리만 필터링
            return items.filter { item in // 배열을 돌면서 요소 하나씩 item에 들어오고, iterator처럼
                // 조건식에 맞는 것들만 가져와서 만든 배열을 리턴!
                
                // item 배열의 categroy를 가져오고, 이 4개중에 있다면 true를 반환
                // true를 반환하는 객체만 filter 함수를 통해서 리턴할 items 배열에 포함됨!
                guard let cat = item.category else { return false }
                return ["T1H", "PTY", "WSD", "SKY"].contains(cat)
            }
        }

    // 단기 예보 데이터에서 URL 넘길 때 basedate를 어제 날짜로 주고, 어제 예측한 오늘 데이터를 받아옴..?
    private func filterShortTerm(items: [ResponseGetWeather.Item]) -> [ResponseGetWeather.Item] {
        let nowTimeDate = String(nowTimeString.prefix(8))
        return items.filter { item in
            if item.category == "TMN" { return item.fcstDate == nowTimeDate && item.fcstTime == "0600" }
            if item.category == "TMX" { return item.fcstDate == nowTimeDate && item.fcstTime == "1500" }
            return false
        }
    }
    
    //MARK: - 비 예보 알림을 위한 함수
    private func sendRainNotification(in hour: Int) {
        let content = UNMutableNotificationContent()
        content.title = "비 예보 알림 ☔️"
        content.body = "\(hour)시간 이후에 비가 올 예정입니다."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false) // 1시간에 1번씩 알림
        let request = UNNotificationRequest(identifier: "rainAlert", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ 알림 전송 실패: \(error)")
            } else {
                print("✅ 비 예보 알림 전송됨")
            }
        }
    }
    
    // MARK: - UI Updates
    // UIKit은 스레드에 안전하지 않기 때문에 무조건 main 스레드에서만 작업할 수 있도록
    // 메인 큐에서 비동기적으로 진행하라는 async를 작업해야 돼
    // async 는 지금 바로 실행하는게 아니라 나중에 실행 예약 -> UI 에선 이 작업 필수!!
    private func updateUltraSrtUI(with items: [ResponseGetWeather.Item]) {
        DispatchQueue.main.async {
            
            // 1~5시간 후를 위한 라벨들을 배열로 구성
            let hourLater = [self.one_hourLater, self.two_hourLater, self.three_hourLater, self.four_hourLater,self.five_hourLater]
            let weatherIcons = [self.one_weatherIcon, self.two_weatherIcon, self.three_weatherIcon, self.four_weatherIcon, self.five_weatherIcon]
            let tempLabels = [self.one_tempLbl, self.two_tempLbl, self.three_tempLbl, self.four_tempLbl, self.five_tempLbl]
            let ptyLabels = [self.one_precipitationLbl, self.two_precipitationLbl, self.three_precipitationLbl, self.four_precipitationLbl, self.five_precipitationLbl]
            let wsdLabels = [self.one_windSpeedLbl, self.two_windSpeedLbl, self.three_windSpeedLbl, self.four_windSpeedLbl, self.five_windSpeedLbl]
            let skyLabels = [self.one_skyLbl, self.two_skyLbl, self.three_skyLbl, self.four_skyLbl, self.five_skyLbl]
            
            // 위젯에 넘길 데이터(기온,풍속, 이미지 이름(강수형태, 하늘상태 조합)
            let hourKeys = ["one", "two", "three", "four", "five"]
            
            // 시간순 정렬 (fcstTime은 "0700" 형식이므로 정렬 가능)
            let sortedItems = items.sorted { ($0.fcstTime ?? "") < ($1.fcstTime ?? "") }
            
            // 카테고리별로 아이템 필터
            let t1hItems = sortedItems.filter { $0.category == "T1H" }
            let ptyItems = sortedItems.filter { $0.category == "PTY" }
            let wsdItems = sortedItems.filter { $0.category == "WSD" }
            let skyItems = sortedItems.filter { $0.category == "SKY" }
            
            // 최대 5개까지만 각 label에 매칭
            for i in 0..<5 {
                hourLater[i]?.text = String(i+1)+"시간 +"
                if i < t1hItems.count {
                    tempLabels[i]?.text = "\(t1hItems[i].fcstValue ?? "")°"
                }
                if i < ptyItems.count {
                    ptyLabels[i]?.text = "강수형태: \(ptyItems[i].fcstValue ?? "")"
                }
                if i < wsdItems.count {
                    wsdLabels[i]?.text = "\(wsdItems[i].fcstValue ?? "") m/s"
                }
                if i < skyItems.count {
                    skyLabels[i]?.text = "하늘상태: \(skyItems[i].fcstValue ?? "")"
                }
                
                // 1시간 데이터를 main 라벨에 넣는다
                self.main_tempLbl.text = "\(t1hItems[0].fcstValue ?? "")°"
                
                let temp = tempLabels[i]?.text ?? ""
                let wind = wsdLabels[i]?.text ?? ""
                
                // 기상에 따라서 이미지 넣기
                if i < ptyItems.count && i < skyItems.count {
                        let pty = ptyItems[i].fcstValue ?? ""
                        let sky = skyItems[i].fcstValue ?? ""

                        var imageName: String = ""

                        if ["1", "5", "6"].contains(pty) {
                            imageName = "rain" // 비, 빗눈 등
                        } else if ["2", "3", "7"].contains(pty) {
                            imageName = "snow" // 눈, 소나기 등
                        } else {
                            // PTY가 0일 때 SKY 값으로 판단
                            switch sky {
                            case "1":
                                imageName = "sunny" // 맑음
                            case "3":
                                imageName = "cloudy" // 구름많음
                            case "4":
                                imageName = "fog" // 흐림
                            default:
                                imageName = "sunny" // 기본값은 맑음
                            }
                        }

                        weatherIcons[i]?.image = UIImage(named: imageName)
                    
                    
                    // UserDefaults에 저장하고, key이름은 one_temp, one_wind 형식
                    let keyPrefix = hourKeys[i]
                    self.sharedDefaults?.set(temp, forKey: "\(keyPrefix)_temp")
                    self.sharedDefaults?.set(wind, forKey: "\(keyPrefix)_wind")
                    self.sharedDefaults?.set(imageName, forKey: "\(keyPrefix)_imageName")
                    
                    // 1시간 후의 데이터를 상단에 표시
                    if i == 0 {
                        self.updateWeatherGIF(pty: pty, sky: sky)
                    }
                    
                }

                
                // PTY 항목을 가져옴
                let ptyItems = sortedItems.filter { $0.category == "PTY" }

                // 시간별 PTY 값 배열 (최대 5개)
                let ptyValues = ptyItems.prefix(5).compactMap { Int($0.fcstValue ?? "0") }

                if ptyValues.count >= 2 {
                    let firstPTY = ptyValues[0] // 1시간 후
                    for i in 1..<ptyValues.count {
                        let futurePTY = ptyValues[i]
                        if firstPTY == 0 && futurePTY != 0 {
                            self.sendRainNotification(in: i + 1) // i+1 시간 후 비 예보
                            break
                        }
                    }
                }
            }
        }
    }


    private func updateVilageUI(with items: [ResponseGetWeather.Item]) {
        DispatchQueue.main.async {
            var tmin: String?
            var tmax: String?
            
            for item in items {
                switch item.category {
                case "TMN":
                    tmin = item.fcstValue
                    self.tminLbl.text = "최저기온: \(tmin ?? "")°"
                case "TMX":
                    tmax = item.fcstValue
                    self.tmaxLbl.text = "최고기온: \(tmax ?? "")°"
                default:
                    break
                }
                self.tmaxMinLbl.text = "\(tmin ?? "")°/ \(tmax ?? "")°"
            }

            // App Group에 저장
            // self.sharedDefaults = UserDefaults(suiteName: "group.com.hyeok.weather")
            
            // if문의 실행불록 -> 이렇게 if문 사용..!
            if let tmin = tmin {
                self.sharedDefaults?.set("\(tmin)°", forKey: "widget_tmin")
            }
            if let tmax = tmax {
                self.sharedDefaults?.set("\(tmax)°", forKey: "widget_tmax")
            }
        }
    }


    // MARK: - 시간에 맞게 요청 갱신하는 타이머
    private func scheduleUltraTimer() {
        ultraTimer?.invalidate()
        ultraTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            self.fetchForecast(type: .ultraSrtFcst)
            //self.fetchDustData()
        }
    }

    private func scheduleDailyTimer() {
        dailyTimer?.invalidate()
        dailyTimer = Timer.scheduledTimer(withTimeInterval: 86400, repeats: true) { _ in
            self.fetchForecast(type: .vilageFcst)
        }
    }
    //MARK: - 날짜, 시간을 형식에 맞게 반환하는 함수
    /* DateFormatter 클래스 -> Date 인스턴스를 String으로 변환하는 작업 */
    /*
     1) 멤버
     - dateFormat -> 날짜 형식을 지정하는 멤버
     
     2) 메소드
     - string(from : Date) -> struct Date 타입을 입력받아서, String 인스턴스로 변환
     (이 때 Date()는 현재 시간을 담는 인스턴스 -> DateFormatter 로 원하는 형식으로 바꿀 수 있다)
     
     (from은 파라미터 레이블이라는데 왜 쓰는진 잘 모르겠다, 일단 호출할 때 파라미터만 넣지말고, 레이블 : 파라미터 형식)
     */
    
    private func setupTimeStrings() {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmm"
        nowTimeString = df.string(from: Date())
        
        // String.prefix 메소드 -> SubString 타입을 리턴, 근데 다시 String으로 캐스팅 가능
        // prefix를 통해서 앞에서 10글자 까지만 자른다. suffix는 뒤에서부터 fix
        // 그리고 뒤에 00 붙여서 minute을 없애고 예보 시간을 정각으로
        fstTimeString = String(nowTimeString.prefix(10)) + "00"
        
        // getBaseTimeString 호출
        baseTimeStringForUltraSrt = getBaseTimeStringForUltra()
        baseTimeStringForVilage = getBaseTimeStringForVilage()
    }

    private func getBaseDateVilage() -> String { String(baseTimeStringForVilage.prefix(8)) }
    private func getBaseDateUltraSrt() -> String { String(baseTimeStringForUltraSrt.prefix(8)) }
    private func getBaseTimeVilage() -> String { String(baseTimeStringForVilage.suffix(4)) }
    private func getBaseTimeUltraSrt() -> String { String(baseTimeStringForUltraSrt.suffix(4)) }

    /* 이건 왜 필요한지 모르겠다. */private func getTomorrowDate() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        guard let today = df.date(from: String(nowTimeString.prefix(8))) else { return "" }
        return df.string(from: Calendar.current.date(byAdding: .day, value: 1, to: today)!)
    }

    // base time을 반환하는 함수들
    /*
     구현해야할 것
     - 단기예보라면 02시 전에 API를 호출했을 때 가져올 수 없으니 전날로 바꾸고 23시 데이터를 가져와야함
     - 초단기예보라면 매 시간 30분 마다 가져올 수 있는데, 12:10 에 요청했을 경우 11시 30분 데이터를 가져와야 함
     - 만약 새벽 00:10 에 요청했을 경우 전날 11시 30분 데이터를 가져와야 함
     
     So 함수에서 입력을 받아서 API에 맞는 시간을 반환하자!
     아냐 이렇게 하지말고, 이 함수는 초단기 전용으로 하고, 단기는 다른 함수로 만들자 구현 간단하게
     */
    
    // 초단기예보 baseTime 반환 함수
    private func getBaseTimeStringForUltra() -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmm"
        let now = Date()
        let nowTimeString = df.string(from: now) // 현재 시각을 "yyyyMMddHHmm" 형식으로

        let hour = Int(String(nowTimeString.dropFirst(8).prefix(2)))!  // 시 (HH)
        let minute = Int(String(nowTimeString.suffix(2)))!            // 분 (mm)

        if hour == 0 && minute < 30 {
            // 새벽 0시 30분 이전이면 어제 23시 30분 데이터
            let calendar = Calendar.current
            let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!
            let ymd = DateFormatter()
            ymd.dateFormat = "yyyyMMdd"
            let yesterdayStr = ymd.string(from: yesterday)
            return yesterdayStr + "2330"
        } else if minute < 30 {
            // 분이 30 미만이면 한 시간 전 30분 데이터
            let calendar = Calendar.current
            let oneHourAgo = calendar.date(byAdding: .hour, value: -1, to: now)!
            let dfHour = DateFormatter()
            dfHour.dateFormat = "yyyyMMddHH"
            return dfHour.string(from: oneHourAgo) + "30"
        } else {
            // 분이 30 이상이면 현재 시간 30분 데이터
            let dfHour = DateFormatter()
            dfHour.dateFormat = "yyyyMMddHH"
            return dfHour.string(from: now) + "30"
        }
    }
    
    // 단기예보 baseTime: 무조건 전날 02시 기준의 데이터를 사용 -> 전날 2시에 뜬 오늘 최고, 최저 기온?
    private func getBaseTimeStringForVilage() -> String {
        let now = Date()
        let calendar = Calendar.current

        // 무조건 어제 날짜로 설정
        let yesterday = calendar.date(byAdding: .day, value: -1, to: now)!

        // 날짜를 yyyyMMdd 형식으로 문자열로 변환
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd"
        let dateString = df.string(from: yesterday)

        // 02시 00분을 붙여서 baseTime 생성
        return dateString + "0200"
    }
    
    //MARK: - 위도 경도 좌표 변환 함수
    // 위도, 경도 -> nx, ny
    private func convertGPStoGRID(lat_X: Double, lng_Y: Double) -> (Int, Int) {
        let RE: Double    = 6371.00877
        let GRID: Double  = 5.0
        let SLAT1: Double = 30.0 * Double.pi / 180.0
        let SLAT2: Double = 60.0 * Double.pi / 180.0
        let OLON: Double  = 126.0 * Double.pi / 180.0
        let OLAT: Double  = 38.0 * Double.pi / 180.0
        let XO: Double    = 43.0
        let YO: Double    = 136.0
        let DEGRAD: Double = Double.pi / 180.0

        let re = RE / GRID
        let sn_numer = log(cos(SLAT1) / cos(SLAT2))
        let sn_denom = log(tan(Double.pi * 0.25 + SLAT2 * 0.5) / tan(Double.pi * 0.25 + SLAT1 * 0.5))
        let sn = sn_numer / sn_denom
        let sf = pow(tan(Double.pi * 0.25 + SLAT1 * 0.5), sn) * cos(SLAT1) / sn
        let ro = re * sf / pow(tan(Double.pi * 0.25 + OLAT * 0.5), sn)

        let radLat = lat_X * DEGRAD
        let radLon = lng_Y * DEGRAD
        let ra = re * sf / pow(tan(Double.pi * 0.25 + radLat * 0.5), sn)
        var theta = radLon - OLON
        if theta > Double.pi { theta -= 2.0 * Double.pi }
        else if theta < -Double.pi { theta += 2.0 * Double.pi }
        theta *= sn

        let x = Int(floor(ra * sin(theta) + XO + 0.5))
        let y = Int(floor(ro - ra * cos(theta) + YO + 0.5))
        return (x, y)
    }
    
    // MARK: - 지역이름 매핑 테이블
    private func convertToSidoName(from administrativeArea: String) -> String? {
        // 매핑 테이블: 행정구역 전체 이름 → API에서 요구하는 시도 이름
        let mapping: [String: String] = [
            "서울특별시": "서울",
            "부산광역시": "부산",
            "대구광역시": "대구",
            "인천광역시": "인천",
            "광주광역시": "광주",
            "대전광역시": "대전",
            "울산광역시": "울산",
            "세종특별자치시": "세종",
            "경기도": "경기",
            "강원도": "강원",
            "충청북도": "충북",
            "충청남도": "충남",
            "전라북도": "전북",
            "전라남도": "전남",
            "경상북도": "경북",
            "경상남도": "경남",
            "제주특별자치도": "제주"
        ]
        
        return mapping[administrativeArea]
    }
    
    // 받아온 위도 경도를 주소 값으로 변환하고 라벨 텍스트로 넣기
    func getAddressFromLocation(latitude: Double, longitude: Double) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        print("🛰 위치 → 주소 변환 시도 중")
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("지오코딩 오류: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.locationLabel.text = "주소를 찾을 수 없습니다."
                }
                return
            }
            
            if let placemark = placemarks?.first {
                let administrativeArea = placemark.administrativeArea ?? "" // 시/도
                let locality = placemark.locality ?? ""                     // 시/군/구
                let subLocality = placemark.subLocality ?? ""              // 동
                
                // 미세먼지 API 전달을 위한 시도 이름
                let sidoName = self?.convertToSidoName(from: administrativeArea) ?? "서울" // 기본값 설정 가능
                

                let fullAddress = "\(administrativeArea) \(locality) \(subLocality)"
                
                // 위젯에 데이터를 넘기기 위한 값
                self?.sharedDefaults?.set(fullAddress, forKey: "address")
                
                DispatchQueue.main.async {
                    self?.locationLabel.text = fullAddress
                    self?.currentSidoName = sidoName  // 이후 URL 제작에 사용
                    self?.fetchDustData()  // ✅ 여기서 미세먼지 API 요청
                    //print(self?.currentSidoName)
                }
            } else {
                DispatchQueue.main.async {
                    self?.locationLabel.text = "주소를 찾을 수 없습니다."
                }
            }
        }
    }
}

//MARK: - 추가로 구현해야할 것
//초단기에서 fcstTime을 5시간 데이터를 따로 가져오도록 해야하고,  -> O
//시간 별로 알림 기능을 넣어야함 -> O
//미세먼지 데이터 -> 측정소별 실시간 데이터 조회 현황 API 사용..!
//GIF 넣어주기 받아온 데이터 활용
//위젯 구현

