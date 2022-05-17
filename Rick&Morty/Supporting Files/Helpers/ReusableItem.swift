//
//  ReusableItem.swift
//  Rick&Morty
//
//  Created by Konrad Cureau on 05/05/2022.
//

import Foundation
import UIKit

protocol ReusableItem: AnyObject {
    associatedtype Identifier: Equatable

    static var reuseIdentifier: Identifier { get }
}

extension ReusableItem where Identifier == String {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

protocol ReusableContainer {
    associatedtype IdentifierType: Equatable

    func registerReusableItem<T: ReusableItem>(_ reusableItem: T.Type) where T.Identifier == IdentifierType

    func dequeueReusableItem<T: ReusableItem>(_ type: T.Type, at indexPath: IndexPath) -> T where T.Identifier == IdentifierType
}

extension UITableViewCell: ReusableItem { }

extension UICollectionReusableView: ReusableItem { }

extension UITableViewHeaderFooterView: ReusableItem { }

extension UICollectionView: ReusableContainer {
    typealias IdentifierType = String

    /// Register a class for use in creating new collection view cells.
    ///
    /// - Parameter reusableItem: The cell type
    func registerReusableItem<T>(_ reusableItem: T.Type) where T: ReusableItem, UICollectionView.IdentifierType == T.Identifier {
        register(reusableItem, forCellWithReuseIdentifier: reusableItem.reuseIdentifier)
    }

    /// Returns a reusable cell object located by its identifier
    ///
    /// - Parameters:
    ///   - type: The cell type
    ///   - indexPath: he index path specifying the location of the cell.
    /// - Returns: A valid cell of type `T`.
    func dequeueReusableItem<T>(_ type: T.Type, at indexPath: IndexPath) -> T where T: ReusableItem, UICollectionView.IdentifierType == T.Identifier {
        return dequeueReusableCell(withReuseIdentifier: type.reuseIdentifier, for: indexPath) as! T
    }
}

extension UITableView: ReusableContainer {
    typealias IdentifierType = String

    func registerHeaderFooterViewReusableItem<T>(_ reusableItem: T.Type) where T: ReusableItem, UITableView.IdentifierType == T.Identifier {
        register(reusableItem, forHeaderFooterViewReuseIdentifier: reusableItem.reuseIdentifier)
    }

    func dequeueReusableHeaderFooterView<T>(_ type: T.Type) -> T where T: ReusableItem, UITableView.IdentifierType == T.Identifier {
        return dequeueReusableHeaderFooterView(withIdentifier: type.reuseIdentifier) as! T
    }

    /// Register a class for use in creating new table view cells.
    ///
    /// - Parameter reusableItem: The cell type
    func registerReusableItem<T>(_ reusableItem: T.Type) where T: ReusableItem, UITableView.IdentifierType == T.Identifier {
        register(reusableItem, forCellReuseIdentifier: reusableItem.reuseIdentifier)
    }

    /// Returns a reusable cell object located by its identifier
    ///
    /// - Parameters:
    ///   - type: The cell type
    ///   - indexPath: he index path specifying the location of the cell.
    /// - Returns: A valid cell of type `T`.
    func dequeueReusableItem<T>(_ type: T.Type, at indexPath: IndexPath) -> T where T: ReusableItem, UITableView.IdentifierType == T.Identifier {
        return dequeueReusableCell(withIdentifier: type.reuseIdentifier, for: indexPath) as! T
    }
}
