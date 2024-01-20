import UIKit

struct NoteModuleFactory {
    func module(noteIndex: Int, model: NoteModel) -> (NoteViewController, NotePresenter) {
        let view = NoteViewController()
        let presenter = NotePresenter(noteIndex: noteIndex, model: model, view: view)

        view.initialize(model: model, presenter: presenter)

        return (view, presenter)
    }
}
