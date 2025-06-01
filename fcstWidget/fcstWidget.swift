//
//  fcstWidget.swift
//  fcstWidget
//
//  Created by Hyeok Jung Kwon on 5/29/25.
//

import WidgetKit
import SwiftUI

// 위젯 배경색을 바꾸는 헬퍼
func backgroundColor(for imageName: String) -> Color {
    switch imageName {
    case "sunny":
        return Color.blue.opacity(0.7)       // 밝은 파랑
    case "cloudy":
        return Color.gray.opacity(0.7)       // 옅은 회색 (더 연하게)
    case "rain":
        return Color.blue.opacity(0.3)       // 옅은 파란색
    case "snow":
        return Color.white.opacity(0.8)      // 흰색 (약간 투명)
    case "fog":
        return Color.gray.opacity(0.7)      // 흰색 (약간 투명)
    default:
        return Color.blue.opacity(0.7)
    }
}

struct Provider: TimelineProvider {
    // placeholder
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(
            date: Date(),
            address: "서울시 서초구 반포동",
            tmin: "최저기온: --°C",
            tmax: "최고기온: --°C",
            temp1: "--°C",
            wind1: "-- m/s",
            image1: "sunny",  // 기본 이미지 이름 (Assets에 있는 것으로 설정)
            temp2: "--°C",
            wind2: "-- m/s",
            image2: "sunny",
            temp3: "--°C",
            wind3: "-- m/s",
            image3: "sunny",
            temp4: "--°C",
            wind4: "-- m/s",
            image4: "sunny",
            temp5: "--°C",
            wind5: "-- m/s",
            image5: "sunny",

        )
    }

    // 스냅샷 (위젯 미리보기용)
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let defaults = UserDefaults(suiteName: "group.com.hyeok.weather")

        let entry = SimpleEntry(
            date: Date(),
            address: defaults?.string(forKey: "address") ?? "서울시 서초구 반포동",
            tmin: defaults?.string(forKey: "widget_tmin") ?? "최저기온: --°C",
            tmax: defaults?.string(forKey: "widget_tmax") ?? "최고기온: --°C",
            temp1: defaults?.string(forKey: "one_temp") ?? "--°C",
            wind1: defaults?.string(forKey: "one_wind") ?? "-- m/s",
            image1: defaults?.string(forKey: "one_imageName") ?? "sunny",
            temp2: defaults?.string(forKey: "two_temp") ?? "--°C",
            wind2: defaults?.string(forKey: "two_wind") ?? "-- m/s",
            image2: defaults?.string(forKey: "two_imageName") ?? "sunny",
            temp3: defaults?.string(forKey: "three_temp") ?? "--°C",
            wind3: defaults?.string(forKey: "three_wind") ?? "-- m/s",
            image3: defaults?.string(forKey: "three_imageName") ?? "sunny",
            temp4: defaults?.string(forKey: "four_temp") ?? "--°C",
            wind4: defaults?.string(forKey: "four_wind") ?? "-- m/s",
            image4: defaults?.string(forKey: "four_imageName") ?? "sunny",
            temp5: defaults?.string(forKey: "five_temp") ?? "--°C",
            wind5: defaults?.string(forKey: "five_wind") ?? "-- m/s",
            image5: defaults?.string(forKey: "five_imageName") ?? "sunny",
        )
        //print("DEBUG - one_temp: \(defaults?.string(forKey: "one_temp") ?? "nil")")
        //print("DEBUG - one_wind: \(defaults?.string(forKey: "one_wind") ?? "nil")")
        completion(entry)
    }

    // 실제 타임라인 구성 -> 리셋 버튼 없고, 자동 갱신이 필요하다!
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let defaults = UserDefaults(suiteName: "group.com.hyeok.weather")
        //데이터 갱신
        WidgetCenter.shared.reloadAllTimelines()
        
        let entry = SimpleEntry(
            date: Date(),
            address: defaults?.string(forKey: "address") ?? "서울시 서초구 반포동",
            tmin: defaults?.string(forKey: "widget_tmin") ?? "최저기온: --°C",
            tmax: defaults?.string(forKey: "widget_tmax") ?? "최고기온: --°C",
            temp1: defaults?.string(forKey: "one_temp") ?? "--°C",
            wind1: defaults?.string(forKey: "one_wind") ?? "-- m/s",
            image1: defaults?.string(forKey: "one_imageName") ?? "sunny",
            temp2: defaults?.string(forKey: "two_temp") ?? "--°C",
            wind2: defaults?.string(forKey: "two_wind") ?? "-- m/s",
            image2: defaults?.string(forKey: "two_imageName") ?? "sunny",
            temp3: defaults?.string(forKey: "three_temp") ?? "--°C",
            wind3: defaults?.string(forKey: "three_wind") ?? "-- m/s",
            image3: defaults?.string(forKey: "three_imageName") ?? "sunny",
            temp4: defaults?.string(forKey: "four_temp") ?? "--°C",
            wind4: defaults?.string(forKey: "four_wind") ?? "-- m/s",
            image4: defaults?.string(forKey: "four_imageName") ?? "sunny",
            temp5: defaults?.string(forKey: "five_temp") ?? "--°C",
            wind5: defaults?.string(forKey: "five_wind") ?? "-- m/s",
            image5: defaults?.string(forKey: "five_imageName") ?? "sunny",
        )
        //print("위젯에서 불러온 주소: \(defaults?.string(forKey: "address") ?? "nil")")

        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }

