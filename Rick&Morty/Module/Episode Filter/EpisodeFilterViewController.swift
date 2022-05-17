//
//  EpisodeFilterViewController.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 12/05/2022.
//

import UIKit

protocol EpisodeFilterViewControllerDelegate: AnyObject {
    func episodeFilterViewController(_ controller: EpisodeFilterViewController, didAddFilter filter: EpisodeFilter)
    func episodeFilterViewController(_ controller: EpisodeFilterViewController, didRemoveFilter filter: EpisodeFilter)
}

final class EpisodeFilterViewController: UIViewController {
    private enum Constants {
        static let spacing = CGFloat(10)
        static let layoutMargin = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    private let presenter: EpisodeFilterViewPresenter

    weak var delegate: EpisodeFilterViewControllerDelegate?

    private weak var collectionView: UICollectionView!

    private var dataSource: UICollectionViewDiffableDataSource<Section, EpisodeFilter>!

    init(presenter: EpisodeFilterViewPresenter) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupDataSource()
        setupConstraints()

        if let selectedFilter = presenter.selectedFilter {
            collectionView.selectItem(at: .init(item: selectedFilter.rawValue, section: 0), animated: false, scrollPosition: [])
        }

        presenter.attachView(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.preferredContentSize = collectionView.collectionViewLayout.collectionViewContentSize
    }

    private func setupView() {
        navigationItem.title = "Filter"
        view.backgroundColor = .systemBackground
        view.layoutMargins = Constants.layoutMargin

        let layout = createCollectionLayout()
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = view.backgroundColor
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self

        view.addSubview(collectionView)

        self.collectionView = collectionView
    }

    private func createCollectionLayout() -> UICollectionViewLayout {
        let sectionProvider = { (sectionIndex: Int, _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            guard let sectionKind = Section(rawValue: sectionIndex) else {
                return nil
            }

            switch sectionKind {
            case .season:
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.1))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(Constants.spacing)
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .estimated(30))
                let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                                elementKind: TitleSupplementaryView.reuseIdentifier,
                                                                                alignment: .top)
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = Constants.spacing
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 10, trailing: 20)
                section.boundarySupplementaryItems = [sectionHeader]
                return section
            }
        }
        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }

    private func setupDataSource() {
        let headerSectionRegistration: UICollectionView.SupplementaryRegistration<TitleSupplementaryView> = UICollectionView.SupplementaryRegistration
        <TitleSupplementaryView>(elementKind: TitleSupplementaryView.reuseIdentifier) { (supplementaryView, _, indexPath) in
            guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }
            supplementaryView.configure(text: section.headerTitle)
        }

        let cellRegistration = UICollectionView.CellRegistration<FilterCollectionViewCell, EpisodeFilter> { (cell, _, filter) in
            cell.configure(text: filter.name)
        }

        dataSource = UICollectionViewDiffableDataSource
        <Section, EpisodeFilter>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section")
            }

            switch section {
            case .season:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }

        dataSource.supplementaryViewProvider = { (view, _, index) in
            return view.dequeueConfiguredReusableSupplementary(using: headerSectionRegistration, for: index)
        }

        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, EpisodeFilter>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)

        let filters = EpisodeFilter.allCases
        var filtersSnapshot = NSDiffableDataSourceSectionSnapshot<EpisodeFilter>()
        filtersSnapshot.append(filters)
        dataSource.apply(filtersSnapshot, to: .season, animatingDifferences: false)
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

extension EpisodeFilterViewController {
    enum Section: Int, CaseIterable {
        case season

        var headerTitle: String {
            switch self {
            case .season:
                return "Season"
            }
        }
    }
}

extension EpisodeFilterViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if presenter.selectedFilter?.rawValue == indexPath.item {
            collectionView.deselectItem(at: indexPath, animated: true)
        }
        presenter.selectFilter(at: indexPath.item)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        presenter.deselectFilter(at: indexPath.item)
    }
}

extension EpisodeFilterViewController: EpisodeFilterViewPresenterDelegate {
    func episodeFilterViewPresenter(_ presenter: EpisodeFilterViewPresenter, didAddFilter filter: EpisodeFilter) {
        delegate?.episodeFilterViewController(self, didAddFilter: filter)
    }

    func episodeFilterViewPresenter(_ presenter: EpisodeFilterViewPresenter, didRemoveFilter filter: EpisodeFilter) {
        delegate?.episodeFilterViewController(self, didRemoveFilter: filter)
    }
}
