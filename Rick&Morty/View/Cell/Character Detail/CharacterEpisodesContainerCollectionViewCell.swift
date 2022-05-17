//
//  CharacterEpisodesContainerCollectionViewCell.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 10/05/2022.
//

import UIKit
import RMModel

protocol CharacterEpisodesContainerCollectionViewCellDelegate: AnyObject {
    func characterEpisodesContainerCollectionViewCell(_ container: CharacterEpisodesContainerCollectionViewCell, didSelectCell cell: CharacterEpisodesCollectionViewCell, at indexPath: IndexPath)
}

class CharacterEpisodesContainerCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let layoutMargins = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        static let cellMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        static let spacing = CGFloat(20)
    }

    static func size(width: CGFloat) -> CGSize {
        let cellHeight = CGFloat(120)
        let verticalMargins = Constants.layoutMargins.top + Constants.layoutMargins.bottom

        return .init(width: width, height: cellHeight + verticalMargins)
    }

    // MARK: - Properties

    private weak var collectionView: UICollectionView!
    private weak var layout: UICollectionViewFlowLayout!

    weak var delegate: CharacterEpisodesContainerCollectionViewCellDelegate?

    private var hasSetupConstraints = false

    var episodes = [Episode]() {
        didSet {
            collectionView.reloadData()
        }
    }

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Methods

    private func setupView() {
        contentView.layoutMargins = Constants.layoutMargins

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = Constants.layoutMargins
        layout.minimumInteritemSpacing = Constants.spacing

        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerReusableItem(CharacterEpisodesCollectionViewCell.self)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)

        self.collectionView = collectionView
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    override func updateConstraints() {
        if !hasSetupConstraints {
            setupConstraints()
            hasSetupConstraints = true
        }

        super.updateConstraints()
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension CharacterEpisodesContainerCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellMaxWidth = collectionView.bounds.width - (Constants.cellMargins.left + Constants.cellMargins.right)
        return CharacterEpisodesCollectionViewCell.size(width: cellMaxWidth / 2)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CharacterEpisodesCollectionViewCell else {
            return
        }
        delegate?.characterEpisodesContainerCollectionViewCell(self, didSelectCell: cell, at: indexPath)
    }
}

extension CharacterEpisodesContainerCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return episodes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let episode = episodes[indexPath.item]
        let cell = collectionView.dequeueReusableItem(CharacterEpisodesCollectionViewCell.self, at: indexPath)
        cell.configure(name: episode.name, episode: episode.episode)
        return cell
    }
}
