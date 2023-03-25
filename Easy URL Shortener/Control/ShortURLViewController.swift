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
    @IBOutlet weak var problemResultView: UIView!
    @IBOutlet weak var okResultView: UIView!
    
    @IBOutlet weak var okResultUrlLabel: UILabel!
    @IBOutlet weak var okResultShortUrlLabel: UILabel!
    
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var historyViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomUrlView: UIView!
    @IBOutlet weak var bottomBlurView: UIVisualEffectView!
    @IBOutlet weak var bottomUrlViewPasteButton: UIButton!
    @IBOutlet weak var bottomUrlViewCancelButton: UIButton!
    @IBOutlet weak var bottomUrlViewBotConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomUrlTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        networkingManager.delegate = self
        setUI()
        registerNotifications()
        updateUI()
    }
    
    
    //MARK: - Functions()
    
    private func setUI() {
        resultStackView.layer.cornerRadius = 10
        historyTableView.layer.cornerRadius = 10
        bottomUrlView.layer.cornerRadius = 10
        showCorrectResultView(named: K.ResultViewStatus.no)
    }
    
    private func updateUI() {
        localDataManager.loadData()
        if bottomUrlTextField.text == nil || bottomUrlTextField.text == "" {
            bottomUrlViewCancelButton.isHidden = true
            bottomUrlViewPasteButton.isHidden = false
        } else {
            bottomUrlViewCancelButton.isHidden = false
            bottomUrlViewPasteButton.isHidden = true
        }
        okResultUrlLabel.text = displayedURL
        okResultShortUrlLabel.text = displayedShortURL
        localDataManager.loadData()
        historyViewHeight.constant = CGFloat(localDataManager.items.count * 44)
        historyTableView.reloadData()
    }
    
    private func showCorrectResultView(named: String) {
        noResultView.isHidden = true
        waitResultView.isHidden = true
        problemResultView.isHidden = true
        okResultView.isHidden = true
        UIView.animate(withDuration: 0.3) { [self] in
            switch named {
            case K.ResultViewStatus.no:
                noResultView.isHidden = false
            case K.ResultViewStatus.wait:
                waitResultView.isHidden = false
            case K.ResultViewStatus.problem:
                problemResultView.isHidden = false
            case K.ResultViewStatus.ok:
                okResultView.isHidden = false
            default:
                break
            }
        }
        
    }
    
    private func userPressedGo() {
        print("userPressedGo")
        showCorrectResultView(named: K.ResultViewStatus.wait)
        if let filledURL = bottomUrlTextField.text {
            networkingManager.performRequest(filledURL)
        }
        self.view.endEditing(true)
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            bottomUrlViewBotConstraint.constant = 0 + keyboardHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.bottomView.backgroundColor = UIColor(named: "keyboardBackgroundColor")
                self.bottomBlurView.isHidden = true
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomUrlViewBotConstraint.constant = 83
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.bottomView.backgroundColor = .clear
            self.bottomBlurView.isHidden = false
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    //MARK: - IBAction Buttons
    
    @IBAction func bottomUrlViewCancelButtonPressed(_ sender: Any) {
        bottomUrlTextField.text = ""
        updateUI()
        bottomUrlTextField.becomeFirstResponder()
    }
    
    @IBAction func bottomUrlViewPasteButtonPressed(_ sender: Any) {
        if let clipboardString = UIPasteboard.general.string {
            bottomUrlTextField.text = clipboardString
            updateUI()
            userPressedGo()
        }
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
    
    func serverCouldntBeReached(_ recievedError: Error) {
        print("errrr")
    }
    
    
    
    func serverDidShortURL(_ recievedURL: URLModel) {
        DispatchQueue.main.async { [self] in
            displayedURL = recievedURL.full
            displayedShortURL = recievedURL.url
            let newItem = SearchedItem(context: K.context)
            newItem.full = recievedURL.full
            newItem.url = recievedURL.url
            newItem.date = Date()
            localDataManager.items.append(newItem)
            localDataManager.saveData()
            updateUI()
            
            showCorrectResultView(named: K.ResultViewStatus.ok)
        }
    }
    
    func serverDidReturnError(_ recievedError: Error) {
        print(recievedError)
        showCorrectResultView(named: K.ResultViewStatus.problem)
    }
}

//MARK: - UITableView Datasource
extension ShortURLViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberToReturn: Int?
        if localDataManager.items.count == 0 {
            numberToReturn = 1
        } else {
            numberToReturn = localDataManager.items.count
        }
        
        return numberToReturn!
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if localDataManager.items.count == 0 {
            cell.textLabel?.text = "Empty history"
        } else {
            cell.textLabel?.text = localDataManager.items[indexPath.row].full

        }
        return cell
    }
}

//MARK: - UITableView Delegate
extension ShortURLViewController: UITableViewDelegate {
    
}
