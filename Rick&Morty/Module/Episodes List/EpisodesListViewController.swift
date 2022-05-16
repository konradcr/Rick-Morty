//
//  EpisodesListViewController.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

final class EpisodesListViewController: UIViewController {
    private enum Constants {
        static let spacing = CGFloat(20)
        static let layoutMargin = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    private let presenter: EpisodesListViewPresenter
    private let navigator: EpisodesListViewNavigator

    private weak var collectionView: UICollectionView!
    private var activityIndicatorView: UIActivityIndicatorView!

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    init(presenter: EpisodesListViewPresenter, navigator: EpisodesListViewNavigator) {
        self.presenter = presenter
        self.navigator = navigator

        super.init(nibName: nil, bundle: nil)

        self.tabBarItem = UITabBarItem(title: "Episodes", image: UIImage(systemName: "tv"), tag: 2)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupDataSource()
        setupConstraints()

        presenter.fetchEpisodes()
        presenter.attachView(self)
    }

    @objc
    private func filterBarButtonAction(_ sender: UIBarButtonItem) {
        navigator.navigate(to: .filter(self, presenter.selectedFilter, sender))
    }

    private func setupView() {
        navigationItem.title = "Episodes"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "tag"), style: .done, target: self, action: #selector(filterBarButtonAction(_:)))
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
        let sectionProvider = { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }

            switch sectionKind {
            case .main:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(Constants.spacing)
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = Constants.spacing
                section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                return section
            }
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }

    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<EpisodeCollectionViewCell, Episode> { (cell, indexPath, episode) in
            cell.configure(episode: episode)
        }

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section")
            }

            switch section {
            case .main:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item.episode)
            }
        }

        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateEpisodesSnapshots(episodes: [Episode]) {
        let episodes = episodes.map { Item(episode: $0) }
        var episodesSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        episodesSnapshot.append(episodes)
        dataSource.apply(episodesSnapshot, to: .main, animatingDifferences: true)
    }
}

extension EpisodesListViewController {
    enum Section: Int, CaseIterable {
        case main
    }

    struct Item: Hashable {
        let id = UUID()
        let episode: Episode
    }
}

extension EpisodesListViewController: EpisodesListViewPresenterDelegate {
    func episodesListViewPresenterStartLoading(_ presenter: EpisodesListViewPresenter) {
        activityIndicatorView.startAnimating()
    }

    func episodesListViewPresenterFinishedLoading(_ presenter: EpisodesListViewPresenter) {
        activityIndicatorView.stopAnimating()
    }

    func episodesListViewPresenter(_ presenter: EpisodesListViewPresenter, didReceiveEpisodes episodes: [Episode]) {
        updateEpisodesSnapshots(episodes: episodes)
    }

    func episodesListViewPresenter(_ presenter: EpisodesListViewPresenter, didReceiveError error: Error) {
        navigator.navigate(to: .error(error))
    }

    func episodesListViewPresenter(_ presenter: EpisodesListViewPresenter, didEnableFilter isEnable: Bool) {
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: isEnable ? "tag.fill" : "tag")
        navigationItem.rightBarButtonItem?.isSelected = isEnable
    }
}

extension EpisodesListViewController: EpisodeFilterViewControllerDelegate {
    func episodeFilterViewController(_ controller: EpisodeFilterViewController, didAddFilter filter: EpisodeFilter) {
        presenter.addFilter(filter)
    }

    func episodeFilterViewController(_ controller: EpisodeFilterViewController, didRemoveFilter filter: EpisodeFilter) {
        presenter.removeFilter(filter)
    }
}

extension EpisodesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section at index: \(indexPath.section)")
        }

        switch section {
        case .main:
            let episode = presenter.episodes[indexPath.item]
            navigator.navigate(to: .episodeDetail(episode))
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastItemIndex = collectionView.numberOfItems(inSection: 0)
        let threeshold = lastItemIndex - 5

        guard indexPath.item == threeshold else {
            return
        }
        presenter.fetchEpisodes()
    }
}

