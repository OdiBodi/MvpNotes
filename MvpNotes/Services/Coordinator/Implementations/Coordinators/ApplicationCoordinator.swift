import Combine
import UIKit

class ApplicationCoordinator: BaseCoordinator<Void, Never> {
    private let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func run() {
        openMainModule()
    }
}

// MARK: - Modules

extension ApplicationCoordinator {
    private func openMainModule() {
        let (mainView, mainPresenter) = MainModuleFactory().module()

        mainPresenter.completion.sink { [weak self] (noteIndex, noteModel) in
            self?.openNoteModule(mainPresenter: mainPresenter, noteIndex: noteIndex, noteModel: noteModel)
        }.store(in: &subscriptions)

        navigationController.pushViewController(mainView, animated: false)
    }

    private func openNoteModule(mainPresenter: MainPresenter, noteIndex: Int, noteModel: NoteModel) {
        let (noteView, notePresenter) = NoteModuleFactory().module(noteIndex: noteIndex, model: noteModel)

        var subscription: AnyCancellable!
        subscription = notePresenter.completion.sink { [weak self] (noteIndex, noteModel) in
            mainPresenter.updateNote(noteIndex: noteIndex, noteModel: noteModel)
            self?.navigationController.popViewController(animated: true)
            self?.subscriptions.remove(subscription)
        }
        subscriptions.insert(subscription)

        navigationController.show(noteView, sender: mainPresenter)
    }
}
