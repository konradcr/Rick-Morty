//
//  TitleNameCollectionViewCell.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 09/05/2022.
//

import UIKit

class TitleNameCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        static let spacing: CGFloat = 10
        static let cornerRadius: CGFloat = 10
        static let rmGreen: UIColor = UIColor(red: 105/255, green: 144/255, blue: 53/255, alpha: 1)
    }

    static func size(width: CGFloat, text: String) -> CGSize {
        let verticalMargin = Constants.layoutMargins.top + Constants.layoutMargins.bottom
        let horizontalMargin = Constants.layoutMargins.right + Constants.layoutMargins.left
        let labelWidth = width - horizontalMargin

        var height = verticalMargin

        let textHeight = text.heightWithConstrainedWidth(width: labelWidth, font: UIFont.preferredFont(forTextStyle: .title2))

        height += ceil(textHeight)

        return CGSize(width: width, height: height)
    }

    // MARK: - Properties

    private weak var nameLabel: UILabel!

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
        backgroundColor = .white

        layer.cornerRadius = 10
        layer.shadowRadius = 5.0
        layer.shadowColor = Constants.rmGreen.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 5)

        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = Constants.cornerRadius
        contentView.layoutMargins = Constants.layoutMargins

        let nameLabel = UILabel()
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.textColor = Constants.rmGreen
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.clipsToBounds = true
        nameLabel.layer.cornerRadius = Constants.cornerRadius

        contentView.addSubview(nameLabel)

        self.nameLabel = nameLabel
    }

    private func setupConstraints() {
        let viewsDictionary = ["nameLabel" : nameLabel!]

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLabel]-|",
                                           options: [],
                                           metrics: nil,
                                           views: viewsDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[nameLabel]-|",
                                           options: [],
                                           metrics: nil,
                                           views: viewsDictionary)
        )
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension TitleNameCollectionViewCell {
    func configure(name: String, color: UIColor) {
        nameLabel.text = name
        contentView.backgroundColor = color
    }
}
