//
//  LocationCollectionViewCell.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 11/05/2022.
//

import UIKit
import RMModel

class LocationCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let layoutMargin = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        static let spacing: CGFloat = 20
        static let cornerRadius: CGFloat = 10
        static let cellHeight: CGFloat = 80
        static let rmLightBrown: UIColor = UIColor(red: 228/255, green: 167/255, blue: 136/255, alpha: 0.9)
        static let rmDarkBrown: UIColor = UIColor(red: 124/255, green: 62/255, blue: 29/255, alpha: 0.9)
    }

    // MARK: - Properties

    private weak var nameLabel: UILabel!
    private weak var dimensionLabel: UILabel!
    private weak var typeLabel: UILabel!
    private weak var horizontalStackView: UIStackView!
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

        let nameLabel = UILabel()
        nameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.textColor = .white

        let dimensionLabel = UILabel()
        dimensionLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        dimensionLabel.adjustsFontSizeToFitWidth = true
        dimensionLabel.textColor = .lightText

        let typeLabel = UILabel()
        typeLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        typeLabel.adjustsFontSizeToFitWidth = true
        typeLabel.textColor = .lightText

        let horizontalStackView = UIStackView(arrangedSubviews: [typeLabel, dimensionLabel])
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .fillProportionally
        horizontalStackView.spacing = Constants.spacing

        let verticalStackView = UIStackView(arrangedSubviews: [nameLabel, horizontalStackView])
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .leading
        verticalStackView.distribution = .fillEqually

        let disclosureIndicator = UIImageView()
        let disclosureConfig = UIImage.SymbolConfiguration(hierarchicalColor: Constants.rmDarkBrown)
        disclosureIndicator.image = UIImage(systemName: "chevron.right", withConfiguration: disclosureConfig)

        [verticalStackView,
         disclosureIndicator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        self.nameLabel = nameLabel
        self.dimensionLabel = dimensionLabel
        self.typeLabel = typeLabel
        self.horizontalStackView = horizontalStackView
        self.verticalStackView = verticalStackView
        self.disclosureIndicator = disclosureIndicator
    }

    private func setGradient() {
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.frame = contentView.bounds
        backgroundGradient.colors = [Constants.rmDarkBrown.cgColor, Constants.rmLightBrown.cgColor]
        backgroundGradient.startPoint = .zero
        contentView.layer.insertSublayer(backgroundGradient, at: 0)
    }

    private func setupConstraints() {
        let viewDictionary = ["verticalStackView": verticalStackView!,
                              "disclosureIndicator": disclosureIndicator!]

        let metricsDictionary = ["spacing": Constants.spacing]

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[verticalStackView]|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "V:[disclosureIndicator]",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[verticalStackView]-(>=0)-[disclosureIndicator]-|",
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

extension LocationCollectionViewCell {
    func configure(location: Location) {
        nameLabel.text = location.name
        dimensionLabel.text = location.dimension
        typeLabel.text = location.type
    }
}

