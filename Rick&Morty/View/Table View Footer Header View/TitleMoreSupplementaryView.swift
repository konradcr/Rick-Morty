//
//  TitleMoreSupplementaryView.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 10/05/2022.
//

import UIKit

protocol TitleMoreSupplementaryViewDelegate: AnyObject {
    func titleMoreSupplementaryViewDelegate(_ supplementaryView: TitleMoreSupplementaryView, didTapShowMoreButton button: UIButton, indexPath: IndexPath?)
}

final class TitleMoreSupplementaryView: UICollectionReusableView {

    // MARK: - Properties

    private enum Constants {
        static let layoutMargins = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        static let separatorHeight: CGFloat = 1
        static let rmGreen = UIColor(red: 105 / 255, green: 144 / 255, blue: 53 / 255, alpha: 1)
    }

    weak var delegate: TitleMoreSupplementaryViewDelegate?

    var indexPath: IndexPath?

    private weak var label: UILabel!
    private weak var button: UIButton!
    private weak var horizontalStackView: UIStackView!
    private weak var separator: UIView!

    private var hasSetupConstraints = false

    static let reuseIdentifier = "title-more-supplementary-reuse-identifier"

    // MARK: - Initializers

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    required init?(coder: NSCoder) {
        fatalError("Failed to init")
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

extension TitleMoreSupplementaryView {
    private func setupView() {
        layoutMargins = Constants.layoutMargins

        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true

        var configuration = UIButton.Configuration.gray()
        configuration.title = "Show More"
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = Constants.rmGreen
        configuration.buttonSize = .mini
        let button = UIButton(configuration: configuration)

        let horizontalStackView = UIStackView(arrangedSubviews: [label, button])
        horizontalStackView.axis = .horizontal
        horizontalStackView.distribution = .equalSpacing

        let separator = UIView()
        separator.backgroundColor = Constants.rmGreen

        [horizontalStackView,
         separator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        self.label = label
        self.separator = separator
        self.horizontalStackView = horizontalStackView
        self.button = button
    }

    private func setupConstraints() {
        let viewsDictionary = ["horizontalStackView": horizontalStackView!,
                               "separator": separator!]

        let metricsDictionary = ["bottomMargin": layoutMargins.bottom,
                                 "separatorHeight": Constants.separatorHeight]

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-[horizontalStackView]-(>=bottomMargin)-[separator(separatorHeight)]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewsDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[horizontalStackView]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewsDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[separator]-|",
                                           options: [],
                                           metrics: metricsDictionary,
                                           views: viewsDictionary)
        )
    }

    @objc
    private func showMoreButtonTapped(_ sender: UIButton) {
        delegate?.titleMoreSupplementaryViewDelegate(self, didTapShowMoreButton: sender, indexPath: self.indexPath)
    }
}

extension TitleMoreSupplementaryView {
    func configure(text: String?) {
        label.text = text
        button.addTarget(self, action: #selector(showMoreButtonTapped(_:)), for: .touchDown)
    }
}
