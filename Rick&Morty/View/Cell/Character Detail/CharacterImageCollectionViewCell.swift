//
//  CharacterImageCollectionViewCell.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 09/05/2022.
//

import UIKit

class CharacterImageCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let imageSize: CGSize = .init(width: 200, height: 200)
        static let layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        static let spacing: CGFloat = 10
    }

    static func size(forWidth width: CGFloat) -> CGSize {
        let height = Constants.layoutMargins.top + Constants.layoutMargins.bottom + Constants.imageSize.height
        return .init(width: width, height: height)
    }

    // MARK: - Properties

    private weak var imageView: UIImageView!

    private var hasSetupConstraints = false

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Methods

    override func updateConstraints() {
        if !hasSetupConstraints {
            setupConstraints()
            hasSetupConstraints = true
        }

        super.updateConstraints()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
        imageView?.cancelImageLoad()
    }

    private func setupView() {
        contentView.layoutMargins = Constants.layoutMargins
        contentView.clipsToBounds = true

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.imageSize.height / 2
        imageView.layer.borderWidth = 1

        contentView.addSubview(imageView)

        self.imageView = imageView
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize.height),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension CharacterImageCollectionViewCell {
    func configure(imageURL: URL) {
        imageView.loadImage(at: imageURL)
    }
}
