//
//  PhotosCollectionViewController.swift
//  CameraFilter-RxSwift
//
//  Created by Toshiyana on 2021/12/01.
//

import UIKit
import RxSwift
import Photos

class PhotosCollectionViewController: UICollectionViewController {

    // create PublishSubject
    // This can emit the value, and you can subscribe to this.
    // add private because I don't want to people to be using this subject
    private let selectedPhotoSubject = PublishSubject<UIImage>()
    
    // expose selectedPhotoSubject as an observable
    // Other ViewController can subscribe to this and get the information
    var selectedPhoto: Observable<UIImage> {
        return selectedPhotoSubject.asObservable()
    }
    
    // This will be putting all images once we enumerates.
    private var images = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        populatePhotos()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedAsset = self.images[indexPath.row]
        let manager = PHImageManager.default()
        
        // call requestImage two time:
        // one time: get thumbnails in collectionView(cellForItemAt)
        // two time: below.
        manager.requestImage(for: selectedAsset, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: nil) { [weak self] image, info in
            
            guard let info = info else { return }
            
            // DegratedImage or not (Thumbnail Image)
            let isDegratedImage = info["PHImageResultIsDegradedKey"] as! Bool
            
            // Original image will completely ignoring the thumbnail image
            if !isDegratedImage {
                
                if let image = image {
                    self?.selectedPhotoSubject.onNext(image)
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as? PhotoCollectionViewCell else {
            fatalError("PhotoCollectionViewCell is not found.")
        }
        
        let asset = self.images[indexPath.row] // not image data
        let manager = PHImageManager.default() // using manager, get image
        
        manager.requestImage(for: asset, targetSize: CGSize(width: 100, height: 100), contentMode: .aspectFit, options: nil) { image, _ in // already have the image, so ignore error parameter(= _ )
            
            DispatchQueue.main.async {
                // using main thread, update iamge
                cell.photoImageView.image = image
            }
        }
        
        return cell
    }
    
    private func populatePhotos() {
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            
            if status == .authorized {
                
                // access the photos from photo library
                let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
                
                assets.enumerateObjects { (object, count, stop) in
                    self?.images.append(object)
                }
                
                // by reversing images, enumerate through the image of putting the most recent image at the end
                self?.images.reverse()

                DispatchQueue.main.async {
                    // Using main thread, update collectionView
                    self?.collectionView.reloadData()
                }
            }
        }
    }
}
