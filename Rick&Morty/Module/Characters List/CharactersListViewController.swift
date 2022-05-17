//
//  CharactersListViewController.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 04/05/2022.
//

import UIKit
import RMModel

final class CharactersListViewController: UIViewController {
    private enum Constants {
        static let spacing = CGFloat(20)
        static let layoutMargin = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    private let presenter: CharactersListViewPresenter
    private let navigator: CharactersListViewNavigator

    private weak var collectionView: UICollectionView!
    private var activityIndicatorView: UIActivityIndicatorView!

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    init(presenter: CharactersListViewPresenter, navigator: CharactersListViewNavigator) {
        self.presenter = presenter
        self.navigator = navigator

        super.init(nibName: nil, bundle: nil)

        self.tabBarItem = UITabBarItem(title: "Characters", image: UIImage(systemName: "person.3"), tag: 1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupDataSource()
        setupConstraints()

        presenter.fetchCharacters()
        presenter.attachView(self)
    }

    private func setupView() {
        navigationItem.title = "Characters"
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
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
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
        let cellRegistration = UICollectionView.CellRegistration<CharacterCollectionViewCell, Character> { (cell, _, character) in
            cell.configure(character: character)
        }

        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section")
            }

            switch section {
            case .main:
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item.character)
            }
        }

        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    private func updateCharactersSnapshots(characters: [Character]) {
        let characters = characters.map { Item(character: $0) }
        var charactersSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
        charactersSnapshot.append(characters)
        dataSource.apply(charactersSnapshot, to: .main, animatingDifferences: true)
    }
}

extension CharactersListViewController {
    enum Section: Int, CaseIterable {
        case main
    }

    struct Item: Hashable {
        let id = UUID()
        let character: Character
    }
}

extension CharactersListViewController: CharactersListViewPresenterDelegate {
    func charactersListViewPresenterStartLoading(_ presenter: CharactersListViewPresenter) {
        activityIndicatorView.startAnimating()
    }

    func charactersListViewPresenterFinishedLoading(_ presenter: CharactersListViewPresenter) {
        activityIndicatorView.stopAnimating()
    }

    func charactersListViewPresenter(_ presenter: CharactersListViewPresenter, didReceiveCharacters characters: [Character]) {
        updateCharactersSnapshots(characters: characters)
    }

    func charactersListViewPresenter(_ presenter: CharactersListViewPresenter, didReceiveError error: Error) {
        navigator.navigate(to: .error(error))
    }
}

extension CharactersListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else {
            fatalError("Unknown section at index: \(indexPath.section)")
        }

        switch section {
        case .main:
            let character = presenter.characters[indexPath.item]
            navigator.navigate(to: .characterDetail(character))
        }
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastItemIndex = collectionView.numberOfItems(inSection: 0)
        let threeshold = lastItemIndex - 5

        guard indexPath.item == threeshold else {
            return
        }

        presenter.fetchCharacters()
    }
}
