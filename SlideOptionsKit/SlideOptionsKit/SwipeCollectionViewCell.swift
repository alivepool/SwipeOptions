//
//  SwipeCollectionViewCell.swift
//  SlideOptions
//
//  Created by Ameya on 16/04/20.
//  Copyright © 2020 Ameya. All rights reserved.
//

import UIKit

public protocol SwipeCollectionViewCellDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, swipeActionConfigurationForRowAt indexPath: IndexPath) -> [SwipeActionConfiguration]?
}

open class SwipeCollectionViewCell: UICollectionViewCell {
    
    private var swipeController: SwipeControllerType?
    
    public weak var collectionView: UICollectionView?
    public var indexPath: IndexPath?
    public weak var actionsProvider: SwipeCollectionViewCellDelegate?
    
    public var actionsState: SwipeActionsViewMode = .none
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        configureCell()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    func configureCell() {
        swipeController = SwipeController(containerView: self, swipeView: contentView)
        swipeController?.actionsProvider = self
    }
    
    public func hideSwipableCellActions(animated: Bool) {
        swipeController?.hideActions(animated: animated)
    }
}

extension SwipeCollectionViewCell: SwipeActionsProvider {
    public func swipeConfiguration() -> [SwipeActionConfiguration]? {
        guard let collectionView = collectionView, let indexPath = indexPath else {
            return nil
        }
        return actionsProvider?.collectionView(collectionView, swipeActionConfigurationForRowAt: indexPath)
    }
    
    public func actionHandler(configuration: SwipeActionConfiguration) {
        guard let indexPath = indexPath else { return }
        configuration.handler?(configuration, indexPath)
    }
}

extension SwipeCollectionViewCell {
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superview = superview else { return false }
        
        let point = convert(point, to: superview)
        
        for cell in collectionView?.swipeCells ?? [] {
            if (cell.actionsState == .left || cell.actionsState == .right) && !cell.frame.contains(point) {
                collectionView?.hideSwipeCell()
                return false
            }
        }
        
        return frame.contains(point)
    }
}
