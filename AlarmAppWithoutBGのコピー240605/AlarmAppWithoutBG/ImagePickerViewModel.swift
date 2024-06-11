//
//  ImagePickerViewModel.swift
//  AlarmAppWithoutBG
//
//  Created by 小松野蒼 on 2024/04/22.
//

import SwiftUI
import PhotosUI

class ImagePickerViewModel: ObservableObject {
    @Published var selectedImage: UIImage? = UIImage(systemName: "photo") {
        didSet {
            guard let selectedImage = selectedImage else { return }
            ImageStorageManager.shared.saveImage(selectedImage)
        }
    }

    init() {
        self.selectedImage = ImageStorageManager.shared.loadImage()
    }

    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        // iOS 13以降で安全にrootViewControllerにアクセスする方法
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        
        rootViewController.present(picker, animated: true, completion: nil)
    }

}

extension ImagePickerViewModel: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)

        guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { image, error in
            DispatchQueue.main.async {
                if let image = image as? UIImage {
                    self.selectedImage = image
                }
            }
        }
    }
}

