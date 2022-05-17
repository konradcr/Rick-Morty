//
//  LocationsListViewController.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

final class LocationsListViewController: UIViewController {
    private enum Constants {
        static let spacing = CGFloat(20)
        static let layoutMargin = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    private let presenter: LocationsListViewPresenter
    private let navigator: LocationsListViewNavigator

    private weak var collectionView: UICollectionView!
    private var activityIndicatorView: UIActivityIndicatorView!

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    init(presenter: LocationsListViewPresenter, navigator: LocationsListViewNavigator) {
        self.presenter = presenter
        self.navigator = navigator

        super.init(nibName: nil, bundle: nil)

        self.tabBarItem = UITabBarItem(title: "Locations", image: UIImage(systemName: "globe.asia.australia"), tag: 3)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupDataSource()
        setupConstraints()

        presenter.fetchLocations()
        presenter.attachView(self)
    }

    private func setupView() {
        navigationItem.title = "Locations"
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
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }

    private func setupDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<LocationCollectionViewCell, Location> { (cell, _, location) in
            cell.configure(location: location)
        }

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section")
            }

            switch section {
            case .main:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item.location)
            }
        }

        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateLocationsSnapshots(locations: [Location]) {
        let locations = locations.map { Item(location: $0) }
        var locationsSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        locationsSnapshot.append(locations)
        dataSource.apply(locationsSnapshot, to: .main, animatingDifferences: true)
    }
}

extension LocationsListViewController {
    enum Section: Int, CaseIterable {
        case main
    }

    struct Item: Hashable {
        let id = UUID()
        let location: Location
    }
}

extension LocationsListViewController: LocationsListViewPresenterDelegate {
    func locationsListViewPresenterStartLoading(_ presenter: LocationsListViewPresenter) {
        activityIndicatorView.startAnimating()
    }

    func locationsListViewPresenterFinishedLoading(_ presenter: LocationsListViewPresenter) {
        activityIndicatorView.stopAnimating()
    }

    func locationsListViewPresenter(_ presenter: LocationsListViewPresenter, didReceiveLocations locations: [Location]) {
        updateLocationsSnapshots(locations: locations)
    }

    func locationsListViewPresenter(_ presenter: LocationsListViewPresenter, didReceiveError error: Error) {
        navigator.navigate(to: .error(error))
    }
}

extension LocationsListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section at index: \(indexPath.section)")
        }

        switch section {
        case .main:
            let location = presenter.locations[indexPath.item]
            navigator.navigate(to: .locationDetail(location))
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastItemIndex = collectionView.numberOfItems(inSection: 0)
        let threeshold = lastItemIndex - 5

        guard indexPath.item == threeshold else {
            return
        }

        presenter.fetchLocations()
    }
}
