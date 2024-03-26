//
//  ReviewImageViewController.swift
//  WeScanSampleProject
//
//  Created by Chawatvish Worrapoj on 8/1/2020
//  Copyright © 2020 WeTransfer. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

final class ReviewImageViewController: UIViewController {

    @IBOutlet private weak var imageView: UIImageView!
    var image: UIImage?
    private var rotationAngle = Measurement<UnitAngle>(value: 0, unit: .degrees)
 
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let image else { return }
        imageView.image = image
    }
    
    @objc func rotateImage() {
        rotationAngle.value += 90

        if rotationAngle.value == 360 {
            rotationAngle.value = 0
        }

        imageView.image = image?.rotated(by: rotationAngle) ?? image

    }
    @IBAction func rotateImage(_ sender: Any) {
        
        rotateImage()
    }
 
    
    
    @IBAction func MarkupBtn(_ sender: Any) {
        
    }
    
    
    @IBAction func filterButton(_ sender: Any) {
    }
    
}








