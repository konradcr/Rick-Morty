//
//  EpisodeCollectionViewCell.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 05/05/2022.
//

import UIKit
import RMModel

class EpisodeDiscoverCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let layoutMargin = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        static let spacing: CGFloat = 10
        static let cornerRadius: CGFloat = 10
    }

    // MARK: - Properties

    private weak var nameLabel: UILabel!
    private weak var airDateLabel: UILabel!
    private weak var episodeLabel: UILabel!

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

        let nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        nameLabel.textColor = .white

        let airDateLabel = UILabel()
        airDateLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        airDateLabel.textColor = .darkGray

        let episodeLabel = UILabel()
        episodeLabel.font = UIFont.preferredFont(forTextStyle: .body)
        episodeLabel.textColor = .white

        let backgroundImage = UIImageView()
        let backgroundConfig = UIImage.SymbolConfiguration(hierarchicalColor: .gray)
        backgroundImage.image = UIImage(systemName: "tv", withConfiguration: backgroundConfig)
        backgroundImage.contentMode = .scaleAspectFit
        backgroundView = backgroundImage
        backgroundView?.center = CGPoint(x: 3*contentView.frame.width/4, y: contentView.frame.height/2)

        [nameLabel,
         airDateLabel,
         episodeLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        self.nameLabel = nameLabel
        self.airDateLabel = airDateLabel
        self.episodeLabel = episodeLabel
    }

    private func setGradient() {
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.frame = contentView.bounds
        backgroundGradient.colors = [UIColor.gray.withAlphaComponent(0.9).cgColor, UIColor.lightGray.withAlphaComponent(0.9).cgColor]
        backgroundGradient.startPoint = .zero
        contentView.layer.insertSublayer(backgroundGradient, at: 0)
    }

    private func setupConstraints() {
        let viewDictionary = ["nameLabel": nameLabel!,
                              "airDateLabel": airDateLabel!,
                              "episodeLabel": episodeLabel!]

        let metricsDictionary = ["spacing": Constants.spacing]

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLabel]-(>=0)-[episodeLabel]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=0)-[airDateLabel]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[nameLabel]-(>=0)-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[episodeLabel]-(>=0)-[airDateLabel]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary)
        )
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension EpisodeDiscoverCollectionViewCell {
    func configure(episode: Episode) {
        nameLabel.text = episode.name
        airDateLabel.text = episode.airDate
        episodeLabel.text = episode.episode
    }
}

