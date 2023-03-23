//
//  UrlData.swift
//  Easy URL Shortener
//
//  Created by David Třešňák on 22.03.2023.
//

import Foundation
import UIKit

struct URLData: Decodable {
    let success: Bool
    let data: Data
}

struct Data: Decodable {
    let id: String
    let url: String
    let full: String
}
