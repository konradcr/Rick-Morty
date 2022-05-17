//
//  DefaultCollectionViewCell.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 05/05/2022.
//

import UIKit
import RMModel

class LocationDiscoverCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let layoutMargin = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        static let spacing: CGFloat = 10
        static let cornerRadius: CGFloat = 10
        static let rmLightBrown = UIColor(red: 228 / 255, green: 167 / 255, blue: 136 / 255, alpha: 0.9)
        static let rmDarkBrown = UIColor(red: 124 / 255, green: 62 / 255, blue: 29 / 255, alpha: 0.9)
    }

    // MARK: - Properties

    private weak var nameLabel: UILabel!
    private weak var typeLabel: UILabel!
    private weak var dimensionLabel: UILabel!

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

        let backgroundImage = UIImageView()
        let backgroundConfig = UIImage.SymbolConfiguration(hierarchicalColor: .gray)
        backgroundImage.image = UIImage(systemName: "globe.asia.australia", withConfiguration: backgroundConfig)
        backgroundImage.contentMode = .scaleAspectFit
        backgroundView = backgroundImage

        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.layoutMargins = Constants.layoutMargin

        let nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        nameLabel.textColor = .white

        let typeLabel = UILabel()
        typeLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        typeLabel.textColor = .lightText

        let dimensionLabel = UILabel()
        dimensionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        dimensionLabel.textColor = .darkText

        [nameLabel,
         typeLabel,
         dimensionLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        self.nameLabel = nameLabel
        self.typeLabel = typeLabel
        self.dimensionLabel = dimensionLabel
    }

    private func setGradient() {
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.frame = contentView.bounds
        backgroundGradient.colors = [Constants.rmDarkBrown.cgColor, Constants.rmLightBrown.cgColor]
        backgroundGradient.startPoint = .zero
        contentView.layer.insertSublayer(backgroundGradient, at: 0)
    }

    private func setupConstraints() {
        let viewDictionary = ["nameLabel": nameLabel!,
                              "typeLabel": typeLabel!,
                              "dimensionLabel": dimensionLabel!]

        let metricsDictionary = ["spacing": Constants.spacing]

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLabel]-spacing-[typeLabel]-(>=0)-[dimensionLabel]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[nameLabel]-(>=0)-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[typeLabel]-(>=0)-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=0)-[dimensionLabel]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary)
        )
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension LocationDiscoverCollectionViewCell {
    func configure(location: Location) {
        nameLabel.text = location.name
        typeLabel.text = location.type
        dimensionLabel.text = location.dimension
    }
}
