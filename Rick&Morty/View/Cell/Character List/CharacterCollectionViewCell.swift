//
//  CharacterCollectionViewCell.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 11/05/2022.
//

import UIKit
import RMModel
import Nuke

class CharacterCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let layoutMargin = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        static let imageSize: CGSize = .init(width: 75, height: 75)
        static let spacing: CGFloat = 10
        static let cornerRadius: CGFloat = 10
        static let rmLightBlue = UIColor(red: 183 / 255, green: 228 / 255, blue: 249 / 255, alpha: 0.3)
        static let rmGreen = UIColor(red: 105 / 255, green: 144 / 255, blue: 53 / 255, alpha: 1)
    }

    // MARK: - Properties

    private weak var imageView: UIImageView!

    private weak var nameLabel: UILabel!
    private weak var locationImageView: UIImageView!
    private weak var locationLabel: UILabel!
    private weak var speciesImageView: UIImageView!
    private weak var speciesLabel: UILabel!

    private weak var locationStackView: UIStackView!
    private weak var speciesStackView: UIStackView!
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

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.image = nil
        imageView?.cancelImageLoad()
    }

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
        let sizeIconConfig = UIImage.SymbolConfiguration(textStyle: .caption1)
        let weightIconConfig = UIImage.SymbolConfiguration(weight: .semibold)
        let colorIconConfig = UIImage.SymbolConfiguration(hierarchicalColor: .gray)
        let combinedIconConfig = sizeIconConfig.applying(weightIconConfig).applying(colorIconConfig)

        backgroundColor = .white

        layer.cornerRadius = 10
        layer.shadowRadius = 5.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 5)

        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.backgroundColor = Constants.rmLightBlue

        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.imageSize.height / 2
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor

        let nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 17)
        nameLabel.textColor = Constants.rmGreen

        let locationImageView = UIImageView()
        locationImageView.contentMode = .scaleAspectFit
        locationImageView.clipsToBounds = true
        locationImageView.preferredSymbolConfiguration = combinedIconConfig

        let locationLabel = UILabel()
        locationLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        locationLabel.textColor = .gray

        let locationStackView = UIStackView(arrangedSubviews: [locationImageView, locationLabel])
        locationStackView.axis = .horizontal
        locationStackView.distribution = .equalCentering
        locationStackView.spacing = Constants.spacing

        let speciesImageView = UIImageView()
        speciesImageView.contentMode = .scaleAspectFit
        speciesImageView.clipsToBounds = true
        speciesImageView.preferredSymbolConfiguration = combinedIconConfig

        let speciesLabel = UILabel()
        speciesLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        speciesLabel.textColor = .gray

        let speciesStackView = UIStackView(arrangedSubviews: [speciesImageView, speciesLabel])
        speciesStackView.axis = .horizontal
        speciesStackView.distribution = .equalCentering
        speciesStackView.spacing = Constants.spacing

        let verticalStackView = UIStackView(arrangedSubviews: [nameLabel, locationStackView, speciesStackView])
        verticalStackView.spacing = Constants.spacing
        verticalStackView.axis = .vertical
        verticalStackView.distribution = .fillProportionally
        verticalStackView.alignment = .leading
        verticalStackView.layoutMargins = Constants.layoutMargin

        let disclosureIndicator = UIImageView()
        let disclosureConfig = UIImage.SymbolConfiguration(hierarchicalColor: Constants.rmGreen)
        disclosureIndicator.image = UIImage(systemName: "chevron.right", withConfiguration: disclosureConfig)

        [imageView,
         verticalStackView,
         disclosureIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        self.imageView = imageView
        self.nameLabel = nameLabel
        self.locationImageView = locationImageView
        self.locationLabel = locationLabel
        self.locationStackView = locationStackView
        self.speciesImageView = speciesImageView
        self.speciesLabel = speciesLabel
        self.speciesStackView = speciesStackView
        self.verticalStackView = verticalStackView
        self.disclosureIndicator = disclosureIndicator
    }

    private func setupConstraints() {
        let viewDictionary = ["imageView": imageView!,
                              "verticalStackView": verticalStackView!,
                              "disclosureIndicator": disclosureIndicator!]

        let metricsDictionary = ["imageHeight": Constants.imageSize.height,
                                 "spacing": CGFloat(20)]

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:[imageView(imageHeight)]",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[verticalStackView]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "V:[disclosureIndicator]",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView(imageHeight)]-spacing-[verticalStackView]-(>=0)-[disclosureIndicator]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary)
        )

        NSLayoutConstraint.activate([
            imageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            disclosureIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension CharacterCollectionViewCell {
    func configure(character: Character) {
        imageView.loadImage(at: character.imageURL)
        nameLabel.text = character.name
        locationImageView.image = UIImage(systemName: "globe.asia.australia")
        locationLabel.text = character.origin.name
        speciesImageView.image = UIImage(systemName: "pawprint")
        speciesLabel.text = character.species
    }
}