struct SimpleEntry: TimelineEntry {
    let date: Date
    let address : String
    // Small 위젯용
    let tmin : String
    let tmax : String
    let temp1: String
    let wind1: String
    let image1: String

    // Medium 위젯용
    let temp2: String
    let wind2: String
    let image2: String
    let temp3: String
    let wind3: String
    let image3: String
    let temp4: String
    let wind4: String
    let image4: String
    let temp5: String
    let wind5: String
    let image5: String
}

struct WidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            Text("지원되지 않는 위젯 크기")
        }
    }
}

@available(iOSApplicationExtension 17.0, *)
struct SmallWidgetView: View {
    let entry: SimpleEntry

    var body: some View {
        VStack {
            Text(entry.address).font(.caption)
            Text(entry.temp1)
            Image(entry.image1)
                .resizable()
                .scaledToFit()
                .frame(height: 40)
            Text(entry.tmin+"/"+entry.tmax)
            
            Text(entry.wind1)
        }
        .containerBackground(backgroundColor(for: entry.image1), for: .widget)
    }
}

@available(iOSApplicationExtension 17.0, *)
struct MediumWidgetView: View {
    let entry: SimpleEntry

    var body: some View {
        ZStack {

            HStack {
                VStack {
                    Text(entry.address).font(.caption)
                    Text(entry.temp1)
                    Image(entry.image1)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                    Text(entry.tmin+"/"+entry.tmax)
                    Text(entry.wind1)
                }
                // ➖ 세로선 Divider 추가
                    Divider()
                        .frame(height: 100) // 높이는 조정 가능
                        .background(Color.gray) // 색상 지정
                        .padding(.horizontal, 8)
                
                // 두 번째 VStack (기온 + 이미지만)
                               VStack {
                                   HStack {
                                       Text("2h+")
                                       Text(entry.temp2)
                                       Image(entry.image2)
                                           .resizable()
                                           .scaledToFit()
                                           .frame(height: 25)
                                   }
                                   
                                   HStack {
                                       Text("3h+")
                                       Text(entry.temp3)
                                       Image(entry.image3)
                                           .resizable()
                                           .scaledToFit()
                                           .frame(height: 25)
                                   }
                                   
                                   HStack {
                                       Text("4h+")
                                       Text(entry.temp4)
                                       Image(entry.image4)
                                           .resizable()
                                           .scaledToFit()
                                           .frame(height: 25)
                                   }
                                   
                                   HStack {
                                       Text("5h+")
                                       Text(entry.temp5)
                                       Image(entry.image5)
                                           .resizable()
                                           .scaledToFit()
                                           .frame(height: 25)
                                   }
                               }
            }
            .padding()
            .containerBackground(backgroundColor(for: entry.image1), for: .widget)
        }
    }
}



struct fcstWidget: Widget {
    let kind: String = "fcstWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }

}

#Preview(as: .systemSmall) {
    fcstWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        address: "서울시 서초구 반포동",
        tmin: "최저기온: 18°C",
        tmax: "최고기온: 27°C",
        temp1: "23°C",
        wind1: "2.3m/s",
        image1: "sunny",
        temp2: "25°C",
        wind2: "2.8m/s",
        image2: "sunny",
        temp3: "26°C",
        wind3: "3.1m/s",
        image3: "sunny",
        temp4: "25°C",
        wind4: "2.8m/s",
        image4: "sunny",
        temp5: "26°C",
        wind5: "3.1m/s",
        image5: "sunny",
    )
}
