//
//  DiscoverBisViewController.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 05/05/2022.
//

import UIKit
import RMModel

final class DiscoverBisViewController: UIViewController {
    private enum Constants {
        static let spacing = CGFloat(10)
        static let layoutMargin = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
    }

    // MARK: - Properties

    private let presenter: DiscoverBisViewPresenter
    private let navigator: DiscoverBisViewNavigator

    private var initialCollectionViewContentOffSet: CGPoint?

    private weak var collectionView: UICollectionView!
    private weak var refreshControl: UIRefreshControl!

    private var displayedSection: [Section] = []

    // MARK: - Initializers

    init(presenter: DiscoverBisViewPresenter, navigator: DiscoverBisViewNavigator) {
        self.presenter = presenter
        self.navigator = navigator

        super.init(nibName: nil, bundle: nil)

        self.tabBarItem = UITabBarItem(title: "Discover Bis", image: UIImage(systemName: "house.fill"), tag: 4)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()

        presenter.attachView(self)
        presenter.fetchData()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if initialCollectionViewContentOffSet == nil {
            initialCollectionViewContentOffSet = collectionView.contentOffset
        }
    }

    @objc
    private func pullToRefreshAction(_ sender: UIButton) {
        refreshControl.beginRefreshing()
        presenter.fetchData()
    }

    private func removeSectionIfNeeded(_ section: Section) {
        guard let index = displayedSection.firstIndex(of: section) else {
            return
        }

        displayedSection.remove(at: index)
        collectionView.reloadData()
    }

    private func addSectionIfNeeded(_ section: Section) {
        if !displayedSection.contains(section) {
            displayedSection.append(section)
            displayedSection.sort()
        }

        collectionView.reloadData()
    }

    private func setupView() {
        navigationItem.title = "Rick & Morty"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        view.layoutMargins = Constants.layoutMargin

        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 20

        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.backgroundColor = view.backgroundColor

        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.registerReusableItem(CharacterContainerCollectionViewCell.self)
        collectionView.registerReusableItem(LocationDiscoverCollectionViewCell.self)
        collectionView.registerReusableItem(EpisodeDiscoverCollectionViewCell.self)
        collectionView.register(TitleSupplementaryView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TitleSupplementaryView.reuseIdentifier)

        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action: #selector(pullToRefreshAction(_:)),
                                 for: .valueChanged)
        collectionView.refreshControl = refreshControl

        view.addSubview(collectionView)

        self.refreshControl = refreshControl
        self.collectionView = collectionView
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

extension DiscoverBisViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch displayedSection[section] {
        case .locations:
            return .init(top: 20, left: 20, bottom: 20, right: 20)
        case .characters:
            return .init(top: 20, left: 20, bottom: 20, right: 20)
        case .episodes:
            return .init(top: 20, left: 20, bottom: 20, right: 20)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let inset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let cellMaxWidth = collectionView.bounds.width - (inset.left + inset.right)

        switch displayedSection[indexPath.section] {
        case .locations:
            return .init(width: cellMaxWidth - Constants.spacing, height: 200)
        case .characters:
            return .init(width: collectionView.bounds.width, height: 220)
        case .episodes:
            return .init(width: cellMaxWidth - Constants.spacing, height: 100)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.bounds.width - (Constants.layoutMargin.left + Constants.layoutMargin.right)
        return CGSize(width: width, height: 80)
    }
}

extension DiscoverBisViewController: UICollectionViewDataSource {
    enum Section: Int, Comparable {
        static func < (lhs: DiscoverBisViewController.Section, rhs: DiscoverBisViewController.Section) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }

        case locations
        case characters
        case episodes

        var headerTitle: String? {
            switch self {
            case .characters:
                return "Characters"
            case .episodes:
                return "New episodes"
            case .locations:
                return "Discover some locations"
            }
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return displayedSection.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = displayedSection[indexPath.section]
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleSupplementaryView.reuseIdentifier, for: indexPath) as! TitleSupplementaryView
        header.configure(text: section.headerTitle)
        return header
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch displayedSection[section] {
        case .characters:
            return 1
        case .locations:
            return presenter.locations.count
        case .episodes:
            return presenter.episodes.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch displayedSection[indexPath.section] {
        case .characters:
            let cell = collectionView.dequeueReusableItem(CharacterContainerCollectionViewCell.self, at: indexPath)
            cell.characters = presenter.characters
            return cell
        case .locations:
            let cell = collectionView.dequeueReusableItem(LocationDiscoverCollectionViewCell.self, at: indexPath)
            cell.configure(location: presenter.locations[indexPath.item])
            return cell
        case .episodes:
            let cell = collectionView.dequeueReusableItem(EpisodeDiscoverCollectionViewCell.self, at: indexPath)
            cell.configure(episode: presenter.episodes[indexPath.item])
            return cell
        }
    }
}

extension DiscoverBisViewController: DiscoverBisViewPresenterDelegate {
    func discoverViewPresenterStartLoading(_ presenter: DiscoverBisViewPresenter) {

    }

    func discoverViewPresenterFinishedLoading(_ presenter: DiscoverBisViewPresenter) {
        refreshControl.endRefreshing()
    }

    func discoverViewPresenterdidReceiveCharacters(_ presenter: DiscoverBisViewPresenter) {
        if presenter.characters.isEmpty {
            removeSectionIfNeeded(.characters)
        } else {
            addSectionIfNeeded(.characters)
        }
    }

    func discoverViewPresenterdidReceiveEpisodes(_ presenter: DiscoverBisViewPresenter) {
        if presenter.episodes.isEmpty {
            removeSectionIfNeeded(.episodes)
        } else {
            addSectionIfNeeded(.episodes)
        }
    }

    func discoverViewPresenterdidReceiveLocations(_ presenter: DiscoverBisViewPresenter) {
        if presenter.locations.isEmpty {
            removeSectionIfNeeded(.locations)
        } else {
            addSectionIfNeeded(.locations)
        }
    }

    func discoverViewPresenter(_ presenter: DiscoverBisViewPresenter, didReceiveError error: Error) {
        navigator.navigate(to: .error(error))
    }
}
