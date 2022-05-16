//
//  CharacterEpisodesCollectionnViewCell.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 10/05/2022.
//

import UIKit

class CharacterEpisodesCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        static let cellHeight: CGFloat = 100
        static let spacing: CGFloat = 10
        static let cornerRadius: CGFloat = 10
    }

    static func size(width: CGFloat) -> CGSize {
        let height = Constants.cellHeight

        return CGSize(width: width, height: height)
    }

    // MARK: - Properties

    private weak var nameLabel: UILabel!
    private weak var episodeLabel: UILabel!
    private weak var episodeStackView: UIStackView!

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

    private func setupView() {
        layer.cornerRadius = 10
        layer.shadowRadius = 5.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 5)

        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.backgroundColor = .lightGray.withAlphaComponent(0.5)
        contentView.layoutMargins = Constants.layoutMargins

        let nameLabel = UILabel()
        nameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .natural
        nameLabel.numberOfLines = 0
        nameLabel.lineBreakMode = .byWordWrapping

        let episodeLabel = UILabel()
        episodeLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        episodeLabel.textAlignment = .right
        episodeLabel.textColor = .white

        let episodeStackView = UIStackView(arrangedSubviews: [nameLabel, episodeLabel])
        episodeStackView.axis = .vertical
        episodeStackView.spacing = Constants.spacing
        episodeStackView.distribution = .equalSpacing

        [episodeStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        self.nameLabel = nameLabel
        self.episodeLabel = episodeLabel
        self.episodeStackView = episodeStackView
    }

    private func setupConstraints() {
        let viewsDictionary = ["episodeStackView": episodeStackView!]

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[episodeStackView]-|",
                                           options: [],
                                           metrics: nil,
                                           views: viewsDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[episodeStackView]-|",
                                           options: [],
                                           metrics: nil,
                                           views: viewsDictionary)
        )
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension CharacterEpisodesCollectionViewCell {
    func configure(name: String, episode: String) {
        nameLabel.text = name
        episodeLabel.text = episode
    }
}

