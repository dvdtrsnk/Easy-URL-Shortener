//
//  NetworkingManager.swift
//  Easy URL Shortener
//
//  Created by David Třešňák on 22.03.2023.
//

import Foundation
import UIKit
import SystemConfiguration

protocol NetworkingManagerDelegate {
    func serverDidReturnSuccessTrue(_ recievedURL: URLModel)
    func serverDidReturnSuccessFalse()
    func deviceDoesNotHaveInternetConnection()
}

struct NetworkingManager {
    
    var delegate: NetworkingManagerDelegate?
    
    func deviceHasInternetConnection() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return (isReachable && !needsConnection)
    }
    
    
    func performRequest(_ filledURL: String) {
        if deviceHasInternetConnection() {
            let urlString = "https://ulvis.net/API/write/get?url=\(filledURL)"
            if let url = URL(string: urlString) {
                let task = URLSession(configuration: .default).dataTask(with: url) { (recievedData, response, error) in
                    if let recievedError = error {
                        print(recievedError)
                        return
                    }
                    if let safeData = recievedData {
                        if let shortURL = parseJSON(safeData) {
                            delegate?.serverDidReturnSuccessTrue(shortURL)
                        }
                        
                    }
                }
                task.resume()
                
            }
        } else {
            delegate?.deviceDoesNotHaveInternetConnection()
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
            delegate?.serverDidReturnSuccessFalse()
            return nil
        }
    }
    
}
    
    
    
