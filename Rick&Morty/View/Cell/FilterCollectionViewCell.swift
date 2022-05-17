//
//  FilterCollectionViewCell.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 12/05/2022.
//

import UIKit

final class FilterCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let layoutMargins = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
        static let rmGreen = UIColor(red: 105 / 255, green: 144 / 255, blue: 53 / 255, alpha: 1)
    }

    static func size(for width: CGFloat, text: String) -> CGSize {
        let verticalMargins = Constants.layoutMargins.top + Constants.layoutMargins.bottom
        let horizontalMargins = Constants.layoutMargins.left + Constants.layoutMargins.right

        let cellWidth = width - horizontalMargins

        let textSize = NSAttributedString(string: text,
                                          attributes: [.font: UIFont.preferredFont(forTextStyle: .body)])
            .boundingRect(with: .init(width: cellWidth,
                                      height: .greatestFiniteMagnitude),
                          options: .usesLineFragmentOrigin,
                          context: nil)

        let height = verticalMargins + ceil(textSize.height)
        let width = min(ceil(textSize.width) + horizontalMargins, width)

        return .init(width: width, height: height)
    }

    private var hasSetupConstraints = false

    override var isSelected: Bool {
        didSet {
            setupColors()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            contentView.alpha = isHighlighted ? 0.4 : 1
        }
    }

    private weak var label: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupColors()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.layoutMargins = Constants.layoutMargins
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 15

        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(label)

        self.label = label
    }

    private func setupColors() {
        if isSelected {
            label.textColor = UIColor.white
            contentView.backgroundColor = Constants.rmGreen
        } else {
            label.textColor = UIColor.white
            contentView.backgroundColor = UIColor.lightGray
        }
    }

    private func setupConstraints() {
        let viewsDictionary = ["label": label!]

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|",
                                           options: [],
                                           metrics: nil,
                                           views: viewsDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-|",
                                           options: [],
                                           metrics: nil,
                                           views: viewsDictionary)
        )
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

extension FilterCollectionViewCell {
    func configure(text: String) {
        label.text = text
    }
}
