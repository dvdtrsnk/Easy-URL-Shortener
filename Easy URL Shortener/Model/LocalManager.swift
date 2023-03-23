//
//  LocalManager.swift
//  Easy URL Shortener
//
//  Created by David Třešňák on 23.03.2023.
//

import Foundation
import UIKit
import CoreData

struct LocalManager {
    var items = [SearchedItem]()
    
    
    private func saveData() {
        do {
            try K.context.save()
        } catch {
            print("Error while saving data: \(error)")
        }
    }
    
    private mutating func loadData() {
        let request : NSFetchRequest<SearchedItem> = SearchedItem.fetchRequest()
        do {
            self.items = try K.context.fetch(request)
        } catch {
            print("Error fetching data: \(error)")
        }
    }
}
