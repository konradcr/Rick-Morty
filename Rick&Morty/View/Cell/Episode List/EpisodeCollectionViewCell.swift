//
//  EpisodeCollectionViewCell.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 11/05/2022.
//

import UIKit
import RMModel

class EpisodeCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let layoutMargin = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        static let spacing: CGFloat = 20
        static let cornerRadius: CGFloat = 10
        static let cellHeight: CGFloat = 80
        static let circleRadius = cellHeight - layoutMargin.top - layoutMargin.bottom
    }

    // MARK: - Properties

    private weak var nameLabel: UILabel!

    private weak var airDateLabel: UILabel!
    private weak var episodeLabel: UILabel!
    private weak var verticalStackView: UIStackView!
    private weak var disclosureIndicator: UIImageView!

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

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: Constants.cornerRadius
        ).cgPath
    }

    private func setupView() {
        layer.cornerRadius = 10
        layer.shadowRadius = 5.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 5)

        setGradient()

        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.layoutMargins = Constants.layoutMargin

        let episodeLabel = UILabel()
        episodeLabel.font = UIFont.preferredFont(forTextStyle: .body)
        episodeLabel.adjustsFontSizeToFitWidth = true
        episodeLabel.textColor = .darkGray
        episodeLabel.layer.backgroundColor = UIColor.white.cgColor
        episodeLabel.layer.cornerRadius = Constants.circleRadius / 2
        episodeLabel.clipsToBounds = true

        let nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.textColor = .white

        let airDateLabel = UILabel()
        airDateLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        airDateLabel.adjustsFontSizeToFitWidth = true
        airDateLabel.textColor = .darkGray

        let verticalStackView = UIStackView(arrangedSubviews: [nameLabel, airDateLabel])
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .leading
        verticalStackView.distribution = .fillEqually

        let disclosureIndicator = UIImageView()
        let disclosureConfig = UIImage.SymbolConfiguration(hierarchicalColor: .darkGray)
        disclosureIndicator.image = UIImage(systemName: "chevron.right", withConfiguration: disclosureConfig)

        [episodeLabel,
         verticalStackView,
         disclosureIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        self.nameLabel = nameLabel
        self.airDateLabel = airDateLabel
        self.episodeLabel = episodeLabel
        self.verticalStackView = verticalStackView
        self.disclosureIndicator = disclosureIndicator
    }

    private func setGradient() {
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.frame = contentView.bounds
        backgroundGradient.colors = [UIColor.gray.withAlphaComponent(0.9).cgColor, UIColor.lightGray.withAlphaComponent(0.9).cgColor]
        backgroundGradient.startPoint = .zero
        contentView.layer.insertSublayer(backgroundGradient, at: 0)
    }

    private func setupConstraints() {
        let viewDictionary = ["episodeLabel": episodeLabel!,
                              "verticalStackView": verticalStackView!,
                              "disclosureIndicator": disclosureIndicator!]

        let metricsDictionary = ["spacing": Constants.spacing,
                                 "circleRadius": Constants.circleRadius]

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[episodeLabel(circleRadius)]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[verticalStackView]|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "V:[disclosureIndicator]",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[episodeLabel(circleRadius)]-spacing-[verticalStackView]-(>=0)-[disclosureIndicator]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary)
        )

        NSLayoutConstraint.activate([
            disclosureIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension EpisodeCollectionViewCell {
    func configure(episode: Episode) {
        nameLabel.text = episode.name
        airDateLabel.text = episode.airDate
        episodeLabel.text = episode.episode
    }
}
