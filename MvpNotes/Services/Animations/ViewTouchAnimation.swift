import UIKit

class ViewTouchAnimation {
    private let view: UIView

    private let touchDuration: TimeInterval
    private let untouchDuration: TimeInterval
    private let touchScale: CGFloat

    private var animator: UIViewPropertyAnimator?

    init(for view: UIView,
         touchDuration: TimeInterval = 0.1,
         untouchDuration: TimeInterval = 0.2,
         touchScale: CGFloat = 0.9) {
        self.view = view
        self.touchDuration = touchDuration
        self.untouchDuration = untouchDuration
        self.touchScale = touchScale
    }

    func touch() {
        animate(duration: touchDuration, scale: touchScale)
    }

    func untouch() {
        animate(duration: untouchDuration, scale: 1)
    }

    private func animate(duration: TimeInterval, scale: CGFloat) {
        animator?.stopAnimation(true)

        animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) { [weak self] in
            self?.view.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        animator?.addCompletion { [weak self] _ in
            self?.animator = nil
        }

        animator?.startAnimation()
    }
}
