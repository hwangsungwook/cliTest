//
//  main.swift
//  cliTest
//
//  Created by 성욱 on 2021/07/21.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
}

struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let description: String
    let id: Int
}

struct WeatherModel {
    let conditionId: Int
    let cityName: String
    let temperature: Double
    
    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
    
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
    
}

let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=420b6957ca2705d0995c8807acd4617d&units=metric"
//let weatherURL = "http://apis.data.go.kr/1230000/HrcspSsstndrdInfoService/getPublicPrcureThngInfoServc?serviceKey=rRcAP4sXQde7Q4g7%2B%2FlMZTBit2jXCILSK2a%2FvP5EFtH%2BgnFuzm5WYBo1yFgP3jStL6DjX82lT9aEKbxgg36zTQ%3D%3D&numOfRows=10&pageNo=1&inqryDiv=1&inqryBgnDt=201604010000&inqryEndDt=201605052359&bfSpecRgstNo=356759&type=json"


func fetchWeather(cityName: String) {
    let urlString = "\(weatherURL)&q=\(cityName)"
    
    performRequest(with: urlString)
}

func performRequest(with urlString: String) {
    if let url = URL(string: urlString) {
        
        let sema = DispatchSemaphore(value: 0)
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error.debugDescription)
                return
            }
            
            if let safeData = data {
                if let weather = parseJSON(safeData) {
                    print(weather)
                }
            }
            
            sema.signal()
        }
        
        task.resume()
        sema.wait()
    }
}

func parseJSON(_ weatherData: Data) -> WeatherModel? {
    let decoder = JSONDecoder()
    do {
        let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
        let id = decodedData.weather[0].id
        let temp = decodedData.main.temp
        let name = decodedData.name
        //print("decodedData\(decodedData)")
        
        let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
        //print(weather)
        return weather
        
    } catch {
        print("error: \(error)")
        return nil
    }
}


//func parseJSON2(_ weatherData: Data) -> WeatherModel? {
//    let decoder = JSONDecoder()
//    do {
//        let decodedData = try decoder.decode(String, from: weatherData)
//        let id = decodedData.weather[0].id
//        let temp = decodedData.main.temp
//        let name = decodedData.name
//        //print("decodedData\(decodedData)")
//
//        let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
//        //print(weather)
//        return weather
//
//    } catch {
//        print("error: \(error)")
//        return nil
//    }
//}

fetchWeather(cityName: "Seoul")
