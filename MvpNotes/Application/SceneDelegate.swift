import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var applicationCoordinator: ApplicationCoordinator?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        let navigationController = NavigationModuleFactory().module()

        applicationCoordinator = ApplicationCoordinator(navigationController: navigationController)
        applicationCoordinator?.run()

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
