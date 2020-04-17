//
//  ExampleCollectionViewController.swift
//  SwipeOptions
//
//  Created by Ameya on 14/04/20.
//  Copyright © 2020 Ameya. All rights reserved.
//

import UIKit
import SwipeOptionsKit

private let reuseIdentifier = "ExampleCollectionCell"
private let titleArray = ["AAAA", "BBBB", "CCCC", "DDDD", "EEEE", "FFFF", "GGGG", "HHHH", "IIII", "JJJJ"]
private let descriptionText = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
"""

class ExampleCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return titleArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ExampleCollectionViewCell
        cell.titleLabel.text = titleArray[indexPath.row]
        cell.descriptionLabel.text = descriptionText
        cell.actionsProvider = self
        cell.collectionView = collectionView
        cell.indexPath = indexPath
        return cell
    }


}

extension ExampleCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 40, height: 100)
    }
}

extension ExampleCollectionViewController: SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView, swipeActionConfigurationForRowAt indexPath: IndexPath) -> [SwipeActionConfiguration]? {
        
        var actionConfigOne = SwipeActionConfiguration()
        actionConfigOne.handler = {[weak self] configuration, indexPath in
            self?.oneTapped()
        }
        actionConfigOne.title = "Option One"
        
        var actionConfigTwo = SwipeActionConfiguration()
        actionConfigTwo.handler = {[weak self] configuration, indexPath in
            self?.twoTapped()
        }
        actionConfigTwo.title = "Option Two"
        
        var actionConfigThree = SwipeActionConfiguration()
        actionConfigThree.handler = {[weak self] configuration, indexPath in
            self?.threeTapped()
        }
        actionConfigThree.title = "Option Three"
        
        return [actionConfigOne, actionConfigTwo, actionConfigThree]
    }
    
    func oneTapped() {
//        print("One tapped")
        showAlert(message: "One tapped")
    }
    
    func twoTapped() {
        print("Two tapped")
        showAlert(message: "Two tapped")
    }
    
    func threeTapped() {
        print("Three tapped")
        showAlert(message: "Three tapped")
    }
    
    private func showAlert(message: String) {
        let alertControl = UIAlertController.init(title: "Action", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertControl.addAction(cancelAction)
        self.present(alertControl, animated: true, completion: nil)
    }
}
