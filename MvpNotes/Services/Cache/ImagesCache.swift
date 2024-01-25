import Foundation
import UIKit
import Combine

class ImagesCache {
    static let shared = ImagesCache()

    private let cache = NSCache<NSString, UIImage>()

    private let imageAddedSubject = PassthroughSubject<(id: String, image: UIImage), Never>()

    private init() { }

    subscript(id: String) -> UIImage? {
        get {
            cached(for: id)
        }
        set (image) {
            cache(for: id, image: image)
        }
    }
}

// MARK: - Publishers

extension ImagesCache {
    var imageAdded: AnyPublisher<(id: String, image: UIImage), Never> {
        imageAddedSubject.eraseToAnyPublisher()
    }
}

// MARK: - Cache

extension ImagesCache {
    private func cached(for id: String) -> UIImage? {
        if let cachedImage = cache.object(forKey: id as NSString) {
            return cachedImage
        }

        guard let url = imageUrl(id: id) else {
            return nil
        }

        if let image = UIImage(contentsOfFile: url.path) {
            cache.setObject(image, forKey: id as NSString)
            return image
        }

        return nil
    }

    private func cache(for id: String, image: UIImage?) {
        guard let url = imageUrl(id: id) else {
            return
        }

        guard cache.object(forKey: id as NSString) == nil else {
            if image == nil {
                cache.removeObject(forKey: id as NSString)
                removeImageFile(url: url)
            }
            return
        }

        guard let image = image else {
            return
        }

        guard let imageData = image.pngData() else {
            return
        }

        do {
            try imageData.write(to: url)
        } catch {
            print("ImagesCache: cache error: \(error)")
        }

        cache.setObject(image, forKey: id as NSString)

        imageAddedSubject.send((id, image))
    }
}

// MARK: - File

extension ImagesCache {
    func removeImageFile(url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("ImagesCache: removeImageFile error: \(error)")
        }
    }
}

// MARK: - Url

extension ImagesCache {
    private func imageUrl(id: String) -> URL? {
        do {
            let fileManager = FileManager.default

            let cachesUrl = try fileManager.url(for: .cachesDirectory,
                                                in: .userDomainMask,
                                                appropriateFor: nil,
                                                create: true)
            let imageUrl = cachesUrl.appendingPathComponent("images")

            if !fileManager.fileExists(atPath: imageUrl.path) {
                try fileManager.createDirectory(at: imageUrl, withIntermediateDirectories: true)
            }

            return imageUrl.appendingPathComponent(id)
        } catch {
            print("ImagesCache: imageUrl error: \(error.localizedDescription)")
        }

        return nil
    }
}
