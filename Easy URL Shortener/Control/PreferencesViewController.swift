//
//  PreferencesViewController.swift
//  Easy URL Shortener
//
//  Created by David Třešňák on 22.03.2023.
//

import UIKit
import StoreKit
import SPConfetti

class PreferencesViewController: UIViewController {
    
    var userTippedApp = false
    let productID = "com.dvdtrsnk.URLShortenerEasy.1Tip"

    var localDataManager = LocalDataManager()
    
    var preferences = [ PreferencesOptions(name: "Help", icon: (UIImage(systemName: "questionmark")?.withRenderingMode(.alwaysTemplate))!),
                        PreferencesOptions(name: "Delete History", icon: (UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate))!),
                        PreferencesOptions(name: "Support Website", icon: (UIImage(systemName: "network")?.withRenderingMode(.alwaysTemplate))!) ]
    
    
    @IBOutlet weak var preferencesTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var preferencesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserData()
        registerCellsAndDelegates()
        setUI()
    }
    
    //MARK: - Functions()
    private func loadUserData() {
        userTippedApp = UserDefaults.standard.bool(forKey: "UserTippedApp")
    }
    
    private func setUI() {
        
        if userTippedApp == true {
            preferences.append(PreferencesOptions(name: "Thank you for your support!", icon: (UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysTemplate))!))
        } else {
            preferences.append(PreferencesOptions(name: "Do you like this app? Support me with 1$!", icon: (UIImage(systemName: "heart")?.withRenderingMode(.alwaysTemplate))!))
        }
        
        preferencesTableView.layer.cornerRadius = 10
        preferencesTableViewHeight.constant = CGFloat(preferences.count * 45)
        
        preferencesTableView.reloadData()
    }
    
    private func registerCellsAndDelegates() {
        preferencesTableView.register(UINib(nibName: K.Cells.preferencesCell, bundle: nil), forCellReuseIdentifier: K.Cells.preferencesCell)
        SKPaymentQueue.default().add(self)

    }
    
    private func supportCelebration() {
        let alert = UIAlertController(title: nil, message: "You supported me with 1$! Thank you!", preferredStyle: .alert)
        self.present(alert, animated: true)
        SPConfetti.startAnimating(.centerWidthToDown, particles: [.triangle, .arc])
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 7) {
            SPConfetti.stopAnimating()
            alert.dismiss(animated: true, completion: nil)
            }
    }
    
    
}

//MARK: - UITableView DataSource
extension PreferencesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.preferencesCell, for: indexPath) as! PreferencesCell
        cell.label.text = preferences[indexPath.row].name
        cell.icon.image = preferences[indexPath.row].icon
        
        return cell
    }
    
    
}

//MARK: - UITableView Delegate
extension PreferencesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch preferences[indexPath.row].name {
        case "Help":
            helpOptionPressed()
        case "Delete History":
            deleteOptionPressed()
        case "Support Website":
            if let url = URL(string: "https://dvdtrsnk.wordpress.com") {
                UIApplication.shared.open(url)
            }
        case "Do you like this app? Support me with 1$!":
            tipOptionPressed()
        case "Thank you for your support!":
            supportCelebration()
        default:
            break
        }
    }
    
    func helpOptionPressed() {
        let helpText = """
To shorten your URL, simply type it into the text field at the bottom of the screen.
Once shortened, you can either copy the result, share it, or view it as a QR code.

If you encounter any issues, please don't hesitate to contact me through the Support website.
"""
        
        let alert = UIAlertController(title: "Help", message: helpText, preferredStyle: .alert)
        let doneAction = UIAlertAction(title: "Done", style: .default, handler: nil)
        alert.addAction(doneAction)
        present(alert, animated: true, completion: nil)
    }
    
    func deleteOptionPressed() {
        let alert = UIAlertController(title: "Delete", message: "Do you want to delete whole history?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.localDataManager.deleteAllData()
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func tipOptionPressed() {
        if SKPaymentQueue.canMakePayments() {
            //can make Payments
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            //CANT
            print("User cant make payments")
        }
    }
    
}


//MARK: - SKPaymentTransactionObserver
extension PreferencesViewController: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
            for transaction in transactions {
                if transaction.transactionState == .purchased {
                    if userTippedApp == false {
                        preferences.remove(at: 3)
                        supportCelebration()
                        UserDefaults.standard.set(true, forKey: "UserTippedApp")
                        loadUserData()
                        preferencesTableView.reloadData()
                    }
                                        
                } else if transaction.transactionState == .failed {
                    print("Transaction Failed!")
                    if let error = transaction.error {
                        let errorDescription = error.localizedDescription
                        print("Transaction failed due to error: \(errorDescription)")
                    }
                }
            }
        }
    

}

