//
//  EventItemController.swift
//  Lush Player
//
//  Created by Joel Trew on 10/04/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

protocol EventProgrammeControllerDelegate: class {
    
    func eventItemsDidScroll(collectionView: UICollectionView)
}

class EventProgrammeController: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var events: [Event]?
    var maxNumberOfProgrammes: Int = 4
    
    weak var delegate: EventProgrammeControllerDelegate?
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfProgrammesToDisplay(item: collectionView.tag)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StandardMediaCellId", for: indexPath) as? StandardMediaCell else {
            fatalError("Incorrect cell")
        }
        
        guard let events = events else {
            fatalError("Recieved cell count but no events array")
        }
        
        let programme = events[collectionView.tag].programmes[indexPath.item]
        cell.imageView.set(imageURL: programme.thumbnailURL, withPlaceholder: nil, completion: nil)
        cell.titleLabel.text = programme.title
        cell.mediaTypeLabel.text = programme.media.displayString()
        cell.datePublishedLabel.text = programme.date?.timeAgo
        
        return cell
    }
    
    
    func numberOfProgrammesToDisplay(item: Int) -> Int {
        guard let events = events else { return 0 }
        return events[item].programmes.prefix(maxNumberOfProgrammes).count
    }
}


extension EventProgrammeController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = CGFloat(250)
        let cellHeight = CGFloat(Double(cellWidth) * 0.9)
        
        let cellSize = CGSize(width: cellWidth , height: cellHeight)
        return cellSize
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return UIEdgeInsets.zero
        }
        
        let inset = collectionView.bounds.width - (flowLayout.minimumInteritemSpacing + 250)
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: inset/2)
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let collectionView = scrollView as? UICollectionView else { return }
        
        delegate?.eventItemsDidScroll(collectionView: collectionView)
    }
    
}
