import UIKit
import Combine
import PhotosUI

class NoteViewController: UIViewController {
    private lazy var verticalStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 10
        return stack
    }()

    private lazy var imageView: NoteImageView = {
        return NoteImageView()
    }()

    private lazy var descriptionText: UITextView = {
        let text = UITextView()
        text.delegate = self
        text.font = .systemFont(ofSize: 24)
        return text
    }()

    private var presenter: NotePresenter?
    private var subscriptions = Set<AnyCancellable>()

    private var imageChanged = false
    private var textChanged = false
}

// MARK: - Life cycle

extension NoteViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureNavigationItem()

        addSubviews()

        updateApplyItemButtonEnabled()

        imageView.imageTapped.sink { [weak self] in
            self?.showPhotoPicker()
        }.store(in: &subscriptions)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSubviewsConstraints()
    }
}

// MARK: - Initializators

extension NoteViewController {
    func initialize(model: NoteModel, presenter: NotePresenter?) {
        self.presenter = presenter

        let imageId = model.imageId
        DispatchQueue.global().async {
            let image = ImagesCache.shared[imageId]
            DispatchQueue.main.async { [weak self] in
                self?.imageView.image = image
            }
        }

        descriptionText.text = model.description
    }
}

// MARK: - Configurators

extension NoteViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
    }

    func configureNavigationItem() {
        let applyButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"),
                                              style: .plain,
                                              target: self,
                                              action: #selector(onApplyButtonItemTapped))
        navigationItem.rightBarButtonItem = applyButtonItem
        navigationItem.title = "Note"
    }
}

// MARK: - Subviews

extension NoteViewController {
    private func addSubviews() {
        view.addSubview(verticalStack)
        verticalStack.addArrangedSubview(imageView)
        verticalStack.addArrangedSubview(descriptionText)
    }

    private func updateSubviewsConstraints() {
        verticalStack.snp.makeConstraints { maker in
            maker.left.right.equalToSuperview().inset(16)
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        imageView.snp.makeConstraints { maker in
            maker.height.equalToSuperview().dividedBy(3)
        }
    }
}

// MARK: - UIBarButtonItem

extension NoteViewController {
    private func updateApplyItemButtonEnabled() {
        navigationItem.rightBarButtonItem?.isEnabled = imageChanged || textChanged
    }
}

// MARK: - Photo Picker

extension NoteViewController {
    private func showPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        present(picker, animated: true)
    }
}

// MARK: - UITextViewDelegate

extension NoteViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateApplyItemButtonEnabled()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let currentText = textView.text else {
            return true
        }

        let newLength = currentText.count + text.count - range.length

        textChanged = newLength > 0

        return newLength <= 100
    }
}

// MARK: - PHPickerViewControllerDelegate

extension NoteViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)

        guard let itemProvider = results.first?.itemProvider else {
            return
        }

        guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] item, error in
            if let error = error {
                print("NoteViewController: Load image error: \(error.localizedDescription)")
            } else if let image = item as? UIImage {
                DispatchQueue.main.async {
                    self?.imageView.image = image
                    self?.imageChanged = true
                    self?.updateApplyItemButtonEnabled()
                }
            }
        }
    }
}

// MARK: - Callbacks

extension NoteViewController {
    @objc func onApplyButtonItemTapped() {
        let image = imageView.image ?? UIImage()
        let description = descriptionText.text ?? ""
        presenter?.applyNote(image: image, imageChanged: imageChanged, description: description)
    }
}
