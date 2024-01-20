import UIKit
import Combine

class NoteImageView: UIView {
    private lazy var noteImage: UIImageView = {
        let image = UIImageView()
        image.backgroundColor = .systemGray6
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        return image
    }()

    private lazy var placeholderImage: UIImageView = {
        let image = UIImage(systemName: "plus.circle.fill")

        let view = UIImageView(image: image)
        view.isUserInteractionEnabled = true

        let tapGestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                                action: #selector(onPlaceholderImageTapped))
        tapGestureRecognizer.minimumPressDuration = 0
        view.addGestureRecognizer(tapGestureRecognizer)

        return view
    }()

    private var placeholderTouchAnimation: ViewTouchAnimation?

    private let imageTappedSubject = PassthroughSubject<Void, Never>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        placeholderTouchAnimation = ViewTouchAnimation(for: placeholderImage)
        addSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Publishers

extension NoteImageView {
    var imageTapped: AnyPublisher<Void, Never> {
        imageTappedSubject.eraseToAnyPublisher()
    }
}

// MARK: - Life cycle

extension NoteImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviewsConstraints()
    }
}

// MARK: - Subviews

extension NoteImageView {
    private func addSubviews() {
        addSubview(noteImage)
        addSubview(placeholderImage)
    }

    private func updateSubviewsConstraints() {
        noteImage.snp.makeConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }
        placeholderImage.snp.makeConstraints { maker in
            maker.center.equalToSuperview()
            maker.width.height.equalTo(75)
        }
    }
}

// MARK: - Image

extension NoteImageView {
    var image: UIImage? {
        get {
            noteImage.image
        }
        set {
            noteImage.image = newValue
        }
    }
}

// MARK: - Callbacks

extension NoteImageView {
    @objc func onPlaceholderImageTapped(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .began {
            placeholderTouchAnimation?.touch()
        } else if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            placeholderTouchAnimation?.untouch()
            imageTappedSubject.send()
        }
    }
}
