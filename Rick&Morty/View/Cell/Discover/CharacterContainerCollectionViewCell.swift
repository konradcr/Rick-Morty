//
//  CharacterContainerCollectionViewCell.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 06/05/2022.
//

import UIKit
import RMModel

class CharacterContainerCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        static let cellMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        static let spacing = CGFloat(20)
    }

    // MARK: - Properties

    private weak var collectionView: UICollectionView!

    private var hasSetupConstraints = false

    var characters = [Character]() {
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
        layout.sectionInset = .init(top: 20, left: 20, bottom: 20, right: 20)
        layout.minimumInteritemSpacing = 20

        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerReusableItem(CharacterDiscoverCollectionViewCell.self)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(collectionView)

        self.collectionView = collectionView
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
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

extension CharacterContainerCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellMaxWidth = collectionView.bounds.width - (Constants.cellMargins.left + Constants.cellMargins.right)
        return .init(width: cellMaxWidth/2 - Constants.spacing, height: 200)
    }
}

extension CharacterContainerCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return characters.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableItem(CharacterDiscoverCollectionViewCell.self, at: indexPath)
        cell.configure(character: characters[indexPath.item])
        return cell
    }
}
