//
//  ImageStorageManager.swift
//  AlarmAppWithoutBG
//
//  Created by 小松野蒼 on 2024/04/22.
//

import UIKit

class ImageStorageManager {
    static let shared = ImageStorageManager()
    
    private let fileManager = FileManager.default
    private let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let imagePath = "backgroundImage.png"
    
    func saveImage(_ image: UIImage) {
        let fileURL = documentDirectory.appendingPathComponent(imagePath)
        guard let data = image.pngData() else { return }
        do {
            try data.write(to: fileURL)
            UserDefaults.standard.set(imagePath, forKey: "backgroundImage")
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    func loadImage() -> UIImage? {
        guard let savedImagePath = UserDefaults.standard.string(forKey: "backgroundImage"),
              let fileURL = URL(string: savedImagePath, relativeTo: documentDirectory) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            return UIImage(data: data)
        } catch {
            print("Failed to load image: \(error)")
            return nil
        }
    }
}
