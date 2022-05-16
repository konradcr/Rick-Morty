//
//  CharacterDetailsCollectionViewCell.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 09/05/2022.
//

import UIKit

class CharacterDetailsCollectionViewCell: UICollectionViewCell {
    private enum Constants {
        static let textContentMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        static let horizontalSpacing: CGFloat = 10
    }

    static func size(for width: CGFloat, status: String, type: String?, gender: String) -> CGSize {
        let horizontalTextContentMargins = Constants.textContentMargins.left + Constants.textContentMargins.right

        let size = CGSize(width: width - horizontalTextContentMargins,
                          height: .greatestFiniteMagnitude)

        let attributedString = CharacterDetailsCollectionViewCell.attributedText(status: status, type: type, gender: gender)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: size)
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)

        let textStorage = NSTextStorage(attributedString: attributedString)
        textStorage.addLayoutManager(layoutManager)

        layoutManager.ensureLayout(for: textContainer)

        let usedRect = layoutManager.usedRect(for: textContainer)

        let verticalTextContentMargins = Constants.textContentMargins.top + Constants.textContentMargins.bottom

        return CGSize(width: width,
                      height: verticalTextContentMargins + ceil(usedRect.height))
    }

    // MARK: - Properties

    private weak var textView: TextView!

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
        let textView = TextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.isOpaque = false
        textView.tintColor = .clear
        textView.textContainerInset = Constants.textContentMargins
        textView.textColor = .black
        textView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(textView)

        self.textView = textView
    }

    private func setupConstraints() {
        let viewsDictionary = ["textView" : textView!]

        NSLayoutConstraint.activate(
            NSLayoutConstraint.constraints(withVisualFormat: "H:|[textView]|",
                                           options: [],
                                           metrics: nil,
                                           views: viewsDictionary),
            NSLayoutConstraint.constraints(withVisualFormat: "V:|[textView]|",
                                           options: [],
                                           metrics: nil,
                                           views: viewsDictionary)
        )
    }

    private static func attributedText(status: String, type: String?, gender: String) -> NSAttributedString {
        var attributedStrings = [NSAttributedString]()

        let statusText = "Status: \(status)"
        let mutableAttributedStatusString = NSMutableAttributedString(string: statusText,
                                                                attributes: [.font : UIFont.preferredFont(forTextStyle: .body),
                                                                             .foregroundColor: UIColor.black])
        mutableAttributedStatusString.addAttributes([.font : UIFont.preferredFont(forTextStyle: .body),
                                                     .foregroundColor : UIColor.secondaryLabel],
                                              range: statusText.nsRange(of: status))
        attributedStrings.append(mutableAttributedStatusString)

        if let type = type {
            let typeText = "Type: \(type)"
            let mutableAttributedTypeString = NSMutableAttributedString(string: typeText,
                                                                    attributes: [.font : UIFont.preferredFont(forTextStyle: .body),
                                                                                 .foregroundColor: UIColor.black])
            mutableAttributedTypeString.addAttributes([.font : UIFont.preferredFont(forTextStyle: .body),
                                                       .foregroundColor : UIColor.secondaryLabel],
                                                  range: typeText.nsRange(of: type))
            attributedStrings.append(mutableAttributedTypeString)
        }

        let genderText = "Gender: \(gender)"
        let mutableAttributedGenderString = NSMutableAttributedString(string: genderText,
                                                                attributes: [.font : UIFont.preferredFont(forTextStyle: .body),
                                                                             .foregroundColor: UIColor.black])
        mutableAttributedGenderString.addAttributes([.font : UIFont.preferredFont(forTextStyle: .body),
                                                     .foregroundColor : UIColor.secondaryLabel],
                                              range: genderText.nsRange(of: gender))
        attributedStrings.append(mutableAttributedGenderString)

        let finalMutableAttributedString = NSMutableAttributedString()

        attributedStrings.forEach {
            if !finalMutableAttributedString.string.isEmpty {
                finalMutableAttributedString.append(NSAttributedString(string: "\n"))
            }

            finalMutableAttributedString.append($0)
        }

        return finalMutableAttributedString
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}

extension CharacterDetailsCollectionViewCell {
    func configure(status: String, type: String?, gender: String) {
        textView.attributedText = CharacterDetailsCollectionViewCell.attributedText(status: status, type: type, gender: gender)
    }
}

