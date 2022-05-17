//
//  DiscoverViewController.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

final class DiscoverViewController: UIViewController {
    private enum Constants {
        static let spacing = CGFloat(20)
        static let layoutMargin = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
    }

    // MARK: - Properties

    private let presenter: DiscoverViewPresenter
    private let navigator: DiscoverViewNavigator

    private weak var collectionView: UICollectionView!
    private var activityIndicatorView: UIActivityIndicatorView!

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    // MARK: - Initializers

    init(presenter: DiscoverViewPresenter, navigator: DiscoverViewNavigator) {
        self.presenter = presenter
        self.navigator = navigator

        super.init(nibName: nil, bundle: nil)

        self.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(systemName: "house"), tag: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupDatasource()
        setupConstraints()

        presenter.fetchData()
        presenter.attachView(self)
    }
}

extension DiscoverViewController {
    enum Section: Int, CaseIterable {
        case locations
        case characters
        case episodes

        var headerTitle: String {
            switch self {
            case .characters:
                return "Meet new characters"
            case .episodes:
                return "Watch new episodes"
            case .locations:
                return "Visit some locations"
            }
        }
    }

    struct Item: Hashable {
        let id = UUID()
        let character: Character?
        let episode: Episode?
        let location: Location?
    }

    private func setupView() {
        navigationItem.title = "Rick & Morty"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemBackground
        view.layoutMargins = Constants.layoutMargin

        let layout = createCollectionLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = view.backgroundColor
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self

        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.center = view.center
        activityIndicatorView.startAnimating()

        view.addSubview(collectionView)
        view.addSubview(activityIndicatorView)

        self.collectionView = collectionView
        self.activityIndicatorView = activityIndicatorView
    }

    private func createCollectionLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = Section(rawValue: sectionIndex) else {
                return nil
            }

            switch sectionKind {
            case .characters:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                       heightDimension: .absolute(200))

                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
                group.interItemSpacing = .fixed(Constants.spacing)

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .estimated(44))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                                elementKind: TitleMoreSupplementaryView.reuseIdentifier,
                                                                                alignment: .top)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = Constants.spacing
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                section.boundarySupplementaryItems = [sectionHeader]
                return section

            case .episodes:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                       heightDimension: .absolute(200))

                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 2)
                group.interItemSpacing = .fixed(Constants.spacing)

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .estimated(44))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: TitleMoreSupplementaryView.reuseIdentifier,
                    alignment: .top)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = Constants.spacing
                section.orthogonalScrollingBehavior = .groupPaging
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                section.boundarySupplementaryItems = [sectionHeader]
                return section

            case .locations:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                       heightDimension: .absolute(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .estimated(44))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: TitleMoreSupplementaryView.reuseIdentifier,
                    alignment: .top)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = Constants.spacing
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                section.orthogonalScrollingBehavior = .groupPaging
                section.boundarySupplementaryItems = [sectionHeader]
                return section
            }
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

extension DiscoverViewController {
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

extension DiscoverViewController {
    private func setupDatasource() {
        let headerSectionRegistration: UICollectionView.SupplementaryRegistration<TitleMoreSupplementaryView> = UICollectionView.SupplementaryRegistration
        <TitleMoreSupplementaryView>(elementKind: TitleMoreSupplementaryView.reuseIdentifier) { (supplementaryView, _, indexPath) in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }
            supplementaryView.configure(text: section.headerTitle)
            supplementaryView.delegate = self
            supplementaryView.indexPath = indexPath
        }

        let characterCellRegistration = UICollectionView.CellRegistration<CharacterDiscoverCollectionViewCell, Character> { (cell, _, character) in
            cell.configure(character: character)
        }

        let episodeCellRegistration = UICollectionView.CellRegistration<EpisodeDiscoverCollectionViewCell, Episode> { (cell, _, episode) in
            cell.configure(episode: episode)
        }

        let locationCellRegistration = UICollectionView.CellRegistration<LocationDiscoverCollectionViewCell, Location> { (cell, _, location) in
            cell.configure(location: location)
        }

