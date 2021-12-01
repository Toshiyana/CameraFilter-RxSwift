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
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
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
            
            self?.photoImageView.image = photo
            
            // don't forget to dispose not to happen memory leaks
        }).disposed(by: disposeBag)
    }

}

