//
//  SwipeCollectionViewCell.swift
//  SlideOptions
//
//  Created by Ameya on 16/04/20.
//  Copyright © 2020 Ameya. All rights reserved.
//

import UIKit

class SwipeCollectionViewCell: UICollectionViewCell {
    
    private var swipeController: SwipeControllerType?
    weak var actionsProvider: SwipeActionsProvider? {
        didSet {
            swipeController?.actionsProvider = actionsProvider
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureCell()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    func configureCell() {
        swipeController = SwipeController(containerView: self, swipeView: contentView)
        swipeController?.actionsProvider = actionsProvider
    }
}
