//
//  ViewController.swift
//  Easy URL Shortener
//
//  Created by David Třešňák on 21.03.2023.
//

import UIKit

class ShortURLViewController: UIViewController {

    @IBOutlet weak var resultStackView: UIStackView!
    
    @IBOutlet weak var noResultView: UIView!
    
    @IBOutlet weak var problemResultView: UIView!
    
    @IBOutlet weak var okResultView: UIView!
    
    @IBOutlet weak var historyView: UIView!
    
    @IBOutlet weak var urlFieldView: UIView!
    
    @IBOutlet weak var bottomViewBotConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        resultStackView.layer.cornerRadius = 10
        historyView.layer.cornerRadius = 10
        urlFieldView.layer.cornerRadius = 10
        noResultView.isHidden = false
        problemResultView.isHidden = false
        okResultView.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
            bottomViewBotConstraint.constant = 0 + keyboardHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        bottomViewBotConstraint.constant = 83
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

}

