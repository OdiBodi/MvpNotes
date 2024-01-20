struct NoteModel: Codable {
    let imageId: String
    let description: String
}

// MARK: - Initializators

extension NoteModel {
    init() {
        imageId = ""
        description = ""
    }
}
