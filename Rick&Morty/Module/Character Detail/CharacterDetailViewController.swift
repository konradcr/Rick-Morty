//
//  CharacterDetailViewController.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 09/05/2022.
//

import UIKit
import RMModel

final class CharacterDetailViewController: UIViewController {
    private enum Constants {
        static let layoutMargins = UIEdgeInsets.zero
        static let spacing: CGFloat = 20
        static let rmLightBlue = UIColor(red: 183 / 255, green: 228 / 255, blue: 249 / 255, alpha: 0.3)
    }

    // MARK: - Properties

    private let presenter: CharacterDetailViewPresenter
    private let navigator: CharacterDetailViewNavigator

    private weak var collectionView: UICollectionView!
    private var activityIndicatorView: UIActivityIndicatorView!

    // MARK: - Initializers

    init(presenter: CharacterDetailViewPresenter, navigator: CharacterDetailViewNavigator) {
        self.presenter = presenter
        self.navigator = navigator

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupConstraints()

        presenter.fetchEpisodes()
        presenter.attachView(self)
    }

    // MARK: - UI Methods

    private func setupView() {
        navigationItem.largeTitleDisplayMode = .never

        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: view.bounds,
                                              collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.registerReusableItem(CharacterImageCollectionViewCell.self)
        collectionView.registerReusableItem(TitleNameCollectionViewCell.self)
        collectionView.registerReusableItem(BadgedDetailCollectionViewCell.self)
        collectionView.registerReusableItem(CharacterDetailsCollectionViewCell.self)
        collectionView.registerReusableItem(CharacterEpisodesContainerCollectionViewCell.self)

        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.center = view.center
        activityIndicatorView.startAnimating()

        view.addSubview(collectionView)
        view.addSubview(activityIndicatorView)

        self.collectionView = collectionView
        self.activityIndicatorView = activityIndicatorView
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

extension CharacterDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return presenter.characterInformations.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch presenter.characterInformations[indexPath.section] {
        case .image(let imageURL):
            let cell = collectionView.dequeueReusableItem(CharacterImageCollectionViewCell.self, at: indexPath)
            cell.configure(imageURL: imageURL)
            return cell

        case .name(let name):
            let cell = collectionView.dequeueReusableItem(TitleNameCollectionViewCell.self, at: indexPath)
            cell.configure(name: name, color: Constants.rmLightBlue)
            return cell

        case .badgedDetailed(species: let species, origin: let origin):
            let cell = collectionView.dequeueReusableItem(BadgedDetailCollectionViewCell.self, at: indexPath)
            cell.configure(species: species, origin: origin)
            return cell

        case .details(status: let status, type: let type, gender: let gender):
            let cell = collectionView.dequeueReusableItem(CharacterDetailsCollectionViewCell.self, at: indexPath)
            cell.configure(status: status, type: type, gender: gender)
            return cell

        case .episodes(let episodes):
            let cell = collectionView.dequeueReusableItem(CharacterEpisodesContainerCollectionViewCell.self, at: indexPath)
            cell.episodes = episodes
            cell.delegate = self
            return cell
        }
    }
}

extension CharacterDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let sectionKind = presenter.characterInformations[section]

        switch sectionKind {
        case .image, .badgedDetailed, .details:
            return UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)

        case .name:
            return UIEdgeInsets(top: 0, left: 40, bottom: 10, right: 40)

        case .episodes:
            return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sectionInset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)

        let width = collectionView.bounds.width - (sectionInset.left + sectionInset.right)

        let section = presenter.characterInformations[indexPath.section]

        switch section {
        case .image:
            return CharacterImageCollectionViewCell.size(forWidth: width)

        case .name(let name):
            return TitleNameCollectionViewCell.size(width: width, text: name)

        case .badgedDetailed(species: let species, origin: let origin):
            return BadgedDetailCollectionViewCell.size(width: width, origin: origin, species: species)

        case .details(status: let status, type: let type, gender: let gender):
            return CharacterDetailsCollectionViewCell.size(for: width, status: status, type: type, gender: gender)

        case .episodes:
            return CharacterEpisodesContainerCollectionViewCell.size(width: width)
        }
    }
}

extension CharacterDetailViewController: UICollectionViewDelegate {
}

extension CharacterDetailViewController: CharacterDetailViewPresenterDelegate {
    func characterDetailViewPresenterStartLoading(_ presenter: CharacterDetailViewPresenter) {
        activityIndicatorView.startAnimating()
    }

    func characterDetailViewPresenterFinishedLoading(_ presenter: CharacterDetailViewPresenter) {
        activityIndicatorView.stopAnimating()
    }

    func characterDetailViewPresenter(_ presenter: CharacterDetailViewPresenter, didReceiveEpisodes episodes: [Episode]) {
        collectionView.reloadData()
    }

    func characterDetailViewPresenter(_ presenter: CharacterDetailViewPresenter, didReceiveError error: Error) {
        navigator.navigate(to: .error(error))
    }
}

extension CharacterDetailViewController: CharacterEpisodesContainerCollectionViewCellDelegate {
    func characterEpisodesContainerCollectionViewCell(_ container: CharacterEpisodesContainerCollectionViewCell, didSelectCell cell: CharacterEpisodesCollectionViewCell, at indexPath: IndexPath) {
        let selectedEpisode = presenter.episodesFromCharacter[indexPath.item]
        navigator.navigate(to: .episodeDetail(selectedEpisode))
    }
}
