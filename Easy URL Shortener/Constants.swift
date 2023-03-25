//
//  Constants.swift
//  Easy URL Shortener
//
//  Created by David Třešňák on 22.03.2023.
//

import Foundation
import UIKit
import CoreData

struct K {
    static let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let hapticFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    struct ResultViewStatus {
        static let no = "noResultView"
        static let wait = "waitResultView"
        static let noInternetConnection = "noInternetConnectionResultView"
        static let successFalse = "successFalseResultView"
        static let successTrue = "successTrueResultView"
    }
}
