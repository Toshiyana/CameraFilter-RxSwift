//
//  FilterService.swift
//  CameraFilter-RxSwift
//
//  Created by Toshiyana on 2021/12/01.
//

import Foundation
import UIKit
import CoreImage

class FilterService {
    
    private var context: CIContext
    
    init() {
        context = CIContext()
    }
    
    func applyFilter(to inputImage: UIImage, completion: @escaping ((UIImage) -> ())) {
        
        let filter = CIFilter(name: "CICMYKHalftone")!
        filter.setValue(5.0, forKey: kCIInputWidthKey)
        
        if let sourceImage = CIImage(image: inputImage) {
            
            filter.setValue(sourceImage, forKey: kCIInputImageKey)
            
            if let cgimg = context.createCGImage(filter.outputImage!, from: filter.outputImage!.extent) {
                let processedImage = UIImage(cgImage: cgimg, scale: inputImage.scale, orientation: inputImage.imageOrientation)

                completion(processedImage)
            }
        }
        
    }
}
