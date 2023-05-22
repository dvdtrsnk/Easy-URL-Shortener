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
    
    struct Segue {
        static let showQR = "ShowQRSegue"
    }
    
    struct Cells {
        static let preferencesCell = "PreferencesCell"
    }
}
