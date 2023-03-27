//
//  PreferencesViewController.swift
//  Easy URL Shortener
//
//  Created by David Třešňák on 22.03.2023.
//

import UIKit

class PreferencesViewController: UIViewController {

    var localDataManager = LocalDataManager()
    
    let preferences = [ PreferencesOptions(name: "Help", icon: (UIImage(systemName: "questionmark")?.withRenderingMode(.alwaysTemplate))!),
                        PreferencesOptions(name: "Delete History", icon: (UIImage(systemName: "trash")?.withRenderingMode(.alwaysTemplate))!),
                        PreferencesOptions(name: "Support Website", icon: (UIImage(systemName: "network")?.withRenderingMode(.alwaysTemplate))!)  ]
    
    
    @IBOutlet weak var preferencesTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var preferencesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        setUI()
    }
    
    //MARK: - Functions()
    func setUI() {
        preferencesTableView.layer.cornerRadius = 10
        preferencesTableViewHeight.constant = CGFloat(preferences.count * 44)
    }
    
    private func registerCells() {
        preferencesTableView.register(UINib(nibName: K.Cells.preferencesCell, bundle: nil), forCellReuseIdentifier: K.Cells.preferencesCell)
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
    
}

