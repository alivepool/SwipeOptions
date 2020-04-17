//
//  ExampleCollectionViewCell.swift
//  SwipeOptions
//
//  Created by Ameya on 14/04/20.
//  Copyright © 2020 Ameya. All rights reserved.
//

import SwipeOptionsKit
import UIKit

class ExampleCollectionViewCell: SwipeCollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
