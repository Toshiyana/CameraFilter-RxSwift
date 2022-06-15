//
//  FilterService.swift
//  CameraFilter-RxSwift
//
//  Created by Toshiyana on 2021/12/01.
//

import UIKit
import CoreImage
import RxSwift

class FilterService {
    
    private var context: CIContext
    
    init() {
        context = CIContext()
    }
    
    // we can be instead of returning a processed image, we will return an observable of UIImage.
    func applyFilter(to inputImage: UIImage) -> Observable<UIImage> {
        
        // Using create function, create observable
        return Observable<UIImage>.create { observer in
            
            self.applyFilter(to: inputImage) { filteredImage in
                observer.onNext(filteredImage)
            }
            
            return Disposables.create()
        }
    }
    
    // This function is called in "func applyFilter(to inputImage: UIImage) -> Observable<UIImage> "
    private func applyFilter(to inputImage: UIImage, completion: @escaping ((UIImage) -> ())) {
        
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
