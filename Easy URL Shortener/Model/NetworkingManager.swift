//
//  NetworkingManager.swift
//  Easy URL Shortener
//
//  Created by David Třešňák on 22.03.2023.
//

import Foundation
import UIKit

protocol NetworkingManagerDelegate {
    func serverDidShortURL(_ recievedURL: URLModel)
    func serverDidReturnError(_ recievedError: Error)
    func serverCouldntBeReached(_ recievedError: Error)
}

struct NetworkingManager {
    
    var delegate: NetworkingManagerDelegate?
    
    func performRequest(_ filledURL: String) {
        print("performRequest")
        let urlString = "https://ulvis.net/API/write/get?url=\(filledURL)"
        if let url = URL(string: urlString) {
            print("ifletURL")
            let task = URLSession(configuration: .default).dataTask(with: url) { (recievedData, response, error) in
                print("URLSession")
                if let recievedError = error {
                    delegate?.serverDidReturnError(recievedError)
                    return
                }
                if let safeData = recievedData {
                    if let shortURL = parseJSON(safeData) {
                        delegate?.serverDidShortURL(shortURL)
                    }
                    
                }
                if let recievedResponse = response {
                    print("došlo na response \(recievedResponse)")
                    return 
                }
            }
            task.resume()
            
        }
    }
    
    
    func parseJSON(_ urlData: Foundation.Data) -> URLModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(URLData.self , from: urlData)
            let id = decodedData.data.id
            let url = decodedData.data.url
            let full = decodedData.data.full
            
            
            let shortURL = URLModel(id: id, url: url, full: full)
            
            return shortURL
        } catch {
            print(error)
            return nil
        }
    }
}
    
    
    
