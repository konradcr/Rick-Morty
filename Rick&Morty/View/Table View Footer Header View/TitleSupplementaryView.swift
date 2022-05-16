//
//  TitleSupplementaryView.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 05/05/2022.
//

import UIKit

final class TitleSupplementaryView: UICollectionReusableView {

    // MARK: - Properties

    private enum Constants {
        static let layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        static let separatorHeight: CGFloat = 1
        static let rmGreen: UIColor = UIColor(red: 105/255, green: 144/255, blue: 53/255, alpha: 1)
    }

    private weak var label: UILabel!
    private weak var separator: UIView!

    private var hasSetupConstraints = false
    static let reuseIdentifier = "title-supplementary-reuse-identifier"

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError()
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

extension TitleSupplementaryView {
    private func setupView() {
        layoutMargins = Constants.layoutMargins

        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true

        let separator = UIView()
        separator.backgroundColor = Constants.rmGreen

        [label,
         separator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        self.label = label
        self.separator = separator
    }

    private func setupConstraints() {
        let viewsDictionary = ["label": label!,
                               "separator": separator!]

        let metricsDictionary = ["bottomMargin" : layoutMargins.bottom,
                                 "separatorHeight" : Constants.separatorHeight]

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-(>=bottomMargin)-[separator(separatorHeight)]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewsDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewsDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[separator]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewsDictionary)
        )
    }
}

extension TitleSupplementaryView {
    func configure(text: String?) {
        label.text = text
    }
}

