import UIKit

struct NavigationModuleFactory {
    func module() -> UINavigationController {
        let controller = UINavigationController()
        controller.navigationBar.prefersLargeTitles = true
        return controller
    }
}
