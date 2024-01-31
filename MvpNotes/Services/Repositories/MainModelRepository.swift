import Foundation

class MainModelRepository {
    func load() -> MainModel? {
        guard let url = url() else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let model = try JSONDecoder().decode(MainModel.self, from: data)
            return model
        } catch {
            print("MainModelRepository: load error: \(error)")
        }

        return nil
    }

    @discardableResult
    func save(model: MainModel) -> Bool {
        do {
            let data = try JSONEncoder().encode(model)

            guard let url = url() else {
                return false
            }

            try data.write(to: url)
        } catch {
            print("MainModelRepository: save error: \(error)")
        }

        return true
    }
}

// MARK: - Url

extension MainModelRepository {
    private func url() -> URL? {
        do {
            let cachesUrl = try FileManager.default.url(for: .cachesDirectory,
                                                        in: .userDomainMask,
                                                        appropriateFor: nil,
                                                        create: true)
            return cachesUrl.appendingPathComponent("notes")
        } catch {
            print("MainModelRepository: url error: \(error.localizedDescription)")
        }
        return nil
    }
}
