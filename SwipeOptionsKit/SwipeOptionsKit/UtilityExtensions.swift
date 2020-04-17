//
//  UtilityExtensions.swift
//  SwipeOptions
//
//  Created by Ameya on 14/04/20.
//  Copyright © 2020 Ameya. All rights reserved.
//

import UIKit

extension UIButton {
    func leftImage(image: UIImage, renderMode: UIImage.RenderingMode) {
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: image.size.width / 2)
        self.contentHorizontalAlignment = .left
        self.imageView?.contentMode = .scaleAspectFit
    }

    func rightImage(image: UIImage, renderMode: UIImage.RenderingMode){
        self.setImage(image.withRenderingMode(renderMode), for: .normal)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left:image.size.width / 2, bottom: 0, right: 0)
        self.contentHorizontalAlignment = .right
        self.imageView?.contentMode = .scaleAspectFit
    }
}

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) {[weak self] (allSubviews, subview) -> [UIView] in
            self?.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
}

extension UICollectionView {
    var swipeCells: [SwipeCollectionViewCell] {
        return visibleCells.compactMap({ $0 as? SwipeCollectionViewCell })
    }
    
    func hideSwipeCell() {
        swipeCells.forEach { $0.hideSwipableCellActions(animated: true) }
    }
}
