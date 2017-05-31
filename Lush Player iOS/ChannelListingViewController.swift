//
//  ChannelListingViewController.swift
//  Lush Player
//
//  Created by Joel Trew on 27/03/2017.
//  Copyright © 2017 ThreeSidedCube. All rights reserved.
//

import UIKit
import LushPlayerKit

// Displays a list of programmes relating to a channel
class ChannelListingViewController: ProgrammeListingViewController {
    
    // The channel the user selected to view programmes from
    var selectedChannel: Channel?

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    // Request programmes from the API for a specific Channel
    func refresh() {
        
        viewState = .loading
        
        // Exit if theres no channel model
        guard let selectedChannel = selectedChannel else { return }
        
        // If we've already pulled the programmes for the selected channel
        if let programmes = LushPlayerController.shared.channelProgrammes[selectedChannel] {
            if programmes.isEmpty {
                self.viewState = .empty
                return
            }
            self.viewState  = .loaded(programmes)
            
        } else {
            
            // Fetch the programmes for a specified channel
            LushPlayerController.shared.fetchProgrammes(for: selectedChannel, of: nil, with: { [weak self] (error, programmes) -> (Void) in
                
                // If we get an error, then display it
                if let error = error, let welf = self {
                    welf.handleError(error: error)
                    return
                }
                

                if let programmes = programmes {
                    // If there are no programmes so the empty state
                    if programmes.isEmpty, let emptyStateViewController = self?.emptyStateViewController {
                        self?.viewState = .empty
                        return
                    }
                    
                    self?.viewState  = .loaded(programmes)
                    return
                }
            })
        }
    }
    
    
    func handleError(error: Error) {
        
        self.connectionErrorViewController.retryAction = { [weak self] in
            self?.refresh()
        }
        
        if error is URLError {
            viewState = .error(error)
            return
        } else if (error as NSError).domain == "com.threesidedcube.ThunderRequest" {
            viewState = .error(error)
            return
        }
        
        UIAlertController.presentError(error, in: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView?.collectionViewLayout.invalidateLayout()
        if self.parent is MenuContainerViewController {
            collectionView?.contentInset = UIEdgeInsets(top: 70, left: 0, bottom: 90, right: 0)
        }
    }
    
}

enum ChannelError: Error, LocalizedError {
    
    case noProgrammes
}
