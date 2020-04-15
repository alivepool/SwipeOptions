//
//  ExampleCollectionViewCell.swift
//  SlideOptions
//
//  Created by Ameya on 14/04/20.
//  Copyright © 2020 Ameya. All rights reserved.
//

import UIKit



protocol SwipableView {
    
}

struct SwipeActionConfiguration {

    var title: String?

    var backgroundColor: UIColor = .blue

    var image: UIImage?
}

protocol SwipableCollectionViewCellDelegate {
    func tableView(_ collectionView: UICollectionView,
    trailingSwipeActionConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
}

class ExampleCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    weak var collectionView: UICollectionView?
    private var actionsView = UIView()
    
    private var orignalLocation = CGPoint.zero
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        actionsView.translatesAutoresizingMaskIntoConstraints = false
        actionsView.backgroundColor = .red
        self.insertSubview(actionsView, belowSubview: contentView)
        
        NSLayoutConstraint.activate([
            actionsView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            actionsView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            actionsView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            actionsView.widthAnchor.constraint(equalToConstant: 120)
        ])
        
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(gestureRecognizer:))))
    }
    
    @objc func panGestureRecognizer(gestureRecognizer: UIPanGestureRecognizer) {
        
        switch gestureRecognizer.state {
        case .began:
            orignalLocation =  contentView.frame.origin
        case .changed :
            
            let velocity = gestureRecognizer.velocity(in: actionsView)
            
            if velocity.x >= 0  {
               
            
            
                let newX = gestureRecognizer.translation(in: self).x
                var cvFrame = contentView.frame
                cvFrame.origin.x = newX + orignalLocation.x
                if cvFrame.origin.x < actionsView.frame.size.width {
                contentView.frame = cvFrame
                }
            
            }
            else {
                
                    let newX = gestureRecognizer.translation(in: self).x
                    var cvFrame = contentView.frame
                    cvFrame.origin.x = newX + orignalLocation.x
                if cvFrame.origin.x < actionsView.frame.size.width {
                        contentView.frame = cvFrame
                }
                
            }
        case .ended, .cancelled, .failed:
            if contentView.frame.origin.x < actionsView.frame.size.width/2 {
                var cvFrame = contentView.frame
                cvFrame.origin.x = 0
                contentView.frame = cvFrame
            }
            else {
                var cvFrame = contentView.frame
                cvFrame.origin.x = actionsView.frame.size.width
                contentView.frame = cvFrame
            }
        default:
            break
        }
    }
    
}
