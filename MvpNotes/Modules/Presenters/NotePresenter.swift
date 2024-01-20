import UIKit

class NotePresenter: BaseCoordinatorModule<(Int, NoteModel), Never> {
    private let noteIndex: Int
    private let model: NoteModel
    private let view: NoteViewController

    init(noteIndex: Int, model: NoteModel, view: NoteViewController) {
        self.noteIndex = noteIndex
        self.model = model
        self.view = view
    }
}

// MARK: - Note

extension NotePresenter {
    func applyNote(image: UIImage, imageChanged: Bool, description: String) {
        let oldImageId = model.imageId
        var newImageId = ""

        if oldImageId.isEmpty || imageChanged {
            newImageId = UUID().uuidString
            DispatchQueue.global().async {
                ImagesCache.shared[oldImageId] = nil
                ImagesCache.shared[newImageId] = image
            }
        } else {
            newImageId = model.imageId
        }

        let newModel = NoteModel(imageId: newImageId, description: description)
        completionSubject.send((noteIndex, newModel))
    }
}
