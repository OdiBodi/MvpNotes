import Foundation
import UIKit

class MainPresenter: BaseCoordinatorModule<(Int, NoteModel), Never> {
    private var model: MainModel
    private weak var view: MainViewController?

    init(model: MainModel, view: MainViewController) {
        self.model = model
        self.view = view
    }
}

// MARK: - Note

extension MainPresenter {
    func openNote(noteIndex: Int, navigationController: UINavigationController) {
        let noteModel = noteIndex > -1 ? model.notes[noteIndex] : NoteModel()
        completionSubject.send((noteIndex, noteModel))
    }

    func addNote(navigationController: UINavigationController) {
        openNote(noteIndex: -1, navigationController: navigationController)
    }

    func removeNote(noteIndex: Int) {
        let imageId = model.notes[noteIndex].imageId

        model.notes.remove(at: noteIndex)

        DispatchQueue.global().async { [model] in
            ImagesCache.shared[imageId] = nil
            MainModelRepository().save(model: model)
        }
    }

    func updateNote(noteIndex: Int, noteModel: NoteModel) {
        guard let view else {
            return
        }

        if noteIndex > -1 {
            model.notes[noteIndex] = noteModel
        } else {
            model.notes.append(noteModel)
        }

        view.updateModel(model)

        DispatchQueue.global().async { [weak self] in
            guard let self else {
                return
            }
            MainModelRepository().save(model: self.model)
        }
    }
}
