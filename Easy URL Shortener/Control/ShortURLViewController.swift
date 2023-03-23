//
//  ViewController.swift
//  Easy URL Shortener
//
//  Created by David Třešňák on 21.03.2023.
//

import UIKit

class ShortURLViewController: UIViewController {

    var networkingManager = NetworkingManager()
    var displayedURL: String?
    var displayedShortURL: String?
    
    @IBOutlet weak var resultStackView: UIStackView!
    @IBOutlet weak var noResultView: UIView!
    @IBOutlet weak var problemResultView: UIView!
    @IBOutlet weak var okResultView: UIView!
    
    @IBOutlet weak var okResultUrlLabel: UILabel!
    @IBOutlet weak var okResultShortUrlLabel: UILabel!
    
    @IBOutlet weak var historyView: UIView!
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
        historyView.layer.cornerRadius = 10
        bottomUrlView.layer.cornerRadius = 10
        noResultView.isHidden = false
        problemResultView.isHidden = false
        okResultView.isHidden = false
    }
    
    private func updateUI() {
        if bottomUrlTextField.text == nil || bottomUrlTextField.text == "" {
            bottomUrlViewCancelButton.isHidden = true
            bottomUrlViewPasteButton.isHidden = false
        } else {
            bottomUrlViewCancelButton.isHidden = false
            bottomUrlViewPasteButton.isHidden = true
        }
        okResultUrlLabel.text = displayedURL
        okResultShortUrlLabel.text = displayedShortURL
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
        }
    }
    
    
    
}

//MARK: - UITextField Delegate
extension ShortURLViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let filledURL = bottomUrlTextField.text {
            networkingManager.performRequest(filledURL)
        }
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        updateUI()
    }
    

}

//MARK: - NetworkingManager Delegate
extension ShortURLViewController: NetworkingManagerDelegate {
    func serverDidShortURL(_ recievedURL: URLModel) {
        DispatchQueue.main.async { [self] in
            displayedURL = recievedURL.url
            displayedShortURL = recievedURL.full
            updateUI()
        }
        
        print("URL: \(displayedURL), ShortURL: \(displayedShortURL)")
    }
    
    func serverDidReturnError(_ recievedError: Error) {
        print(recievedError)
    }
}

