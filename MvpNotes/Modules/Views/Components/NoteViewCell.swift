import UIKit
import Combine

class NoteViewCell: UITableViewCell {
    private lazy var horizontalStack = initializeHorizontalStack()
    private lazy var iconView = initializeIconView()
    private lazy var iconImage = initializeIconImage()
    private lazy var descriptionLabel = initializeDescriptionLabel()

    private var subscriptions = Set<AnyCancellable>()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - Life cycle

extension NoteViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSubviewsConstraints()
    }
}

// MARK: - Initializators

extension NoteViewCell {
    func initialize(model: NoteModel) {
        subscriptions.removeAll()
        descriptionLabel.text = model.description
        DispatchQueue.global().async { [weak self] in
            self?.changeImage(by: model)
        }
    }
}

// MARK: - Subviews

extension NoteViewCell {
    private func initializeHorizontalStack() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 10
        stack.layoutMargins = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 32)
        stack.isLayoutMarginsRelativeArrangement = true
        return stack
    }

    private func initializeIconView() -> UIView {
        UIView()
    }

    private func initializeIconImage() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 8
        return view
    }

    private func initializeDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 3
        return label
    }

    private func addSubviews() {
        contentView.addSubview(horizontalStack)

        horizontalStack.addArrangedSubview(iconView)
        horizontalStack.addArrangedSubview(descriptionLabel)

        iconView.addSubview(iconImage)
    }

    private func updateSubviewsConstraints() {
        horizontalStack.snp.updateConstraints { maker in
            maker.left.right.top.bottom.equalToSuperview()
        }
        iconView.snp.makeConstraints { maker in
            maker.width.equalTo(80)
        }
        iconImage.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview()
            maker.top.bottom.equalToSuperview().inset(12)
        }
    }
}

// MARK: - Image

extension NoteViewCell {
    private func changeImage(by model: NoteModel) {
        let imageId = model.imageId
        if let image = ImagesCache.shared[imageId] {
            DispatchQueue.main.async { [weak self] in
                self?.iconImage.image = image
            }
        } else {
            ImagesCache.shared.imageAdded.filter { (id, _) in
                id == model.imageId
            }.sink { [weak self] (_, image) in
                DispatchQueue.main.async {
                    self?.iconImage.image = image
                }
                self?.subscriptions.removeAll()
            }.store(in: &subscriptions)
        }
    }
}
