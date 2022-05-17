//
//  IconCollectionViewCell.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 09/05/2022.
//

import UIKit

class BadgedDetailCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let layoutMargin = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        static let spacing: CGFloat = 10
        static let iconSize: CGFloat = 30
        static let stackWidth: CGFloat = 80
    }

    static func size(width: CGFloat, origin: String, species: String) -> CGSize {
        let verticalMargin = Constants.layoutMargin.top + Constants.layoutMargin.bottom + Constants.iconSize
        let originHeight = origin.heightWithConstrainedWidth(width: Constants.stackWidth - Constants.layoutMargin.left, font: UIFont.preferredFont(forTextStyle: .caption1))
        let speciesHeight = species.heightWithConstrainedWidth(width: Constants.stackWidth - Constants.layoutMargin.left, font: UIFont.preferredFont(forTextStyle: .caption1))

        let height = verticalMargin + max(originHeight, speciesHeight)

        return CGSize(width: width, height: height)
    }

    // MARK: - Properties

    private weak var speciesImageView: UIImageView!
    private weak var speciesLabel: UILabel!
    private weak var speciesStackView: UIStackView!
    private weak var originImageView: UIImageView!
    private weak var originLabel: UILabel!
    private weak var originStackView: UIStackView!
    private weak var horizontalStackView: UIStackView!

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
        contentView.layoutMargins = Constants.layoutMargin

        let speciesImageView = UIImageView()
        speciesImageView.contentMode = .scaleAspectFill
        speciesImageView.clipsToBounds = true

        let speciesLabel = UILabel()
        speciesLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        speciesLabel.numberOfLines = 0
        speciesLabel.textAlignment = .center

        let speciesStackView = UIStackView(arrangedSubviews: [speciesImageView, speciesLabel])
        speciesStackView.spacing = Constants.spacing
        speciesStackView.axis = .vertical
        speciesStackView.distribution = .fillProportionally
        speciesStackView.alignment = .center

        let originImageView = UIImageView()
        originImageView.contentMode = .scaleAspectFill
        originImageView.clipsToBounds = true

        let originLabel = UILabel()
        originLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        originLabel.numberOfLines = 0
        originLabel.textAlignment = .center

        let originStackView = UIStackView(arrangedSubviews: [originImageView, originLabel])
        originStackView.spacing = Constants.spacing
        originStackView.axis = .vertical
        originStackView.distribution = .fillProportionally
        originStackView.alignment = .center

        let horizontalStackView = UIStackView(arrangedSubviews: [speciesStackView, originStackView])
        horizontalStackView.spacing = Constants.spacing
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .equalSpacing
        horizontalStackView.layoutMargins = Constants.layoutMargin

        [speciesStackView, originStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        self.speciesImageView = speciesImageView
        self.speciesLabel = speciesLabel
        self.speciesStackView = speciesStackView
        self.originImageView = originImageView
        self.originLabel = originLabel
        self.originStackView = originStackView
        self.horizontalStackView = horizontalStackView
    }

    private func setupConstraints() {
        let viewDictionary = ["speciesStackView": speciesStackView!,
                              "originStackView": originStackView!]

        let metricsDictionary = ["spacing": Constants.spacing,
                                 "stackWidth": Constants.stackWidth]

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[speciesStackView]-(>=0)-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[originStackView]-(>=0)-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[originStackView(stackWidth)]-spacing-[speciesStackView(stackWidth)]-(>=0)-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewDictionary)
        )
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension BadgedDetailCollectionViewCell {
    func configure(species: String, origin: String) {
        let sizeIconConfig = UIImage.SymbolConfiguration(pointSize: Constants.iconSize)
        let weightIconConfig = UIImage.SymbolConfiguration(weight: .semibold)
        let colorIconConfig = UIImage.SymbolConfiguration(hierarchicalColor: .gray)
        let combinedIconConfig = sizeIconConfig.applying(weightIconConfig).applying(colorIconConfig)

        speciesImageView.image = UIImage(systemName: "pawprint", withConfiguration: combinedIconConfig)
        speciesLabel.text = species
        originImageView.image = UIImage(systemName: "globe.asia.australia", withConfiguration: combinedIconConfig)
        originLabel.text = origin
    }
}
