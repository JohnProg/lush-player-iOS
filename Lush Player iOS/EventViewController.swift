//
//  EventViewController.swift
//  Lush Player
//
/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

import UIKit
import LushPlayerKit

class EventViewController: ContentListingViewController<Event> {
    
    let eventProgrammeController = EventProgrammeController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "EventCollectionViewCell", bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: "EventCollectionViewCellId")
        
        viewModeForDeviceTraits(traits: self.traitCollection)

        eventProgrammeController.delegate = self
        collectionView?.collectionViewLayout.invalidateLayout()
        collectionView?.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
        
        if self.parent is MenuContainerViewController {
            collectionView?.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 70, right: 0)
        }
    }
    
    
    func viewModeForDeviceTraits(traits: UITraitCollection) {
        if (traits.horizontalSizeClass == .regular) ||  (UIDevice.current.orientation.isLandscape) {
            
            eventProgrammeController.viewMode = .extended
        } else {
            eventProgrammeController.viewMode = .compact
        }
    }
    
    
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        viewModeForDeviceTraits(traits: newCollection)
        collectionView?.collectionViewLayout.invalidateLayout()
        collectionView?.reloadData()
    }
    
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EventCollectionViewCellId", for: indexPath) as? EventCollectionViewCell {
            
            if case let .loaded(events) = viewState {
                
                let event = events[indexPath.item]
                cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: eventProgrammeController, forRow: indexPath.item)
                cell.eventLabel.text = event.title
                cell.didTapViewMore = { [weak self] button in
                    
                    if let menuVc = self?.parent as? EventContainerViewController {
                        
                        if let itemWithOffset = menuVc.menuItems.enumerated().filter({ $0.element.identifier == event.id }).first {
                            
                            let ip = IndexPath(item: itemWithOffset.offset, section: 0)
                            menuVc.menuCollectionView.selectItem(at: ip, animated: true, scrollPosition: .right)
                            menuVc.collectionView(menuVc.menuCollectionView, didSelectItemAt: ip)
                        }
                    }
                    
                }
                
                
                switch eventProgrammeController.viewMode {
                case .compact:
                    cell.pageMode = .individual(eventProgrammeController.numberOfProgrammesToDisplay(item: indexPath.item))
                    
                case .extended:
                    cell.pageMode = .page
                }
                
                
                return cell
            }
        }
        
        return UICollectionViewCell()
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

            return CGSize(width: collectionView.bounds.width, height: 500)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        guard let cell = cell as? EventCollectionViewCell else {
            return
        }
        if eventProgrammeController.viewMode == .extended {
            cell.pageControl.numberOfPages = Int(ceil(cell.eventItemsCollectionView.contentSize.width / cell.eventItemsCollectionView.frame.size.width))
        }

    }
    
    
    func showEvent(_ event: Event) {
        

    }
}


extension EventViewController: EventProgrammeControllerDelegate {
    
    
    func didSelectEventProgrammePreview(programme: Programme) {
        
        if let mediaDetailVc = UIStoryboard.init(name: "MediaDetail", bundle: nil).instantiateInitialViewController() as? MediaDetailViewController {
            mediaDetailVc.programme = programme
            show(mediaDetailVc, sender: self)
        }
        
    }


    func eventItemsDidScroll(collectionView: UICollectionView) {
        setPageControlIndex(for: collectionView)

    }
    
    func setPageControlIndex(for collectionView: UICollectionView) {
        guard let cell = self.collectionView?.cellForItem(at: IndexPath(item: collectionView.tag, section: 0)) as? EventCollectionViewCell else { return }
        
        switch eventProgrammeController.viewMode {
            
        case .compact:
            let contentOffset = collectionView.contentOffset
            let centrePoint =  CGPoint(
                x: contentOffset.x + collectionView.frame.midX,
                y: contentOffset.y + collectionView.frame.midY
            )
            
            
            if let index = collectionView.indexPathForItem(at: centrePoint){
                cell.pageControl.currentPage = index.row
            }
            
        case .extended:
            cell.pageControl.currentPage = Int(ceil(collectionView.contentOffset.x / collectionView.frame.size.width))
        }
    }
}
