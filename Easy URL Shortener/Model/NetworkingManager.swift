//
//  NetworkingManager.swift
//  Easy URL Shortener
//
//  Created by David Třešňák on 22.03.2023.
//

import Foundation
import UIKit

struct NetworkingManager {
    
    func performRequest(URLAdress: String) {
        let urlString = "https://ulvis.net/API/write/get?url=\(URLAdress)"
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error)
                    return
                }
                if let safeData = data {
                    if let weather = parseJSON(safeData) {
//                        delegate?.didUpdateWeather(self, weather: weather)
                        print("something")
                    }
                }
            }
            task.resume()
                
            }
        }
    }

func parseJSON(_ urlData: Data) {
    let decoder = JSONDecoder()
    do {
        let decodedData = try decoder.decode(WeatherData.self , from: weatherData)
        let id = decodedData.weather[0].id
        let temp = decodedData.main.temp
        let name = decodedData.name
        
        let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
        
        return weather
    } catch {
        delegate?.didFailWithError(error: error)
        return nil
    }
}

}
