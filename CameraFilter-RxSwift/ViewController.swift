//
//  ViewController.swift
//  CameraFilter-RxSwift
//
//  Created by Toshiyana on 2021/11/30.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var applyFilterButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        applyFilterButton.isHidden = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let navC = segue.destination as? UINavigationController,
              let photosCVC = navC.viewControllers.first as? PhotosCollectionViewController
        else {
                  fatalError("Segue destination is not found.")
              }
        
        // selectedPhoto is observable (defined it in PhotosCVC)
        // by subscribing selectedPhoto, get image
        photosCVC.selectedPhoto.subscribe(onNext: { [weak self] photo in
            
            DispatchQueue.main.async {
                self?.updateUI(with: photo)
            }
            
            // don't forget to dispose not to happen memory leaks
        }).disposed(by: disposeBag)
    }
    
    private func updateUI(with image: UIImage) {
        self.photoImageView.image = image
        self.applyFilterButton.isHidden = false
    }
    
    @IBAction private func applyFilterButtonPressed() {
        
        guard let sourceImage = photoImageView.image else {
            return
        }

        // Use observable in filtering
        // by subscribing filteredImage, get image
        FilterService().applyFilter(to: sourceImage)
            .subscribe(onNext: { filteredImage in
                
                DispatchQueue.main.async {
                    self.photoImageView.image = filteredImage
                }
                
            }).disposed(by: disposeBag)
        
        // Not use observable in filtering
//        FilterService().applyFilter(to: sourceImage) { filteredImage in
//
//            DispatchQueue.main.async {
//                self.photoImageView.image = filteredImage
//            }
//        }
        
    }

}

