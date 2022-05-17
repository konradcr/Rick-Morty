//
//  EpisodeDetailViewController.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 09/05/2022.
//

import UIKit
import RMModel

final class EpisodeDetailViewController: UIViewController {
    private enum Constants {
        static let layoutMargins = UIEdgeInsets.zero
        static let spacing: CGFloat = 20
    }

    // MARK: - Properties

    private let presenter: EpisodeDetailViewPresenter
    private let navigator: EpisodeDetailViewNavigator

    private weak var collectionView: UICollectionView!
    private var activityIndicatorView: UIActivityIndicatorView!

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    // MARK: - Initializers

    init(presenter: EpisodeDetailViewPresenter, navigator: EpisodeDetailViewNavigator) {
        self.presenter = presenter
        self.navigator = navigator

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupDatasource()
        setupConstraints()

        presenter.fetchCharacters()

        presenter.attachView(self)
    }

    private func setupView() {
        navigationItem.largeTitleDisplayMode = .never

        view.backgroundColor = .white
        view.layoutMargins = Constants.layoutMargins

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
            case .name:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                       heightDimension: .absolute(60))

                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                return section

            case .details:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9),
                                                       heightDimension: .absolute(80))

                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(Constants.spacing)

                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .estimated(44))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                                elementKind: TitleSupplementaryView.reuseIdentifier,
                                                                                alignment: .top)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = Constants.spacing
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                section.boundarySupplementaryItems = [sectionHeader]
                return section

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
                                                                                elementKind: TitleSupplementaryView.reuseIdentifier,
                                                                                alignment: .top)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = Constants.spacing
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                section.boundarySupplementaryItems = [sectionHeader]
                return section
            }
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    private func setupDatasource() {
        let headerSectionRegistration: UICollectionView.SupplementaryRegistration<TitleSupplementaryView> = UICollectionView.SupplementaryRegistration
        <TitleSupplementaryView>(elementKind: TitleSupplementaryView.reuseIdentifier) { (supplementaryView, _, indexPath) in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }
            supplementaryView.configure(text: section.headerTitle)
        }

        let titleCellRegistration = UICollectionView.CellRegistration<TitleNameCollectionViewCell, String> { (cell, _, name) in
            cell.configure(name: name, color: .white)
        }

        let detailsCellRegistration = UICollectionView.CellRegistration<EpisodeInfosCollectionViewCell, (episode: String, date: String)> { (cell, _, infos) in
            cell.configure(episode: infos.episode, date: infos.date)
        }

        let characterCellRegistration = UICollectionView.CellRegistration<CharacterDiscoverCollectionViewCell, Character> { (cell, _, character) in
            cell.configure(character: character)
        }

        dataSource = UICollectionViewDiffableDataSource
        <Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }

            switch section {
            case .name:
                return collectionView.dequeueConfiguredReusableCell(using: titleCellRegistration, for: indexPath, item: item.nameRow)

            case .details:
                return collectionView.dequeueConfiguredReusableCell(using: detailsCellRegistration, for: indexPath, item: item.detailsRow)

            case .characters:
                return collectionView.dequeueConfiguredReusableCell(using: characterCellRegistration, for: indexPath, item: item.charactersRow)
            }
        }

        dataSource.supplementaryViewProvider = { (view, _, index) in
            guard let section = Section(rawValue: index.section) else { fatalError("Unknown section") }

            switch section {
            case .name:
                return nil

            case .details, .characters:
                return view.dequeueConfiguredReusableSupplementary(using: headerSectionRegistration, for: index)
            }
        }

        configureSnapshotsSection()
        updateBasicSnapshots()
    }

    private func configureSnapshotsSection() {
        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateBasicSnapshots() {
        let name = Item(nameRow: presenter.episode.name, detailsRow: nil, charactersRow: nil)
        var nameSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        nameSnapshot.append([name])
        dataSource.apply(nameSnapshot, to: .name, animatingDifferences: false)
        let details = Item(nameRow: nil, detailsRow: (episode: presenter.episode.episode, date: presenter.episode.airDate), charactersRow: nil)
        var detailsSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        detailsSnapshot.append([details])
        dataSource.apply(detailsSnapshot, to: .details, animatingDifferences: false)
    }

    private func updateCharactersSnapshots(characters: [Character]) {
        let allCharacters = characters.map { Item(nameRow: nil, detailsRow: nil, charactersRow: $0) }
        var allCharactersSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        allCharactersSnapshot.append(allCharacters)
        dataSource.apply(allCharactersSnapshot, to: .characters, animatingDifferences: true)
    }

    private func setupConstraints() {
        let viewsDictionary = ["collectionView": collectionView!]

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|",
                                           options: [],
                                           metrics: nil,
                                           views: viewsDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[collectionView]|",
                                           options: [],
                                           metrics: nil,
                                           views: viewsDictionary)
        )
    }
}

extension EpisodeDetailViewController {
    enum Section: Int, CaseIterable {
        case name
        case details
        case characters

        var headerTitle: String? {
            switch self {
            case .name:
                return nil

            case .details:
                return "Details"

            case .characters:
                return "Residents"
            }
        }
    }

    struct Item: Hashable {
        let identifier = UUID()
        let nameRow: String?
        let detailsRow: (episode: String, date: String)?
        let charactersRow: Character?

        static func == (lhs: EpisodeDetailViewController.Item, rhs: EpisodeDetailViewController.Item) -> Bool {
            lhs.identifier == rhs.identifier
        }
        func hash(into hasher: inout Hasher) {
            hasher.combine(identifier)
        }
    }
}

extension EpisodeDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }

        switch section {
        case .name, .details:
            return

        case .characters:
            navigator.navigate(to: .characterDetail(presenter.charactersFromEpisode[indexPath.item]))
        }
    }
}

extension EpisodeDetailViewController: EpisodeDetailViewPresenterDelegate {
    func episodeDetailViewPresenterStartLoading(_ presenter: EpisodeDetailViewPresenter) {
        activityIndicatorView.startAnimating()
    }

    func episodeDetailViewPresenterFinishedLoading(_ presenter: EpisodeDetailViewPresenter) {
        activityIndicatorView.stopAnimating()
    }

    func episodeDetailViewPresenter(_ presenter: EpisodeDetailViewPresenter, didReceiveCharacters characters: [Character]) {
        updateCharactersSnapshots(characters: characters)
    }

    func episodeDetailViewPresenter(_ presenter: EpisodeDetailViewPresenter, didReceiveError error: Error) {
        navigator.navigate(to: .error(error))
    }
}
