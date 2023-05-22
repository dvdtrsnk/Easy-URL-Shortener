//
//  ViewController.swift
//  Easy URL Shortener
//
//  Created by David Třešňák on 21.03.2023.
//

import UIKit

class ShortURLViewController: UIViewController {

    var networkingManager = NetworkingManager()
    var localDataManager = LocalDataManager()
    var displayedURL: String?
    var displayedShortURL: String?
    
    @IBOutlet weak var resultStackView: UIStackView!
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var waitResultView: UIView!
    @IBOutlet weak var noInternetConnectionResultView: UIView!
    
    @IBOutlet weak var successFalseResultView: UIView!
    @IBOutlet weak var successTrueResultView: UIView!
    
    @IBOutlet weak var successTrueResultUrlLabel: UILabel!
    @IBOutlet weak var successTrueResultShortUrlLabel: UILabel!
    @IBOutlet weak var successTrueShareButton: UIButton!
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var historyTableViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomUrlView: UIView!
    @IBOutlet weak var bottomUrlViewPasteButton: UIButton!
    @IBOutlet weak var bottomUrlViewBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomUrlTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        registerNotificationsAndDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    
    //MARK: - Functions()
    
    private func setUI() {
        resultStackView.layer.cornerRadius = 10
        historyTableView.layer.cornerRadius = 10
        bottomUrlView.layer.cornerRadius = 10
        changeDisplayedResultView(named: .no)
        if UIDevice.current.userInterfaceIdiom == .pad {
           successTrueShareButton.isHidden = true
        }
    }
    
    private func updateUI() {
        localDataManager.loadData()
        if bottomUrlTextField.text == nil || bottomUrlTextField.text == "" {
            bottomUrlViewPasteButton.isHidden = false
        } else {
            bottomUrlViewPasteButton.isHidden = true
        }
        successTrueResultUrlLabel.text = displayedURL
        successTrueResultShortUrlLabel.text = displayedShortURL
        localDataManager.loadData()
        historyTableView.reloadData()
        historyTableViewHeight.constant = CGFloat(min(localDataManager.items.count * 44, 880))
    }
    
    
    enum displayedResultView {
        case no, wait, noInternetConnection, successFalse, successTrue
    }
    
    private func changeDisplayedResultView(named: displayedResultView) {
        print("resultview: \(named)")
        noResultView.isHidden = true
        waitResultView.isHidden = true
        noInternetConnectionResultView.isHidden = true
        successFalseResultView.isHidden = true
        successTrueResultView.isHidden = true
        UIView.animate(withDuration: 0.3) { [self] in
            switch named {
            case .no:
                noResultView.isHidden = false
            case .wait:
                waitResultView.isHidden = false
            case .noInternetConnection:
                noInternetConnectionResultView.isHidden = false
            case .successFalse:
                successFalseResultView.isHidden = false
            case .successTrue:
                successTrueResultView.isHidden = false
            }
        }
        
    }
    
    private func userPressedGo() {
        if bottomUrlTextField.text != nil || bottomUrlTextField.text != "" {
            networkingManager.performRequest(bottomUrlTextField.text!)
            changeDisplayedResultView(named: .wait)
            
            
            let duplicatesToDelete = localDataManager.items.filter { $0.full == bottomUrlTextField.text }
            for delete in duplicatesToDelete {
                K.context.delete(delete)
            }
            
            let newItem = SearchedItem(context: K.context)
            newItem.full = bottomUrlTextField.text
            newItem.date = Date()
            localDataManager.items.append(newItem)
            localDataManager.saveData()
            updateUI()
        }

        self.view.endEditing(true)
    }
    
    private func registerNotificationsAndDelegates() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        networkingManager.delegate = self

    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            bottomUrlViewBotConstraint.constant = 0 + keyboardHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomUrlViewBotConstraint.constant = 83
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.showQR {
            let destionationVC = segue.destination as! QRViewController
            destionationVC.displayedShortURL = displayedShortURL
        }
    }

    //MARK: - IBAction Buttons
    
    @IBAction func bottomUrlViewPasteButtonPressed(_ sender: Any) {
        if let clipboardString = UIPasteboard.general.string {
            bottomUrlTextField.text = clipboardString
            updateUI()
            userPressedGo()
        }
    }
    
    
    @IBAction func copyButtonPressed(_ sender: UIButton) {
        if let url = displayedShortURL {
            UIPasteboard.general.string = url
            let alert = UIAlertController(title: nil, message: "URL copied to clipboard.", preferredStyle: .alert)
            self.present(alert, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        if let url = URL(string: displayedShortURL!) {
            DispatchQueue.main.async { [self] in
                let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                present(activityController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func qrButtonPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.Segue.showQR, sender: nil)
    }
    
}

//MARK: - UITextField Delegate
extension ShortURLViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        userPressedGo()
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateUI()
    }
    

}

//MARK: - NetworkingManager Delegate
extension ShortURLViewController: NetworkingManagerDelegate {
    
    func deviceDoesNotHaveInternetConnection() {
        DispatchQueue.main.async { [self] in
            changeDisplayedResultView(named: .noInternetConnection)
        }
    }
    
    func serverDidReturnSuccessTrue(_ recievedURL: URLModel) {
        DispatchQueue.main.async { [self] in
            displayedURL = recievedURL.full
            displayedShortURL = recievedURL.url
            updateUI()
            changeDisplayedResultView(named: .successTrue)
        }
    }
    
    func serverDidReturnSuccessFalse() {
        DispatchQueue.main.async { [self] in
            changeDisplayedResultView(named: .successFalse)
        }
    }

}

//MARK: - UITableView Datasource
extension ShortURLViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localDataManager.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = localDataManager.items[indexPath.row].full
        cell.backgroundColor = UIColor(named: "viewBackgroundColorSet")

        return cell
    }
}

//MARK: - UITableView Delegate
extension ShortURLViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        bottomUrlTextField.text =  localDataManager.items[indexPath.row].full
        userPressedGo()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            K.context.delete(localDataManager.items[indexPath.row])
            localDataManager.saveData()
            updateUI()
        }
    }
    
}
