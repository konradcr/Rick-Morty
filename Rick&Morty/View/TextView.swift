//
//  TextView.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 09/05/2022.
//

import UIKit

final class TextView: UITextView {

    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }

    override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        return nil
    }
}
