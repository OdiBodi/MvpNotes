import UIKit

struct MainModuleFactory {
    func module() -> (view: MainViewController, presenter: MainPresenter) {
        let model = MainModelRepository().load() ?? MainModel()
        let view = MainViewController()
        let presenter = MainPresenter(model: model, view: view)

        view.initialize(presenter: presenter)
        view.updateModel(model)

        return (view, presenter)
    }
}
