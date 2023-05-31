//
//  QRViewController.swift
//  Easy URL Shortener
//
//  Created by David Třešňák on 26.03.2023.
//

import UIKit
import CoreImage

class QRViewController: UIViewController {
    
    var displayedShortURL: String?
    
    @IBOutlet weak var qrImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setQRImage()
    }
    
    
    func setQRImage() {
        if let shortURL = displayedShortURL {
                let qrImage = generateQRCode(from: shortURL)
                qrImageView.image = qrImage
            
        }
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")
            if let output = filter.outputImage {
                let invertFilter = CIFilter(name: "CIColorInvert")
                invertFilter?.setValue(output, forKey: kCIInputImageKey)
                let maskedQR = invertFilter?.outputImage?.transformed(by: CGAffineTransform(scaleX: 15, y: 15))
                let maskFilter = CIFilter(name: "CIMaskToAlpha")
                maskFilter?.setValue(maskedQR, forKey: kCIInputImageKey)
                if let maskedOutput = maskFilter?.outputImage {
                    return UIImage(ciImage: maskedOutput)
                }
            }
        }
        return nil
    }
}