        dataSource = UICollectionViewDiffableDataSource
        <Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }

            switch section {
            case .characters:
                return collectionView.dequeueConfiguredReusableCell(using: characterCellRegistration, for: indexPath, item: item.character)

            case .episodes:
                return collectionView.dequeueConfiguredReusableCell(using: episodeCellRegistration, for: indexPath, item: item.episode)

            case .locations:
                return collectionView.dequeueConfiguredReusableCell(using: locationCellRegistration, for: indexPath, item: item.location)
            }
        }

        dataSource.supplementaryViewProvider = { (view, _, index) in
            return view.dequeueConfiguredReusableSupplementary(using: headerSectionRegistration, for: index)
        }

        configureSnapshotsSection()
    }

    private func configureSnapshotsSection() {
        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateCharactersSnapshots(characters: [Character]) {
        let allCharacters = characters.map { Item(character: $0, episode: nil, location: nil) }
        var allCharactersSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        allCharactersSnapshot.append(allCharacters)
        dataSource.apply(allCharactersSnapshot, to: .characters, animatingDifferences: true)
    }

    private func updateEpisodesSnapshots(episodes: [Episode]) {
        let allEpisodes = episodes.map { Item(character: nil, episode: $0, location: nil) }
        var allEpisodesSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        allEpisodesSnapshot.append(allEpisodes)
        dataSource.apply(allEpisodesSnapshot, to: .episodes, animatingDifferences: true)
    }

    private func updateLocationsSnapshots(locations: [Location]) {
        let alllocations = locations.map { Item(character: nil, episode: nil, location: $0) }
        var allLocationsSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        allLocationsSnapshot.append(alllocations)
        dataSource.apply(allLocationsSnapshot, to: .locations, animatingDifferences: true)
    }
}

extension DiscoverViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section at index: \(indexPath.section)")
        }

        switch section {
        case .locations:
            let location = presenter.locations[indexPath.item]
            navigator.navigate(to: .locationDetail(location))

        case .characters:
            let character = presenter.characters[indexPath.item]
            navigator.navigate(to: .characterDetail(character))

        case .episodes:
            let episode = presenter.episodes[indexPath.item]
            navigator.navigate(to: .episodeDetail(episode))
        }
    }
}

extension DiscoverViewController: DiscoverViewPresenterDelegate {
    func discoverViewPresenterStartLoading(_ presenter: DiscoverViewPresenter) {
        activityIndicatorView.startAnimating()
    }

    func discoverViewPresenterFinishedLoading(_ presenter: DiscoverViewPresenter) {
        activityIndicatorView.stopAnimating()
    }

    func discoverViewPresenter(_ presenter: DiscoverViewPresenter, didReceiveCharacters characters: [Character]) {
        updateCharactersSnapshots(characters: characters)
    }

    func discoverViewPresenter(_ presenter: DiscoverViewPresenter, didReceiveEpisodes episodes: [Episode]) {
        updateEpisodesSnapshots(episodes: episodes)
    }

    func discoverViewPresenter(_ presenter: DiscoverViewPresenter, didReceiveLocations locations: [Location]) {
        updateLocationsSnapshots(locations: locations)
    }

    func discoverViewPresenter(_ presenter: DiscoverViewPresenter, didReceiveError error: Error) {
        navigator.navigate(to: .error(error))
    }
}

extension DiscoverViewController: TitleMoreSupplementaryViewDelegate {
    func titleMoreSupplementaryViewDelegate(_ supplementaryView: TitleMoreSupplementaryView, didTapShowMoreButton button: UIButton, indexPath: IndexPath?) {
        guard let indexPath = indexPath,
              let section = Section(rawValue: indexPath.section)
        else {
            return
        }

        switch section {
        case .locations:
            navigator.navigate(to: .locationsList)

        case .characters:
            navigator.navigate(to: .charactersList)

        case .episodes:
            navigator.navigate(to: .episodesList)
        }
    }
}
