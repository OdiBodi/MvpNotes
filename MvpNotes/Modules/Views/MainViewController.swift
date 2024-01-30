import UIKit
import SnapKit

class MainViewController: UIViewController {
    private lazy var notesView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.dataSource = self
        table.delegate = self
        table.register(NoteViewCell.self, forCellReuseIdentifier: "NoteViewCell")
        table.separatorInset = UIEdgeInsets(top: 0, left: 106, bottom: 0, right: 0)
        return table
    }()

    private var presenter: MainPresenter?
    private var notes: [NoteModel]?
}

// MARK: - Life cycle

extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureNavigationItem()
        addSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSubviewsConstraints()
    }
}

// MARK: - Initializators

extension MainViewController {
    func initialize(presenter: MainPresenter?) {
        self.presenter = presenter
    }
}

// MARK: - Configurators

extension MainViewController {
    func configureView() {
        view.backgroundColor = .systemBackground
    }

    func configureNavigationItem() {
        let addItem = UIBarButtonItem(barButtonSystemItem: .add,
                                      target: self,
                                      action: #selector(onAddBarButtonItemTapped))
        navigationItem.rightBarButtonItem = addItem
        navigationItem.title = "Notes"
    }
}

// MARK: - Subviews

extension MainViewController {
    private func addSubviews() {
        view.addSubview(notesView)
    }

    private func updateSubviewsConstraints() {
        notesView.snp.makeConstraints { maker in
            maker.left.top.right.equalToSuperview()
            maker.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

// MARK: - Model

extension MainViewController {
    func updateModel(_ model: MainModel) {
        self.notes = model.notes
        notesView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let index = indexPath.item
        let model = notes?[index] ?? NoteModel(imageId: "ERROR", description: "ERROR")

        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteViewCell", for: indexPath) as! NoteViewCell
        cell.accessoryType = .disclosureIndicator
        cell.initialize(model: model)

        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = indexPath.item
            notes?.remove(at: index)
            presenter?.removeNote(noteIndex: index)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let navigationController = navigationController else {
            return
        }

        let index = indexPath.item
        presenter?.openNote(noteIndex: index, navigationController: navigationController)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
}

// MARK: - Callbacks

extension MainViewController {
    @objc func onAddBarButtonItemTapped() {
        guard let navigationController = navigationController else {
            return
        }
        presenter?.addNote(navigationController: navigationController)
    }
}
